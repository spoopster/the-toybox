local mod = ToyboxMod

local LUCK_UP = 1

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(mod.COLLECTIBLE.LUCKY_PEBBLES)) then return end

    local mult = pl:GetCollectibleNum(mod.COLLECTIBLE.LUCKY_PEBBLES)
    pl.Luck = pl.Luck+LUCK_UP*mult
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_LUCK)