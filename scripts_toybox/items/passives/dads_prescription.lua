

local nonSpecialRooms = {
    [RoomType.ROOM_NULL]= true,
    [RoomType.ROOM_DEFAULT]= true,
    [RoomType.ROOM_TELEPORTER]= true,
    [RoomType.ROOM_GREED_EXIT]= true,
    [RoomType.ROOM_DUNGEON]= true,
    [RoomType.ROOM_BLUE]= true,
    [RoomType.ROOM_SECRET_EXIT]= true,
    [RoomType.ROOM_TELEPORTER_EXIT] = true,
}

local function postPlayerNewRoom(_, player)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_DADS_PRESCRIPTION)) then return end
    local room = ToyboxMod.GAME:GetRoom()
    if(not room:IsFirstVisit()) then return end
    if(not ToyboxMod:isAnyCustomSpecialRoom(ToyboxMod.GAME:GetLevel():GetCurrentRoomDesc()) and nonSpecialRooms[room:GetType()]) then return end

    for _=1, player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_DADS_PRESCRIPTION) do
        local pill = Isaac.Spawn(5,70,0,room:FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,nil):ToPickup()
    end
    player:AnimateHappy()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postPlayerNewRoom)