local sfx = SFXManager()

local REPLACE_CHANCE = 0.05

local PIPE_SPEED = 18
local PIPE_MAXSPEED = 15

local PIPE_DAMAGE = 3
local PIPE_DAMAGEFREQ = 5

local PIPE_RETURN_TIME = 10
local PIPE_ARC = 10

---@param isContinued boolean
local function replacePipe(_, isContinued)
    if(isContinued) then return end

    local rng = ToyboxMod:generateRng(Game():GetSeeds():GetStartSeed())
    if(rng:RandomFloat()<REPLACE_CHANCE) then
        local pools = {
            {ItemPoolType.POOL_SHOP, 1},
            {ItemPoolType.POOL_OLD_CHEST, 1},
        }

        local pool = Game():GetItemPool()
        pool:RemoveCollectible(ToyboxMod.COLLECTIBLE_DADS_PIPE)

        for _, pooldata in ipairs(pools) do
            pool:AddCollectible(pooldata[1], {
                itemID = ToyboxMod.COLLECTIBLE_NOT_A_PIPE,
                weight = pooldata[2]
            })
        end
    else
        local pool = Game():GetItemPool()
        pool:RemoveCollectible(ToyboxMod.COLLECTIBLE_NOT_A_PIPE)
        pool:ResetCollectible(ToyboxMod.COLLECTIBLE_DADS_PIPE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, replacePipe)

---@param player EntityPlayer
local function useMeltedCandle(_, _, rng, player, flags)
    if(player:GetItemState()==ToyboxMod.COLLECTIBLE_NOT_A_PIPE) then
        player:SetItemState(0)
        player:AnimateCollectible(ToyboxMod.COLLECTIBLE_NOT_A_PIPE, "HideItem")
    else
        player:SetItemState(ToyboxMod.COLLECTIBLE_NOT_A_PIPE)
        player:AnimateCollectible(ToyboxMod.COLLECTIBLE_NOT_A_PIPE, "LiftItem")
    end

    return {
        Discharge = false,
        Remove = false,
        ShowAnim = false,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useMeltedCandle, ToyboxMod.COLLECTIBLE_NOT_A_PIPE)

---@param player EntityPlayer
local function tryUseHeldCandle(_, player)
    if(player:GetItemState()~=ToyboxMod.COLLECTIBLE_NOT_A_PIPE) then return end

    if(player:GetAimDirection():Length()>0) then
        local dir = (player:GetAimDirection():Length()<0.01 and player.Velocity or player:GetAimDirection())
        dir = dir*PIPE_SPEED
        dir = dir+player:GetTearMovementInheritance(dir)
        dir = dir:Rotated(PIPE_ARC)

        local pipe = Isaac.Spawn(EntityType.ENTITY_EFFECT, ToyboxMod.EFFECT_PIPE_BOOMERANG, 0, player.Position, dir, player):ToEffect()

        player:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
        player:AnimateCollectible(ToyboxMod.COLLECTIBLE_NOT_A_PIPE, "HideItem")
        player:SetItemState(0)

        sfx:Play(SoundEffect.SOUND_BOOMERANG_THROW)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, tryUseHeldCandle)

---@param effect EntityEffect
local function pipeInit(_, effect)
    local sp = effect:GetSprite()
    sp:Play("Rotate", true)

    effect.CollisionDamage = PIPE_DAMAGE

    effect.SpriteOffset = Vector(0,-12)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, pipeInit, ToyboxMod.EFFECT_PIPE_BOOMERANG)

---@param effect EntityEffect
local function pipeUpdate(_, effect)
    if(not sfx:IsPlaying(SoundEffect.SOUND_BOOMERANG_LOOP)) then
        sfx:Play(SoundEffect.SOUND_BOOMERANG_LOOP,nil,nil,true)
    end

    local hurtEnt = false
    if(effect.FrameCount%PIPE_DAMAGEFREQ==0) then
        local rad = 12*math.max(effect.SpriteScale.X, effect.SpriteScale.Y)
        local effRef = EntityRef(effect)
        for _, ent in ipairs(Isaac.FindInRadius(effect.Position, rad, EntityPartition.ENEMY)) do
            if(ent and ent:IsVulnerableEnemy()) then
                ent:TakeDamage(effect.CollisionDamage, 0, effRef, 1)
                hurtEnt = true
            end
        end

        if(hurtEnt) then
            sfx:Play(SoundEffect.SOUND_BOOMERANG_HIT)
        end
    end

    if(hurtEnt or effect.FrameCount==PIPE_RETURN_TIME) then
        local dir = effect.Velocity:Normalized()
        local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, ToyboxMod.EFFECT_PIPE_SMOKE, 0, effect.Position, dir, effect.SpawnerEntity):ToEffect()
        smoke.SpriteScale = smoke.SpriteScale*0.7
        smoke.CollisionDamage = smoke.CollisionDamage*0.5
    end

    if(not effect.SpawnerEntity) then return end

    if(effect.FrameCount>PIPE_RETURN_TIME) then
        local vel = (effect.SpawnerEntity.Position-effect.Position)
        if(vel:Length()>PIPE_MAXSPEED) then
            vel = vel:Resized(PIPE_MAXSPEED)
        end

        effect.Velocity = ToyboxMod:lerp(effect.Velocity, vel, 0.1+math.max(0, (effect.FrameCount-30)*0.01))
    else
        effect.Velocity = effect.Velocity*0.95
        effect.Velocity = effect.Velocity:Rotated(-2*PIPE_ARC/(PIPE_RETURN_TIME-1))
    end

    if(effect.FrameCount>PIPE_RETURN_TIME and effect.Position:Distance(effect.SpawnerEntity.Position)<20) then
        sfx:Play(SoundEffect.SOUND_BOOMERANG_CATCH)
        effect:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, pipeUpdate, ToyboxMod.EFFECT_PIPE_BOOMERANG)

---@param effect EntityEffect
local function pipeRemove(_, effect)
    if(effect.Variant==ToyboxMod.EFFECT_PIPE_BOOMERANG) then
        sfx:Stop(SoundEffect.SOUND_BOOMERANG_LOOP)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, pipeRemove, EntityType.ENTITY_EFFECT)