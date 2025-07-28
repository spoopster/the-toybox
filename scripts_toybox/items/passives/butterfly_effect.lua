local DMG_EXPO = 1.25

---@param pl EntityPlayer
---@param flags CacheFlag
local function evalCache(_, pl, flags)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_BUTTERFLY_EFFECT)) then return end

    pl.Damage = pl.Damage^(DMG_EXPO^pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_BUTTERFLY_EFFECT))
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, evalCache, CacheFlag.CACHE_DAMAGE)