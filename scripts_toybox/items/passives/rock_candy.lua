---@param player EntityPlayer
local function postAddItem(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position,40)
    local mantle = Isaac.Spawn(5,ToyboxMod.PICKUP_RANDOM_SELECTOR,ToyboxMod.PICKUP_RANDOM_MANTLE,pos,Vector.Zero,player):ToPickup()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem, ToyboxMod.COLLECTIBLE_ROCK_CANDY)