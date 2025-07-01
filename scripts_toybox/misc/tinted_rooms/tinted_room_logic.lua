local TINT_AURA_SIZE = 1


---@param idx integer
---@param tint integer
---@param center boolean
local function markRoomAsTinted(idx, tint, center)
    local data = ToyboxMod:getExtraDataTable()
    data.TINTED_ROOM_POSITIONS = data.TINTED_ROOM_POSITIONS or {}
    data.TINTED_ROOM_POSITIONS[idx] = data.TINTED_ROOM_POSITIONS[idx] or {Tints=0, Centers=0}
    data.TINTED_ROOM_POSITIONS[idx].Tints = data.TINTED_ROOM_POSITIONS[idx].Tints | tint
    if(center) then
        data.TINTED_ROOM_POSITIONS[idx].Centers = data.TINTED_ROOM_POSITIONS[idx].Centers | tint
    end
end

---@param roomPos Vector
---@param tintedType integer
---@param radius integer?
function ToyboxMod:makeTintedRoom(roomPos, tintedType, radius)
    if(type(roomPos)~="number") then
        roomPos = ToyboxMod:positionVectorToGridIndex(roomPos)
    end
    radius = radius or 1

    local level = Game():GetLevel()

    local alreadyAddedToTintedAura = {}
    local idx = 1
    local roomQueue = {}
    table.insert(roomQueue, {roomPos, radius})

    while(roomQueue[idx]) do
        local curPos = roomQueue[idx][1]
        local curRad = roomQueue[idx][2]

        local room = level:GetRoomByIdx(curPos)
        if(room.Data and room.GridIndex>=0) then
            if(not alreadyAddedToTintedAura[room.SafeGridIndex]) then
                alreadyAddedToTintedAura[room.SafeGridIndex] = true

                markRoomAsTinted(room.SafeGridIndex, tintedType, curRad==radius)
            end

            if(curRad>1) then
                local topLeftPos = ToyboxMod:gridIndexToPositionVector(room.GridIndex)
                local roomSize = ToyboxMod.ROOM_DIMENSIONS[room.Data.Shape]
                if(room.Data.Subtype==BossType.DELIRIUM) then roomSize = ToyboxMod.ROOM_DIMENSIONS[RoomShape.ROOMSHAPE_1x1] end

                for rx=topLeftPos.X, topLeftPos.X+roomSize.X-1 do
                    for ry=topLeftPos.Y, topLeftPos.Y+roomSize.Y-1 do
                        if(level:GetRoomByIdx(ToyboxMod:positionVectorToGridIndex(Vector(rx,ry))).SafeGridIndex==room.SafeGridIndex) then
                            for ax=-1, 1 do
                                for ay=-1, 1 do
                                    local newidx = level:GetRoomByIdx(ToyboxMod:positionVectorToGridIndex(Vector(rx+ax,ry+ay))).SafeGridIndex
                                    if(newidx~=-1 and not alreadyAddedToTintedAura[newidx]) then
                                        table.insert(roomQueue, {newidx, curRad-1})
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        idx = idx+1
    end
end



local function resetTintedRoomsOnLevelGen(_)
    ToyboxMod:setExtraData("TINTED_ROOM_POSITIONS", {})
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LEVEL_LAYOUT_GENERATED, resetTintedRoomsOnLevelGen)




---@param player EntityPlayer
local function test(_, _, rng, player, flags)
    local numblablabla = 0
    for _, _ in pairs(ToyboxMod.TINTED_ROOM) do numblablabla = numblablabla+1 end

    local sel = rng:RandomInt(numblablabla)
    ToyboxMod:makeTintedRoom(Game():GetLevel():GetCurrentRoomDesc().SafeGridIndex, 1<<(sel))
end
--ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, test)