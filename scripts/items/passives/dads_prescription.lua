local mod = MilcomMOD

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
    if(not player:HasCollectible(mod.COLLECTIBLE.DADS_PRESCRIPTION)) then return end
    local room = Game():GetRoom()
    if(not room:IsFirstVisit()) then return end
    if(nonSpecialRooms[room:GetType()]==0) then return end

    local pos = player.Position
    local num = player:GetCollectibleNum(mod.COLLECTIBLE.DADS_PRESCRIPTION)
    if(num%2~=0) then
        local pill = Isaac.Spawn(5,70,0,room:FindFreePickupSpawnPosition(pos,40),Vector.Zero,nil):ToPickup()
    end
    for _=1, math.floor(num/2) do
        local pill = Isaac.Spawn(5,70,0,room:FindFreePickupSpawnPosition(pos,40),Vector.Zero,nil):ToPickup()
        pill:Morph(5,70,pill.SubType|PillColor.PILL_GIANT_FLAG)
    end
    player:AnimateHappy()
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postPlayerNewRoom)