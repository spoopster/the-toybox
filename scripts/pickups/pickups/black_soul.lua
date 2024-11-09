local mod = MilcomMOD
local sfx = SFXManager()

local BLACK_SOUL_TRAIL_OFFSET = Vector(0,-25)
local BLACK_SOUL_SPEED = 35

local SPIRIT_FOLLOW_DELAY = 12
local SPIRIT_FLICKER_FREQ = 7
local SPIRIT_FLICKER_CRAZYFREQ = 2
local SPIRIT_MINALPHA = 0.75

local SPIRIT_DMG = 3
local SPIRIT_CRAZYDMG = 2
local SPIRIT_DMGPERSOUL = 0.25

local SPIRIT_CRAZYSPEED = 16
local SPIRIT_CRAZYFASTERDIST = 40*1.2
local SPIRIT_CRAZYFASTERSPEED = 24
local SPIRIT_TARGETRADIUS = 40*4

--! PICKUP LOGIC
function mod:getBlackSpiritNum(player)
    local numShadows = math.max(0, mod:getEntityData(player, "BLACKSOUL_COUNTER") or 0)
    return numShadows--math.floor((numShadows)^(1/2))
end

---@param player EntityPlayer
function mod:addBlackSoulCounter(player, num)
    local data = mod:getEntityDataTable(player)
    local oldNum = mod:getBlackSpiritNum(player)
    data.BLACKSOUL_COUNTER = math.max(0, (data.BLACKSOUL_COUNTER or 0)+num)
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)

    local plrhash = GetPtrHash(player)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_EVIL_SHADOW)) do
        if(GetPtrHash(fam:ToFamiliar().Player)==plrhash) then
            local poof = Isaac.Spawn(1000,16,1,fam.Position,Vector.Zero,fam):ToEffect()
            poof.SpriteScale = Vector(1,1)*0.5
            poof.Color = Color(0.15,0.15,0.15,0.75)
        end
    end
end

---@param pickup EntityPickup
local function blackSoulInit(_, pickup)
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    if(pickup.SpawnerEntity and pickup.SpawnerEntity:ToPlayer()) then
        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    end

    --* TRAIL
    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, pickup.Position+pickup.PositionOffset+BLACK_SOUL_TRAIL_OFFSET, Vector.Zero, pickup):ToEffect()
    trail:FollowParent(pickup)
    trail.ParentOffset = pickup.PositionOffset+BLACK_SOUL_TRAIL_OFFSET
    trail.MinRadius = 0.15/2
    trail.SpriteScale = Vector(1,1)*pickup.SpriteScale.Y
    mod:setEntityData(trail, "BLACK_SOUL_PARENT", pickup)

    trail:Update()
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, blackSoulInit, mod.PICKUP_BLACK_SOUL)

---@param pickup EntityPickup
local function blackSoulUpdate(_, pickup)
    if(pickup.SpawnerEntity and pickup.SpawnerEntity:ToPlayer()) then
        pickup.Velocity = mod:lerp(pickup.Velocity, (pickup.SpawnerEntity.Position-pickup.Position):Resized(BLACK_SOUL_SPEED), 0.05)
    else
        pickup.Velocity = pickup.Velocity*0.95
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, blackSoulUpdate, mod.PICKUP_BLACK_SOUL)

local function blackSoulCollision(_, pickup, coll)
    if(coll.Type~=1) then return true end
    if(pickup:GetSprite():GetAnimation()~="Idle") then return true end
    if(not coll:ToPlayer():IsExtraAnimationFinished()) then return true end

    mod:addBlackSoulCounter(coll:ToPlayer(), 1)

    local smoke = Isaac.Spawn(1000,15,1,pickup.Position,Vector.Zero,pickup):ToEffect()
    smoke.Color = Color(0.25,0.25,0.25,1)
    smoke.SpriteOffset = Vector(0, -10)
    sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 0.5, 2, false, 0.85)

    pickup:Die()
    pickup:Remove()
    return true
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, blackSoulCollision, mod.PICKUP_BLACK_SOUL)

local function soulTrailRender(_, effect, offset)
    local pickupParent = mod:getEntityData(effect, "BLACK_SOUL_PARENT")
    if(not pickupParent) then return end

    if(pickupParent:Exists()) then
        effect.ParentOffset = pickupParent.PositionOffset+BLACK_SOUL_TRAIL_OFFSET
        effect.Color = Color(1,0,0,1,1,0,0,1,1,1,-100)
    else
        effect.Color = Color(1,0,0,0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, soulTrailRender, EffectVariant.SPRITE_TRAIL)

