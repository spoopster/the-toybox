local mod = ToyboxMod

local DMG_UP = 1
local TEARS_UP = 0.5

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)) then return end

    if(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(pl, DMG_UP*pl:GetCollectibleNum(mod.COLLECTIBLE.TOAST))
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(pl, TEARS_UP*pl:GetCollectibleNum(mod.COLLECTIBLE.TOAST))
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)