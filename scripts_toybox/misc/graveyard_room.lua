local function addNewBossRoom(_)
    local level = Game():GetLevel()
    local newBossRoom = RoomConfigHolder.GetRandomRoom(Random(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_TELEPORTER, nil, nil, nil, nil, nil, nil, 100)
    local possibleRooms = level:FindValidRoomPlacementLocations(newBossRoom, -1, false, false)

    local finalRoom
    while(#possibleRooms>0 and not finalRoom) do
        local idx = Isaac.GetPlayer():GetCollectibleRNG(1):RandomInt(#possibleRooms)+1
    
        finalRoom = level:TryPlaceRoom(newBossRoom, possibleRooms[idx], -1, 0, true, true, false)
        table.remove(possibleRooms, idx)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, addNewBossRoom)

local function gggg(_)
    local iconssprite = Minimap.GetIconsSprite()
    iconssprite.Rotation = 0
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_MINIMAP_RENDER, gggg)