

local BONEHEART_ADD = 2

local INTENSITY_DURATION = 5*60
local INTENSITY_UPDATE_FREQ = 30

local TEARS_MULT_MAX = 5

---@param player EntityPlayer
local function addHaemorrhage(_, item, _, firstTime, _, _, player)
    if(firstTime~=true) then return end

    player:AddBoneHearts(BONEHEART_ADD)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addHaemorrhage, ToyboxMod.COLLECTIBLE_HEMORRHAGE)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_HEMORRHAGE)) then return end

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        local lerpFloat = (ToyboxMod:getEntityData(player, "HAEMORRHAGE_COUNTDOWN") or 0)/INTENSITY_DURATION

        player.MaxFireDelay = ToyboxMod:toFireDelay(ToyboxMod:toTps(player.MaxFireDelay)*ToyboxMod:lerp(1,TEARS_MULT_MAX, lerpFloat))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
local function hemorrhageEffectCheck(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_HEMORRHAGE)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.HAEMORRHAGE_COUNTDOWN = (data.HAEMORRHAGE_COUNTDOWN or 0)

    if(data.HAEMORRHAGE_COUNTDOWN>0) then
        data.HAEMORRHAGE_COUNTDOWN = data.HAEMORRHAGE_COUNTDOWN-1

        if(data.HAEMORRHAGE_COUNTDOWN%INTENSITY_UPDATE_FREQ==0) then

            --print(INTENSITY_DURATION-data.HAEMORRHAGE_COUNTDOWN)
            pl:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, hemorrhageEffectCheck)

---@param ent Entity
local function increaseIntensity(_, ent, _, flags, source)
    local pl = ent:ToPlayer()
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_HEMORRHAGE))) then return end

    ToyboxMod:setEntityData(pl, "HAEMORRHAGE_COUNTDOWN", INTENSITY_DURATION)
    pl:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, increaseIntensity, EntityType.ENTITY_PLAYER)