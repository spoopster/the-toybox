local STATUPS_ON_PICKUP = 8
local STATDOWNS_PER_FLOOR = 1

local STAT_WEIGHT_SHIFT = 2

local STAT_BONUSES = {
    SPEED = 0.2,
    TEARS = 0.5,
    DAMAGE = 0.5,
    RANGE = 1,
    SHOTSPEED = 0.1,
    LUCK = 1,
}
local PICKER_TO_STAT = {"SPEED", "TEARS", "DAMAGE", "RANGE", "SHOTSPEED", "LUCK"}

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_DISSOCIATION)) then return end
    local statTable = ToyboxMod:getEntityData(player, "DISSOCIATION_STATS") or {}

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
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_DISSOCIATION)) then return end
    local statTable = ToyboxMod:getEntityData(pl, "DISSOCIATION_STATS") or {}

    if(stat==EvaluateStatStage.TEARS_UP) then
        return val+(statTable.TEARS or 0)
    elseif(stat==EvaluateStatStage.DAMAGE_UP) then
        return val+(statTable.DAMAGE or 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat)

---@param firstTime boolean
---@param pl EntityPlayer
local function addRandomStatUps(_, _, _, firstTime, _, _, pl)
    if(not firstTime) then return end

    local WEIGHT_PICKER = WeightedOutcomePicker()
    for i, _ in ipairs(PICKER_TO_STAT) do WEIGHT_PICKER:AddOutcomeFloat(i, 1, 100) end

    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_DISSOCIATION)
    local statTable = ToyboxMod:getEntityDataTable(pl).DISSOCIATION_STATS or {}
    for _=1, STATUPS_ON_PICKUP do
        local stat = WEIGHT_PICKER:PickOutcome(rng)
        local statkey = PICKER_TO_STAT[stat]
        statTable[statkey] = (statTable[statkey] or 0)+STAT_BONUSES[statkey]

        local chosenweight = 100
        for _, outcome in ipairs(WEIGHT_PICKER:GetOutcomes()) do
            if(outcome.Value==stat) then
                chosenweight = outcome.Weight
            end
        end
        WEIGHT_PICKER:RemoveOutcome(stat)
        WEIGHT_PICKER:AddOutcomeFloat(stat, 1/(100/chosenweight+STAT_WEIGHT_SHIFT))
    end
    pl:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addRandomStatUps, ToyboxMod.COLLECTIBLE_DISSOCIATION)

---@param player EntityPlayer
local function addRandomStatDowns(_, player)
    if(player.FrameCount==0) then return end
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_DISSOCIATION)) then return end
    
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)) then return end

    local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_DISSOCIATION)
    local statTable = ToyboxMod:getEntityDataTable(player).DISSOCIATION_STATS or {}
    for _=1, STATDOWNS_PER_FLOOR*player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_DISSOCIATION) do
        local stat = PICKER_TO_STAT[rng:RandomInt(1,#PICKER_TO_STAT)]
        statTable[stat] = (statTable[stat] or 0)-STAT_BONUSES[stat]
    end
    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, addRandomStatDowns)