--! FAMILIAR LOGIC
---@param player EntityPlayer
local function evalSpirits(_, player, flag)
    local data = mod:getEntityDataTable(player)
    player:CheckFamiliar(mod.FAMILIAR_EVIL_SHADOW, mod:getBlackSpiritNum(player), player:GetCardRNG(mod.CONSUMABLE_MANTLE_DARK), nil)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalSpirits, CacheFlag.CACHE_FAMILIARS)

---@param fam EntityFamiliar
local function flushSpiritQueue(fam)
    local data = mod:getEntityDataTable(fam)
    for i=1, SPIRIT_FOLLOW_DELAY do data.BLACKSPIRIT_DELAYEDPOS[i] = data.BLACKSPIRIT_DELAY_TARGET.Position end
    fam.Position = data.BLACKSPIRIT_DELAY_TARGET.Position
    fam.Velocity = Vector.Zero
end

---@param fam EntityFamiliar
local function blackSpiritInit(_, fam)
    fam.State = 0
    fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    local data = mod:getEntityDataTable(fam)
    data.BLACKSPIRIT_DELAY_TARGET = fam.Player
    data.BLACKSPIRIT_IDX = 0
    data.BLACKSPIRIT_MAXIDX = 1
    data.BLACKSPIRIT_RANDOMFLICKEROFFSET = Random()
    data.BLACKSPIRIT_DELAYEDPOS = {}

    local otherSpirits = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_EVIL_SHADOW)
    if(#otherSpirits>0) then
        local lastSpirit, lastIdx
        local playerHash = GetPtrHash(data.BLACKSPIRIT_DELAY_TARGET)
        for _, ent in ipairs(otherSpirits) do
            ent = ent:ToFamiliar()
            if(ent.State==0 and GetPtrHash(ent.Player)==playerHash) then
                local eData = mod:getEntityDataTable(ent)
                if(eData.BLACKSPIRIT_IDX and (lastIdx==nil or (eData.BLACKSPIRIT_IDX or 0)>lastIdx)) then
                    lastIdx = (eData.BLACKSPIRIT_IDX or 0)
                    lastSpirit = ent
                end

                data.BLACKSPIRIT_MAXIDX = (data.BLACKSPIRIT_MAXIDX or 0)+1
                eData.BLACKSPIRIT_MAXIDX = (eData.BLACKSPIRIT_MAXIDX or 0)+1
            end
        end

        if(lastSpirit and lastIdx) then
            data.BLACKSPIRIT_IDX = lastIdx+1
            data.BLACKSPIRIT_DELAY_TARGET = lastSpirit
        end
    end

    flushSpiritQueue(fam)
    if(fam:HasEntityFlags(EntityFlag.FLAG_APPEAR)) then
        local smoke = Isaac.Spawn(1000,15,2,fam.Position,Vector.Zero,fam):ToEffect()
        smoke.Color = Color(0.25,0.25,0.25,1)
        fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
    fam:GetSprite():Play("Idle", true)
    fam.DepthOffset = -100
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, blackSpiritInit, mod.FAMILIAR_EVIL_SHADOW)

