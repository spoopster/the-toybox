local mod = ToyboxMod

---@param item CollectibleType
---@param firstTime boolean
---@param pl EntityPlayer
local function addCollectibleHp(_, item, _, firstTime, _, _, pl)
    if(not firstTime) then return end
    if(not pl:HasCollectible(mod.COLLECTIBLE.FOOD_STAMPS)) then return end
    if(item==mod.COLLECTIBLE.FOOD_STAMPS and pl:GetCollectibleNum(mod.COLLECTIBLE.FOOD_STAMPS)==1) then return end

    pl:AddMaxHearts(2)
    pl:AddHearts(2)
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addCollectibleHp)