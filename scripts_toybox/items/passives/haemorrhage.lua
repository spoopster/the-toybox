local mod = ToyboxMod

local BONEHEART_ADD = 1

local INTENSITY_DURATION = 17*18
local TEARS_MULT_MAX = 5

---@param player EntityPlayer
local function addHaemorrhage(_, item, _, firstTime, _, _, player)
    if(firstTime~=true) then return end

    player:AddBoneHearts(BONEHEART_ADD)
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addHaemorrhage, mod.COLLECTIBLE.HEMORRHAGE)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE.HEMORRHAGE)) then return end

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        local lerpFloat = (mod:getEntityData(player, "HAEMORRHAGE_COUNTDOWN") or 0)/INTENSITY_DURATION

        player.MaxFireDelay = mod:toFireDelay(mod:toTps(player.MaxFireDelay)*mod:lerp(1,TEARS_MULT_MAX, lerpFloat))
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
local function hemorrhageEffectCheck(_, pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE.HEMORRHAGE)) then return end

    local data = mod:getEntityDataTable(pl)
    data.HAEMORRHAGE_COUNTDOWN = (data.HAEMORRHAGE_COUNTDOWN or 0)

    if(data.HAEMORRHAGE_COUNTDOWN>0) then
        data.HAEMORRHAGE_COUNTDOWN = data.HAEMORRHAGE_COUNTDOWN-1

        local res = (math.sqrt(1+4*(INTENSITY_DURATION-data.HAEMORRHAGE_COUNTDOWN))-1)/2
        if(math.abs(math.floor(res)-res)<0.01) then

            print(INTENSITY_DURATION-data.HAEMORRHAGE_COUNTDOWN)
            pl:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, hemorrhageEffectCheck)

---@param player Entity
local function increaseIntensity(_, player, _, flags, source)
    if(not player:ToPlayer():HasCollectible(mod.COLLECTIBLE.HEMORRHAGE)) then return end

    mod:setEntityData(player:ToPlayer(), "HAEMORRHAGE_COUNTDOWN", INTENSITY_DURATION)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, increaseIntensity, EntityType.ENTITY_PLAYER)