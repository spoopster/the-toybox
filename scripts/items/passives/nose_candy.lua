local mod = ToyboxMod

local ENUM_NUMTOSTAT = {"FIREDELAY", "DAMAGE", "RANGE", "SHOTSPEED", "LUCK"}
local ENUM_STATPICKER = WeightedOutcomePicker()
ENUM_STATPICKER:AddOutcomeFloat(1, 0.9, 100)
ENUM_STATPICKER:AddOutcomeFloat(2, 0.9, 100)
ENUM_STATPICKER:AddOutcomeFloat(3, 1.0, 100)
ENUM_STATPICKER:AddOutcomeFloat(4, 1.0, 100)
ENUM_STATPICKER:AddOutcomeFloat(5, 1.0, 100)

local ENUM_LEVEL_SPEEDBONUS = 0.2
local ENUM_LEVEL_STATUPBONUS = 0.1
local ENUM_LEVEL_STATDOWNBONUS = -0.05

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE.NOSE_CANDY)) then return end

    local statTable = mod:getEntityData(player, "NOSE_CANDY_STATBONUSES")

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+statTable.SPEED
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(player, statTable.FIREDELAY)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*(1+statTable.DAMAGE/2)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+statTable.RANGE*40
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+statTable.SHOTSPEED
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+statTable.LUCK
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function addNoseCandyBonuses(_, player)
    if(player.FrameCount==0) then return end
    if(not player:HasCollectible(mod.COLLECTIBLE.NOSE_CANDY)) then return end

    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE.NOSE_CANDY)
    local statTable = mod:getEntityDataTable(player).NOSE_CANDY_STATBONUSES
    local num = player:GetCollectibleNum(mod.COLLECTIBLE.NOSE_CANDY)

    local statToUp = ENUM_NUMTOSTAT[ENUM_STATPICKER:PickOutcome(rng)]
    local statToDown = ENUM_NUMTOSTAT[ENUM_STATPICKER:PickOutcome(rng)]

    statTable[statToUp] = statTable[statToUp]+ENUM_LEVEL_STATUPBONUS*num
    statTable[statToDown] = statTable[statToDown]+ENUM_LEVEL_STATDOWNBONUS*num

    if(player.MoveSpeed+ENUM_LEVEL_SPEEDBONUS*num>2) then
        local speedOverflow = player.MoveSpeed+ENUM_LEVEL_SPEEDBONUS*num-2

        statTable.SPEED = statTable.SPEED + ENUM_LEVEL_SPEEDBONUS*num-speedOverflow
        local overflowBonusStat = ENUM_NUMTOSTAT[ENUM_STATPICKER:PickOutcome(rng)]
        statTable[overflowBonusStat] = statTable[overflowBonusStat]+speedOverflow
    else
        statTable.SPEED = statTable.SPEED + ENUM_LEVEL_SPEEDBONUS*num
    end

    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, addNoseCandyBonuses)