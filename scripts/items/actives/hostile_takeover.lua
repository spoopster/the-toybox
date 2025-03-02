local mod = MilcomMOD
local sfx = SFXManager()

local BASEHP = 10
local HPSCALE_EXPO = 0.7

local BASE_CHARGES_GIVEN = 0.15
local BASE_STATSTIMER_INCREASE = 90

local STAT_DECREASE_TIMER = 30*10
local STAT_DECREASE_FREQ = 15

local PUDDLE_CONSUME_FRAMES = 15

local STACK_BONUS = 0.5
local SPEED_UP = 0.2
local DMG_UP = 2
local TEARS_UP = 1
--local RANGE_UP = 1
--local SHOTSPEED_UP = 0.1
--local LUCK_UP = 1

local function firstHostileTakeoverPlayer()
    for i=0,Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE.HOSTILE_TAKEOVER)) then
            return pl, pl:GetEffects():GetCollectibleEffectNum(mod.COLLECTIBLE.HOSTILE_TAKEOVER)
        end
    end
    return nil
end
local function spawnTarPuddle(pos, size, pl)
    size = size or 1
    pl = pl or firstHostileTakeoverPlayer()

    local puddle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, pos, Vector.Zero, pl):ToEffect()
    local visualSize = mod:clamp(size^0.75, 0.75, 2)
    puddle.SpriteScale = Vector(1,1)*visualSize

    mod:setEntityData(puddle, "TAKEOVER_TAR_PUDDLE", true)
    mod:setEntityData(puddle, "TAKEOVER_PUDDLE_SCALE", visualSize)
    mod:setEntityData(puddle, "TAKEOVER_PUDDLE_CONSUMPTION_FRAMES", 0)
    mod:setEntityData(puddle, "TAKEOVER_PUDDLE_SIZE", size)

    puddle.Timeout = -1

    return puddle
end

---@param pl EntityPlayer
local function activateHostileTakeover(_, _, rng, pl, flags, slot, vdata)
    mod:setEntityData(pl, "HOSTILETAKEOVER_STAT_TIMER", STAT_DECREASE_TIMER)
    pl:AddCacheFlags(CacheFlag.CACHE_ALL, true)

    if(not pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE.HOSTILE_TAKEOVER)) then
        mod.HiddenItemManager:AddForRoom(pl, CollectibleType.COLLECTIBLE_4_5_VOLT, nil, 1, "TOYBOX")
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, activateHostileTakeover, mod.COLLECTIBLE.HOSTILE_TAKEOVER)

---@param pl EntityPlayer
local function aa(_, pl)
    if(pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE.HOSTILE_TAKEOVER)) then
        pl:GetEffects():RemoveCollectibleEffect(mod.COLLECTIBLE.HOSTILE_TAKEOVER, -1)
        mod:setEntityData(pl, "HOSTILETAKEOVER_STAT_TIMER", 0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, aa)

---@param pl EntityPlayer
local function postPeffectUpdate(_, pl)
    if(not (pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE.HOSTILE_TAKEOVER))) then return end
    local data = mod:getEntityDataTable(pl)
    data.HOSTILETAKEOVER_STAT_TIMER = (data.HOSTILETAKEOVER_STAT_TIMER or 0)-1

    if(data.HOSTILETAKEOVER_STAT_TIMER>=0 and data.HOSTILETAKEOVER_STAT_TIMER%STAT_DECREASE_FREQ==0) then
        pl:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end
    data.HOSTILETAKEOVER_STAT_TIMER = math.max(data.HOSTILETAKEOVER_STAT_TIMER, 0)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not (pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE.HOSTILE_TAKEOVER))) then return end
    local timer = (mod:getEntityData(pl, "HOSTILETAKEOVER_STAT_TIMER") or 0)
    if(timer<=0) then return end

    local numEffects = pl:GetEffects():GetCollectibleEffectNum(mod.COLLECTIBLE.HOSTILE_TAKEOVER)
    local statFrac = timer/STAT_DECREASE_TIMER*(1+(numEffects-1)*STACK_BONUS)

    if(flag==CacheFlag.CACHE_SPEED) then
        pl.MoveSpeed = pl.MoveSpeed+statFrac*SPEED_UP
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(pl, statFrac*TEARS_UP)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(pl, statFrac*DMG_UP)
    --elseif(flag==CacheFlag.CACHE_RANGE) then
    --    pl.TearRange = pl.TearRange+statFrac*RANGE_UP*40
    --elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
    --    pl.ShotSpeed = pl.ShotSpeed+statFrac*SHOTSPEED_UP
    --elseif(flag==CacheFlag.CACHE_LUCK) then
    --    pl.Luck = pl.Luck+statFrac*LUCK_UP
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)


