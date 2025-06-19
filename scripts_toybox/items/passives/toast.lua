

local BINGE_DMG_UP = 1
local BINGE_TEARS_UP = 0.5

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)) then return end

    if(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(pl, BINGE_DMG_UP*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_TOAST))
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(pl, BINGE_TEARS_UP*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_TOAST))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)