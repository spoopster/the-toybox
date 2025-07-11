local bossPools = {
    [ItemPoolType.POOL_BOSS] = true,
    [ItemPoolType.POOL_GREED_BOSS] = true,
}

---@param item CollectibleType
---@param firstTime boolean
---@param pl EntityPlayer
local function addCollectibleHp(_, item, _, firstTime, _, _, pl)
    if(not firstTime) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_FOOD_STAMPS)) then return end
    if(item==ToyboxMod.COLLECTIBLE_FOOD_STAMPS and pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_FOOD_STAMPS)==1) then return end

    pl:AddMaxHearts(2)
    pl:AddHearts(2)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addCollectibleHp)