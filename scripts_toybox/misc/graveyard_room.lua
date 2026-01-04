
--! cant get it 2 work rn

--[[]]
local function addNewBossRoom(_)
    local level = Game():GetLevel()
    local newBossRoom = RoomConfigHolder.GetRandomRoom(Random(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_TELEPORTER)
    local possibleRooms = level:FindValidRoomPlacementLocations(newBossRoom, -1, false, false)

    local finalRoom
    while(#possibleRooms>0 and not finalRoom) do
        local idx = Isaac.GetPlayer():GetCollectibleRNG(1):RandomInt(#possibleRooms)+1
    
        finalRoom = level:TryPlaceRoom(newBossRoom, possibleRooms[idx], -1, 0, true, true, false)
        table.remove(possibleRooms, idx)
    end

    print(finalRoom)
    --[[] ]
    if(#validRooms>0) then
        local idx = Isaac.GetPlayer():GetCollectibleRNG(ToyboxMod.COLLECTIBLE_BLOODY_MAP):RandomInt(#validRooms)+1

        level:TryPlaceRoom(newBossRoom, validRooms[idx], -1, 0, true, true, false)
    end
    ]]
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, addNewBossRoom)

function ToyboxMod:gyat()
    addNewBossRoom()
end
--]]