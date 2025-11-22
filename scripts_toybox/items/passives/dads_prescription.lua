

local nonSpecialRooms = {
    [RoomType.ROOM_NULL] = 0,
    [RoomType.ROOM_DEFAULT] = 0,
    [RoomType.ROOM_TELEPORTER] = 0,
    [RoomType.ROOM_GREED_EXIT] = 0,
    [RoomType.ROOM_DUNGEON] = 0,
    [RoomType.ROOM_BLUE] = 0,
    [RoomType.ROOM_SECRET_EXIT] = 0,
    [RoomType.ROOM_TELEPORTER_EXIT] = 0,
}

local function postPlayerNewRoom(_, player)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_DADS_PRESCRIPTION)) then return end
    local room = Game():GetRoom()
    if(not room:IsFirstVisit()) then return end
    if(nonSpecialRooms[room:GetType()]==0) then return end

    for _=1, player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_DADS_PRESCRIPTION) do
        local pill = Isaac.Spawn(5,70,0,room:FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,nil):ToPickup()
    end
    player:AnimateHappy()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postPlayerNewRoom)