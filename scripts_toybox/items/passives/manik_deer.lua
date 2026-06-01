local STAT_BONUSES = {
    SPEED = 0.2,
    TEARS = 0.5,
    DAMAGE = 0.5,
    RANGE = 1,
    SHOTSPEED = 0.1,
    LUCK = 1,
}
local PICKER_TO_STAT = {"SPEED", "TEARS", "DAMAGE", "RANGE", "SHOTSPEED", "LUCK"}

local function TEARFLAG(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end

local TEARFLAGS_BLACKLIST = {
    [28] = true, -- sad bombs
    [29] = true, -- butt bombs
    [35] = true, -- glitter bombs
    [36] = true, -- scatter bombs
    [41] = true, -- black hp drop (serpents kiss)
    [42] = true, -- tractor beam
}
local MAX_FLAGS = TearFlags.TEAR_EFFECT_COUNT

local TEAR_FLAGS = {}
for i=0, MAX_FLAGS-1 do
    if(not TEARFLAGS_BLACKLIST[i]) then
        table.insert(TEAR_FLAGS, TEARFLAG(i))
    end
end

local TEAR_FLAG_CHANCE = 0.1

---@param pl EntityPlayer
---@param isInitFinished boolean
local function clearStatsAndFlags(_, pl, _, isInitFinished)
    if(pl.FrameCount==0) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_MANIK_DEER)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.MANIK_STATS = {}
    data.MANIK_FLAGS = {}

    pl:AddCacheFlags(CacheFlag.CACHE_ALL)
    pl:EvaluateItems()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, clearStatsAndFlags)

---@param pl EntityPlayer
local function addStatsAndFlags(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_MANIK_DEER)) then return end
    
    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_MANIK_DEER)
    local data = ToyboxMod:getEntityDataTable(pl)

    local stat = PICKER_TO_STAT[rng:RandomInt(1,#PICKER_TO_STAT)]
    data.MANIK_STATS = data.MANIK_STATS or {}
    data.MANIK_STATS[stat] = (data.MANIK_STATS[stat] or 0)+STAT_BONUSES[stat]

    local flag = TEAR_FLAGS[rng:RandomInt(1,#TEAR_FLAGS)]
    data.MANIK_FLAGS = data.MANIK_FLAGS or {}
    table.insert(data.MANIK_FLAGS, flag)

    pl:AddCacheFlags(CacheFlag.CACHE_ALL)
    pl:EvaluateItems()

    pl:AnimateHappy()
    
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR, addStatsAndFlags)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_MANIK_DEER)) then return end

    if(flag==CacheFlag.CACHE_TEARFLAG) then
        local flags = ToyboxMod:getEntityData(player, "MANIK_FLAGS") or {}

        local chance = TEAR_FLAG_CHANCE*player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_MANIK_DEER)
        for _, tearflag in ipairs(flags) do
            ToyboxMod:addTearFlag(
                player,
                tearflag,
                chance,
                ToyboxMod.COLLECTIBLE_MANIK_DEER
            )
        end
    else
        local statTable = ToyboxMod:getEntityData(player, "MANIK_STATS") or {}

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
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not (stat==EvaluateStatStage.TEARS_UP or stat==EvaluateStatStage.DAMAGE_UP)) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_MANIK_DEER)) then return end
    local statTable = ToyboxMod:getEntityData(pl, "MANIK_STATS") or {}

    if(stat==EvaluateStatStage.TEARS_UP) then
        return val+(statTable.TEARS or 0)
    elseif(stat==EvaluateStatStage.DAMAGE_UP) then
        return val+(statTable.DAMAGE or 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat)