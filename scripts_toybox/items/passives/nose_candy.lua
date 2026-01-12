
local STAT_BONUSES = {
    SPEED = 0.2,
    TEARS = 0.5,
    DAMAGE = 1,
    RANGE = 1,
    SHOTSPEED = 0.2,
    LUCK = 1,
}
local PICKER_TO_STAT = {"TEARS", "DAMAGE", "RANGE", "SHOTSPEED", "LUCK"}
local STATPICKER = WeightedOutcomePicker()
STATPICKER:AddOutcomeFloat(1, 0.9, 100)
STATPICKER:AddOutcomeFloat(2, 0.9, 100)
STATPICKER:AddOutcomeFloat(3, 1.0, 100)
STATPICKER:AddOutcomeFloat(4, 1.0, 100)
STATPICKER:AddOutcomeFloat(5, 1.0, 100)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_NOSE_CANDY)) then return end

    local statTable = ToyboxMod:getEntityData(player, "NOSE_CANDY_STATBONUSES") or {}

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+(statTable.SPEED or 0)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+(statTable.RANGE or 0)*40
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+(statTable.SHOTSPEED or 0)
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+(statTable.LUCK or 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not (stat==EvaluateStatStage.TEARS_UP or stat==EvaluateStatStage.DAMAGE_UP)) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_NOSE_CANDY)) then return end

    local statTable = ToyboxMod:getEntityData(pl, "NOSE_CANDY_STATBONUSES") or {}

    if(stat==EvaluateStatStage.TEARS_UP) then
        return val+(statTable.TEARS or 0)
    elseif(stat==EvaluateStatStage.DAMAGE_UP) then
        return val+(statTable.DAMAGE or 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat)

---@param player EntityPlayer
local function addNoseCandyBonuses(_, player)
    if(player.FrameCount==0) then return end
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_NOSE_CANDY)) then return end

    local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_NOSE_CANDY)
    local statTable = ToyboxMod:getEntityDataTable(player).NOSE_CANDY_STATBONUSES
    local num = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_NOSE_CANDY)
    num = 1+(num-1)/2

    local statToUp = PICKER_TO_STAT[STATPICKER:PickOutcome(rng)]
    local statToDown = PICKER_TO_STAT[STATPICKER:PickOutcome(rng)]

    statTable[statToUp] = statTable[statToUp]+num*STAT_BONUSES[statToUp]
    statTable[statToDown] = statTable[statToDown]-num*STAT_BONUSES[statToDown]

    statTable.SPEED = statTable.SPEED + STAT_BONUSES.SPEED*num

    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, addNoseCandyBonuses)