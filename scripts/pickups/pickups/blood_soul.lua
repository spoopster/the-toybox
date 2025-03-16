local mod = ToyboxMod
local sfx = SFXManager()

local BLOOD_SOUL_TRAIL_OFFSET = Vector(0,-25)
local BLOOD_SOUL_SPEED = 35

local BLOOD_UPDATE_FREQ = 15
local BLOOD_FADE_TIME = 60*15 -- 15 sec
local BLOOD_DMG_UP = 0.4
local BLOOD_TEARS_UP = 0.4

function mod:addBloodSoulCounter(player, num)
    local data = mod:getEntityDataTable(player)
    data.BLOODSOUL_COUNTER = math.max(0, (data.BLOODSOUL_COUNTER or 0)+num*BLOOD_FADE_TIME)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)
end

---@param pickup EntityPickup
local function bloodSoulInit(_, pickup)
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    if(pickup.SpawnerEntity and pickup.SpawnerEntity:ToPlayer()) then
        pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    end

    --* TRAIL
    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, pickup.Position+pickup.PositionOffset+BLOOD_SOUL_TRAIL_OFFSET, Vector.Zero, pickup):ToEffect()
    trail:FollowParent(pickup)
    trail.ParentOffset = pickup.PositionOffset+BLOOD_SOUL_TRAIL_OFFSET
    trail.MinRadius = 0.15/2
    trail.SpriteScale = Vector(1,1)*pickup.SpriteScale.Y
    mod:setEntityData(trail, "BLOOD_SOUL_PARENT", pickup)

    trail:Update()
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, bloodSoulInit, mod.PICKUP_VARIANT.BLOOD_SOUL)

---@param pickup EntityPickup
local function bloodSoulUpdate(_, pickup)
    if(pickup.SpawnerEntity and pickup.SpawnerEntity:ToPlayer()) then
        pickup.Velocity = mod:lerp(pickup.Velocity, (pickup.SpawnerEntity.Position-pickup.Position):Resized(BLOOD_SOUL_SPEED), 0.05)
    else
        pickup.Velocity = pickup.Velocity*0.95
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, bloodSoulUpdate, mod.PICKUP_VARIANT.BLOOD_SOUL)

local function bloodSoulCollision(_, pickup, coll)
    if(coll.Type~=1) then return true end
    if(pickup:GetSprite():GetAnimation()~="Idle") then return true end
    if(not coll:ToPlayer():IsExtraAnimationFinished()) then return true end

    mod:addBloodSoulCounter(coll:ToPlayer(), 1)

    local smoke = Isaac.Spawn(1000,15,1,pickup.Position,Vector.Zero,pickup):ToEffect()
    smoke.Color = Color(1,0.5,0.5,1,0.5)
    smoke.SpriteOffset = Vector(0, -10)
    sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 0.5, 2, false, 0.85)

    pickup:Die()
    pickup:Remove()
    return true
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, bloodSoulCollision, mod.PICKUP_VARIANT.BLOOD_SOUL)

local function soulTrailRender(_, effect, offset)
    local pickupParent = mod:getEntityData(effect, "BLOOD_SOUL_PARENT")
    if(not pickupParent) then return end

    if(pickupParent:Exists()) then
        effect.ParentOffset = pickupParent.PositionOffset+BLOOD_SOUL_TRAIL_OFFSET
        effect.Color = Color(1,0,0,1,1,0,0,1,1,1,-100)
    else
        effect.Color = Color(1,0,0,0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, soulTrailRender, EffectVariant.SPRITE_TRAIL)

--! STAT FUNCTIONALITY
---@param player EntityPlayer
local function evalBlood(_, player, flag)
    local data = mod:getEntityDataTable(player)
    local boostIntensity = (data.BLOODSOUL_COUNTER or 0)/BLOOD_FADE_TIME
    
    if(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(player, boostIntensity*BLOOD_DMG_UP)
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(player, boostIntensity*BLOOD_TEARS_UP)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalBlood)

---@param pl EntityPlayer
local function decreaseBloodCounter(_, pl)
    local data = mod:getEntityDataTable(pl)
    if(data.BLOODSOUL_COUNTER and data.BLOODSOUL_COUNTER>0) then
        data.BLOODSOUL_COUNTER = data.BLOODSOUL_COUNTER-1
        if(data.BLOODSOUL_COUNTER%BLOOD_UPDATE_FREQ) then
            pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, decreaseBloodCounter)