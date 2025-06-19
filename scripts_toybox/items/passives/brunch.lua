

local BINGE_RANGE_UP = 2.5
local BINGE_LUCK_UP = 1

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)) then return end

    if(flag==CacheFlag.CACHE_RANGE) then
        pl.TearRange = pl.TearRange+40*BINGE_RANGE_UP*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_BRUNCH)
    elseif(flag==CacheFlag.CACHE_LUCK) then
        pl.Luck = pl.Luck+BINGE_LUCK_UP*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_BRUNCH)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)