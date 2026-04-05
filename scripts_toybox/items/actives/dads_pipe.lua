local sfx = SFXManager()

local SMOKE_TIMEOUT = 30*4
local SMOKE_DAMAGE = 8
local SMOKE_SLOWDUR = 30*3
local SMOKE_SLOWINT = 0.75
local SMOKE_DAMAGEFREQ = 5
local SMOKE_SCALE = 20
local SMOKE_FINALSCALE = 70

local SMOKE_STOPDMG_THRESHOLD = 10

local SMOKE_BASESCALE = 40

---@param player EntityPlayer
local function useMeltedCandle(_, _, rng, player, flags)
    if(player:GetItemState()==ToyboxMod.COLLECTIBLE_DADS_PIPE) then
        player:SetItemState(0)
        player:AnimateCollectible(ToyboxMod.COLLECTIBLE_DADS_PIPE, "HideItem")
    else
        player:SetItemState(ToyboxMod.COLLECTIBLE_DADS_PIPE)
        player:AnimateCollectible(ToyboxMod.COLLECTIBLE_DADS_PIPE, "LiftItem")
    end

    return {
        Discharge = false,
        Remove = false,
        ShowAnim = false,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useMeltedCandle, ToyboxMod.COLLECTIBLE_DADS_PIPE)

---@param player EntityPlayer
local function tryUseHeldCandle(_, player)
    if(player:GetItemState()~=ToyboxMod.COLLECTIBLE_DADS_PIPE) then return end

    if(player:GetAimDirection():Length()>0) then
        local dir = (player:GetAimDirection():Length()<0.01 and player.Velocity or player:GetAimDirection())
        dir = dir*10
        dir = dir+player:GetTearMovementInheritance(dir)

        local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, ToyboxMod.EFFECT_PIPE_SMOKE, 0, player.Position, dir, player):ToEffect()

        player:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
        player:AnimateCollectible(ToyboxMod.COLLECTIBLE_DADS_PIPE, "HideItem")
        player:SetItemState(0)

        sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT,nil,nil,nil,0.9)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, tryUseHeldCandle)

---@param effect EntityEffect
local function smokeInit(_, effect)
    effect.Timeout = SMOKE_TIMEOUT
    effect.CollisionDamage = SMOKE_DAMAGE
    effect.SpriteScale = Vector(1,1)*SMOKE_SCALE/SMOKE_BASESCALE

    effect.SpriteOffset = Vector(0,-15)
    effect.DepthOffset = effect.DepthOffset+40

    effect.Color = Color(1,1,1,0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, smokeInit, ToyboxMod.EFFECT_PIPE_SMOKE)

---@param effect EntityEffect
local function smokeUpdate(_, effect)
    if(effect.LifeSpan<effect.Timeout) then effect.LifeSpan = effect.Timeout end
    
    local prevFrac = (effect.Timeout+1)/effect.LifeSpan
    local frac = effect.Timeout/effect.LifeSpan

    local maxvel = 0.5
    if(effect.Velocity:Length()>maxvel) then
        effect.Velocity = effect.Velocity*0.9
    end
    if(effect.Velocity:Length()<maxvel) then
        effect.Velocity = effect.Velocity:Resized(maxvel)
    end

    effect.SpriteScale = effect.SpriteScale*ToyboxMod:lerp(SMOKE_FINALSCALE, SMOKE_SCALE, frac)/ToyboxMod:lerp(SMOKE_FINALSCALE, SMOKE_SCALE, prevFrac)
    effect.Color = Color(1,1,1,frac^0.5)

    if(effect.FrameCount%SMOKE_DAMAGEFREQ==0 and effect.Timeout>SMOKE_STOPDMG_THRESHOLD) then
        local rad = ToyboxMod:lerp(SMOKE_FINALSCALE, SMOKE_SCALE, frac)
        local dmg = effect.CollisionDamage*(frac^0.5)
        local effRef = EntityRef(effect)
        for _, ent in ipairs(Isaac.FindInRadius(effect.Position, rad, EntityPartition.ENEMY)) do
            if(ent and ent:IsVulnerableEnemy()) then
                ent:TakeDamage(dmg, 0, effRef, 1)
                ent:AddSlowing(effRef, math.max(0,SMOKE_SLOWDUR-ent:GetSlowingCountdown()), SMOKE_SLOWINT, Color(1,1,1.3,1,0.16,0.16,0.16))
            end
        end
    end

    if(effect.Timeout==0) then effect:Remove() end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, smokeUpdate, ToyboxMod.EFFECT_PIPE_SMOKE)