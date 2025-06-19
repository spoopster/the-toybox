

local LUCK_UP = 1

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_LUCKY_PEBBLES)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_LUCKY_PEBBLES)
    pl.Luck = pl.Luck+LUCK_UP*mult
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_LUCK)