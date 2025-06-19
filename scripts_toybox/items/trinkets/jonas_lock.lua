

local STAT_MULTS = 0.5
local HORSE_MULT = 2
local GOLD_MULT = 0.2
local PILL_STAT_UPS = {
    SPEED = 0.15,
    FIREDELAY = 0.35,
    DAMAGE = 0.45,
    RANGE = 1.25,
    SHOTSPEED = 0.15,
    LUCK = 0.5,
}
local ENUM_NUMTOSTAT = {"SPEED", "FIREDELAY", "DAMAGE", "RANGE", "SHOTSPEED", "LUCK"}
local ENUM_STATPICKER = WeightedOutcomePicker()
ENUM_STATPICKER:AddOutcomeFloat(1, 1, 100)
ENUM_STATPICKER:AddOutcomeFloat(2, 0.8, 100)
ENUM_STATPICKER:AddOutcomeFloat(3, 0.8, 100)
ENUM_STATPICKER:AddOutcomeFloat(4, 1.0, 100)
ENUM_STATPICKER:AddOutcomeFloat(5, 0.8, 100)
ENUM_STATPICKER:AddOutcomeFloat(6, 1.0, 100)

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    if(not player:HasTrinket(ToyboxMod.TRINKET_JONAS_LOCK)) then return end
    local data = ToyboxMod:getEntityDataTable(player)
    local rng = player:GetPillRNG(effect)

    local stat = ENUM_NUMTOSTAT[ENUM_STATPICKER:PickOutcome(rng)]
    data.JONAS_LOCK_STATBONUSES = data.JONAS_LOCK_STATBONUSES or {SPEED=0,FIREDELAY=0,DAMAGE=0,RANGE=0,SHOTSPEED=0,LUCK=0}

    local valToAdd = player:GetTrinketMultiplier(ToyboxMod.TRINKET_JONAS_LOCK)
    if(color & PillColor.PILL_GIANT_FLAG ~= 0) then valToAdd = valToAdd*HORSE_MULT end
    if(color & (~PillColor.PILL_GIANT_FLAG) == PillColor.PILL_GOLD) then valToAdd = valToAdd*GOLD_MULT end

    data.JONAS_LOCK_STATBONUSES[stat] = data.JONAS_LOCK_STATBONUSES[stat]+PILL_STAT_UPS[stat]*valToAdd
    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasTrinket(ToyboxMod.TRINKET_JONAS_LOCK)) then return end

    local statTable = ToyboxMod:getEntityData(player, "JONAS_LOCK_STATBONUSES")

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+statTable.SPEED*STAT_MULTS
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, statTable.FIREDELAY*STAT_MULTS)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(player, statTable.DAMAGE*STAT_MULTS)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+statTable.RANGE*40*STAT_MULTS
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+statTable.SHOTSPEED*STAT_MULTS
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+statTable.LUCK*STAT_MULTS
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)