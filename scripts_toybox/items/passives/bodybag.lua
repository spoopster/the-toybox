local NUM_HEARTS = 6

---@param pl EntityPlayer
---@param firstTime boolean
local function addBrunch(_, _, _, firstTime, _, _, pl)
    if(not firstTime) then return end

    local room = Game():GetRoom()
    for i=1, NUM_HEARTS do
        local heart = Isaac.Spawn(5,10,0,room:FindFreePickupSpawnPosition(pl.Position,40),Vector.Zero,nil):ToPickup()
        heart:SetDropDelay(2*(i-1))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addBrunch, ToyboxMod.COLLECTIBLE_BODYBAG)