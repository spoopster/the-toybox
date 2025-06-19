
--! cant get it 2 work rn

--[[] ]
local function addNewBossRoom(_)
    local level = Game():GetLevel()
    local newBossRoom = RoomConfigHolder.GetRandomRoom(Random(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_BOSS)
    print(newBossRoom.Shape, newBossRoom.Height, newBossRoom.Width)

    local possibleRooms = level:FindValidRoomPlacementLocations(newBossRoom, -1, true, true)
    local validRooms = {}
    
    print("--")
    for _, idx in ipairs(possibleRooms) do
        local desc = level:GetRoomByIdx(idx, -1)
        local hasNoValidNeighbors = true

        for _, nIdx in ipairs({idx+1, idx-1, idx+13, idx-13}) do
            if(nIdx>=0 and nIdx<=168) then
                local nDesc = level:GetRoomByIdx(nIdx)
                local nData = nDesc.Data

                if(nData and not (nData.Type==RoomType.ROOM_SECRET or nData.Type==RoomType.ROOM_SUPERSECRET or nData.Type==RoomType.ROOM_ULTRASECRET)) then
                    hasNoValidNeighbors = false
                end
            end
        end

        if( not hasNoValidNeighbors) then
            table.insert(validRooms, idx)
        end
    end
    print("--")
    print(#possibleRooms, #validRooms)

    local finalRoom
    while(#validRooms>0 and not finalRoom) do
        local idx = Isaac.GetPlayer():GetCollectibleRNG(ToyboxMod.COLLECTIBLE_BLOODY_MAP):RandomInt(#validRooms)+1
    
        finalRoom = level:TryPlaceRoom(newBossRoom, validRooms[idx], -1, 0, true, true, false)
        table.remove(validRooms, idx)
    end

    print(finalRoom)
    --[[if(#validRooms>0) then
        local idx = Isaac.GetPlayer():GetCollectibleRNG(ToyboxMod.COLLECTIBLE_BLOODY_MAP):RandomInt(#validRooms)+1

        level:TryPlaceRoom(newBossRoom, validRooms[idx], -1, 0, true, true, false)
    end] ]
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, addNewBossRoom)

function ToyboxMod:gyat()
    addNewBossRoom()
end
--]]