---@param fam EntityFamiliar
local function blackSpiritUpdate(_, fam)
    local data = mod:getEntityDataTable(fam)
    local sp = fam:GetSprite()
    local rng = fam:GetDropRNG()

    if(fam.State==0) then -- IDLE/FOLLOWING
        --print(data.BLACKSPIRIT_DELAY_TARGET:ToPlayer(), data.BLACKSPIRIT_DELAYEDPOS[1], fam.FrameCount)
        fam.Position = data.BLACKSPIRIT_DELAYEDPOS[1]
        fam.Velocity = mod:lerp(fam.Velocity, (data.BLACKSPIRIT_DELAYEDPOS[2]-data.BLACKSPIRIT_DELAYEDPOS[1]), 0.75)
        table.remove(data.BLACKSPIRIT_DELAYEDPOS, 1)
        data.BLACKSPIRIT_DELAYEDPOS[SPIRIT_FOLLOW_DELAY] = data.BLACKSPIRIT_DELAY_TARGET.Position

        local alpha = 1-(data.BLACKSPIRIT_IDX/data.BLACKSPIRIT_MAXIDX)*SPIRIT_MINALPHA
        if(rng:RandomInt(SPIRIT_FLICKER_FREQ)==0) then
            alpha = alpha*0.7
        end

        fam.CollisionDamage = SPIRIT_DMG+(mod:getEntityData(fam.Player, "BLACKSOUL_COUNTER") or 0)*SPIRIT_DMGPERSOUL
        fam.Color = Color(1,1,1,alpha)
    elseif(fam.State==1) then
        if(fam.Target==nil or (fam.Target and (fam.Target:IsDead() or not fam.Target:Exists()))) then
            local possibleTargets = Isaac.FindInRadius(fam.Position, SPIRIT_TARGETRADIUS, EntityPartition.ENEMY)
            local validTargets = {}
            for _, ent in ipairs(possibleTargets) do
                if(mod:isValidEnemy(ent)) then table.insert(validTargets, ent:ToNPC()) end
            end

            fam.Target = validTargets[rng:RandomInt(#validTargets)+1]
        end
        local dir = (fam.Target or fam.Player).Position-fam.Position+Vector.FromAngle(rng:RandomInt(360))*(rng:RandomFloat()*10)
        local fl = 1-dir:Length()/SPIRIT_CRAZYFASTERDIST

        local newVel = dir:Resized(mod:lerp(SPIRIT_CRAZYSPEED, SPIRIT_CRAZYFASTERSPEED, math.max(fl, 0))*(rng:RandomFloat()*0.1+0.9))
        --if(newVel:Length()>SPIRIT_CRAZYSPEED) then newVel = newVel:Resized(SPIRIT_CRAZYSPEED) end
        fam.Velocity = mod:lerp(fam.Velocity, newVel, 0.05)

        local alpha = 1-(data.BLACKSPIRIT_IDX/data.BLACKSPIRIT_MAXIDX)*SPIRIT_MINALPHA
        if(rng:RandomInt(SPIRIT_FLICKER_CRAZYFREQ)==0) then
            alpha = alpha*0.6
        end

        fam.CollisionDamage = SPIRIT_CRAZYDMG+(mod:getEntityData(fam.Player, "BLACKSOUL_COUNTER") or 0)*SPIRIT_DMGPERSOUL
        fam.Color = Color(1,1,1,alpha)
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, blackSpiritUpdate, mod.FAMILIAR_EVIL_SHADOW)

local function spiritNewRoom(_)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_EVIL_SHADOW)) do
        flushSpiritQueue(fam:ToFamiliar())
    end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local data = mod:getEntityDataTable(pl)

        if(data.BLACKSOUL_COUNTER and data.BLACKSOUL_COUNTER>0 and data.BLACKSOUL_GOTHIT and data.BLACKSOUL_GOTHIT>0) then
            local oldCount = data.BLACKSOUL_COUNTER
            pl:CheckFamiliar(mod.FAMILIAR_EVIL_SHADOW, 0, mod:generateRng())

            data.BLACKSOUL_COUNTER = math.max(0, oldCount-data.BLACKSOUL_GOTHIT)
            pl:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)

            data.BLACKSOUL_GOTHIT = 0

            pl:AnimateSad()
            local poof = Isaac.Spawn(1000,16,1,pl.Position,Vector.Zero,pl):ToEffect()
            poof.SpriteScale = Vector(1,1)*0.5
            poof.Color = Color(0.15,0.15,0.15,0.75)

            local poof2 = Isaac.Spawn(1000,16,2,pl.Position,Vector.Zero,pl):ToEffect()
            poof2.SpriteScale = Vector(1,1)*0.75
            poof2.Color = Color(0.15,0.15,0.15,0.75)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, spiritNewRoom)

---@param player Entity
local function soulDamage(_, player, _, flags, source)
    player = player:ToPlayer()
    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    mod:setEntityData(player, "BLACKSOUL_GOTHIT", mod:getEntityData(player, "BLACKSOUL_COUNTER"))
    local didEvilShadow = false
    local plrHash = GetPtrHash(player)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_EVIL_SHADOW)) do
        fam = fam:ToFamiliar()
        if(GetPtrHash(fam.Player)==plrHash and fam.State==0) then
            didEvilShadow = true
            fam.State = 1
            fam:GetSprite():Play("Crazy", true)

            local poof = Isaac.Spawn(1000,16,2,fam.Position,Vector.Zero,fam):ToEffect()
            poof.SpriteScale = Vector(1,1)*0.9
            poof.Color = Color(0.15,0.15,0.15,0.75)
        end
    end

    if(didEvilShadow) then
        sfx:Play(SoundEffect.SOUND_LAZARUS_FLIP_DEAD)
        Game():ShakeScreen(10)

        local poof = Isaac.Spawn(1000,16,1,player.Position,Vector.Zero,player):ToEffect()
        poof.SpriteScale = Vector(1,1)*0.75
        poof.Color = Color(0.15,0.15,0.15,0.75)

        local poof2 = Isaac.Spawn(1000,16,2,player.Position,Vector.Zero,player):ToEffect()
        poof2.SpriteScale = Vector(1,1)
        poof2.Color = Color(0.15,0.15,0.15,0.75)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, soulDamage, EntityType.ENTITY_PLAYER)