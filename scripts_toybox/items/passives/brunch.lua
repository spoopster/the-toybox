local mod = ToyboxMod

local RANGE_UP = 2.5
local LUCK_UP = 1

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)) then return end

    if(flag==CacheFlag.CACHE_RANGE) then
        pl.TearRange = pl.TearRange+40*RANGE_UP*pl:GetCollectibleNum(mod.COLLECTIBLE.BRUNCH)
    elseif(flag==CacheFlag.CACHE_LUCK) then
        pl.Luck = pl.Luck+LUCK_UP*pl:GetCollectibleNum(mod.COLLECTIBLE.BRUNCH)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)