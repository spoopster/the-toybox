---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_MEN_EAGLE)) then return end

    player.CanFly = true
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FLYING)

---@param pickup EntityPickup
local function _1984(_, pickup)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_MEN_EAGLE)) then return end

    pickup.OptionsPickupIndex = 0
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, _1984)

---@param pickup EntityPickup
local function _1985(_, pickup)
    if(pickup.FrameCount>1) then return end
    if(pickup.OptionsPickupIndex==0) then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_MEN_EAGLE)) then return end

    pickup.OptionsPickupIndex = 0
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, _1985)