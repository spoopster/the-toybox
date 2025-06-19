
--* Spawns Gold Key and Gold Bomb

---@param player EntityPlayer
local function postAddItem(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    if(not ToyboxMod:playerHasLimitBreak(player)) then return end
    local room = Game():GetRoom()

    local goldKey = Isaac.Spawn(5,30,2,room:FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,player):ToPickup()
    local goldKey = Isaac.Spawn(5,40,4,room:FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,player):ToPickup()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem, CollectibleType.COLLECTIBLE_BOX)