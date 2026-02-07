function ToyboxMod:addRandomStat(pl, stat, amount)
    local statTable = ToyboxMod:getEntityData(pl, "RANDOM_STAT_BONUSES") or {}
    statTable[stat] = (statTable[stat] or 0)+amount
end

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    local statTable = ToyboxMod:getEntityData(player, "RANDOM_STAT_BONUSES") or {}

    if(flag==CacheFlag.CACHE_SPEED) then
        statTable.SPEED = 0
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        statTable.TEARS = 0
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        statTable.DAMAGE = 0
    elseif(flag==CacheFlag.CACHE_RANGE) then
        statTable.RANGE = 0
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        statTable.SHOTSPEED = 0
    elseif(flag==CacheFlag.CACHE_LUCK) then
        statTable.LUCK = 0
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.IMPORTANT, evalCache)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    local statTable = ToyboxMod:getEntityData(player, "RANDOM_STAT_BONUSES") or {}

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
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 1, evalCache)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not (stat==EvaluateStatStage.TEARS_UP or stat==EvaluateStatStage.DAMAGE_UP)) then return end
    local statTable = ToyboxMod:getEntityData(pl, "RANDOM_STAT_BONUSES") or {}

    if(stat==EvaluateStatStage.TEARS_UP) then
        return val+(statTable.TEARS or 0)
    elseif(stat==EvaluateStatStage.DAMAGE_UP) then
        return val+(statTable.DAMAGE or 0)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_STAT, 1, evalStat)