---@param npc EntityNPC
local function spawnDeathPuddle(_, npc)
    local pl = firstHostileTakeoverPlayer()
    if(not pl) then return end

    local hpSize = (npc.MaxHitPoints/BASEHP)^HPSCALE_EXPO
    spawnTarPuddle(npc.Position, hpSize, pl)
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, spawnDeathPuddle)

---@param effect EntityEffect
local function consumeTarPuddle(_, effect)
    local data = mod:getEntityDataTable(effect)
    if(not data.TAKEOVER_TAR_PUDDLE) then return end

    local consumerPl = nil
    local currentScale = (data.TAKEOVER_PUDDLE_SCALE or 1)*(1-(data.TAKEOVER_PUDDLE_CONSUMPTION_FRAMES or 0)/PUDDLE_CONSUME_FRAMES)
    for _, pl in ipairs(Isaac.FindInRadius(effect.Position, math.max(40, currentScale*25), EntityPartition.PLAYER)) do
        pl = pl:ToPlayer()
        if(pl:GetEffects():HasCollectibleEffect(mod.COLLECTIBLE.HOSTILE_TAKEOVER)) then
            consumerPl = pl
            break
        end
    end

    effect.SpriteScale = Vector(1,1)*(data.TAKEOVER_PUDDLE_SCALE or 1)*(0.1+0.9*(1-(data.TAKEOVER_PUDDLE_CONSUMPTION_FRAMES or 0)/PUDDLE_CONSUME_FRAMES))

    if(not consumerPl) then return end
    local plData = mod:getEntityDataTable(consumerPl)
    local mul = consumerPl:GetEffects():GetCollectibleEffectNum(mod.COLLECTIBLE.HOSTILE_TAKEOVER)
    local scaleMul = (data.TAKEOVER_PUDDLE_SIZE or 1)/PUDDLE_CONSUME_FRAMES

    for _, slot in pairs(ActiveSlot) do
        local desc = consumerPl:GetActiveItemDesc(slot)
        if(desc and desc.Item==mod.COLLECTIBLE.HOSTILE_TAKEOVER) then
            desc.PartialCharge = desc.PartialCharge+BASE_CHARGES_GIVEN*scaleMul*mul
        end
    end

    local oldTime = (plData.HOSTILETAKEOVER_STAT_TIMER or 0)

    plData.HOSTILETAKEOVER_STAT_TIMER = (plData.HOSTILETAKEOVER_STAT_TIMER or 0)+math.floor(BASE_STATSTIMER_INCREASE*scaleMul+1)
    plData.HOSTILETAKEOVER_STAT_TIMER = math.min(plData.HOSTILETAKEOVER_STAT_TIMER, STAT_DECREASE_TIMER)

    if(oldTime//STAT_DECREASE_FREQ~=plData.HOSTILETAKEOVER_STAT_TIMER//STAT_DECREASE_FREQ) then
        consumerPl:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end

    sfx:Play(SoundEffect.SOUND_POOPITEM_HOLD, 0.75, 4, false, 0.5+0.5*data.TAKEOVER_PUDDLE_CONSUMPTION_FRAMES/PUDDLE_CONSUME_FRAMES)
    data.TAKEOVER_PUDDLE_CONSUMPTION_FRAMES = (data.TAKEOVER_PUDDLE_CONSUMPTION_FRAMES or 0)+1

    if(data.TAKEOVER_PUDDLE_CONSUMPTION_FRAMES>=PUDDLE_CONSUME_FRAMES) then
        local splat = Isaac.Spawn(1000,2,0,effect.Position,Vector.Zero,nil):ToEffect()
        splat.Color = Color(0,0,0,0.75)
        splat.SpriteScale = Vector(1,1)*0.75*(data.TAKEOVER_PUDDLE_SCALE or 1)
        sfx:Play(SoundEffect.SOUND_POISON_HURT)
        --sfx:Stop(SoundEffect.SOUND_POISON_WARN)

        effect:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, consumeTarPuddle, EffectVariant.PLAYER_CREEP_BLACK)