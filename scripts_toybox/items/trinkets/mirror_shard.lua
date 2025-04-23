local mod = ToyboxMod

local BASE_LUCK = -13
local LUCK_INCR = 1

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasTrinket(mod.TRINKET.MIRROR_SHARD)) then return end

    pl.Luck = pl.Luck+BASE_LUCK+(mod:getEntityData(pl, "MIRROR_SHARD_COUNTER") or 0)*LUCK_INCR
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_LUCK)

---@param pl Entity
local function incrementLuck(_, pl)
    pl = pl:ToPlayer()
    if(not (pl and pl:HasTrinket(mod.TRINKET.MIRROR_SHARD))) then return end

    local mult = pl:GetTrinketMultiplier(mod.TRINKET.MIRROR_SHARD)
    local toAdd = 1+(mult-1)/2

    local data = mod:getEntityDataTable(pl)
    data.MIRROR_SHARD_COUNTER = (data.MIRROR_SHARD_COUNTER or 0)+toAdd
    pl:AddCacheFlags(CacheFlag.CACHE_LUCK, true)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, incrementLuck, EntityType.ENTITY_PLAYER)