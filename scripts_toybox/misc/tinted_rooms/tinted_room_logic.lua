local mod = ToyboxMod

local TINT_AURA_SIZE = 1

---@param roomPos Vector
---@param tintedType integer
function mod:makeTintedRoom(roomPos, tintedType)
    if(type(roomPos)~="number") then
        roomPos = mod:positionVectorToGridIndex(roomPos)
    end

    local data = mod:getExtraDataTable()
    data.TINTED_ROOM_POSITIONS = data.TINTED_ROOM_POSITIONS or {}

    local level = Game():GetLevel()
    local room = level:GetRoomByIdx(roomPos)
    if(room.Data and room.GridIndex>=0) then
        local topLeftPos = mod:gridIndexToPositionVector(room.GridIndex)
        local roomSize = mod.ROOM_DIMENSIONS[room.Data.Shape]

        local alreadyAddedToTintedAura = {}
        for rx=topLeftPos.X, topLeftPos.X+roomSize.X-1 do
            for ry=topLeftPos.Y, topLeftPos.Y+roomSize.Y-1 do
                if(level:GetRoomByIdx(mod:positionVectorToGridIndex(Vector(rx,ry))).SafeGridIndex==room.SafeGridIndex) then
                    for ax=-TINT_AURA_SIZE, TINT_AURA_SIZE do
                        for ay=-TINT_AURA_SIZE, TINT_AURA_SIZE do
                            local newidx = level:GetRoomByIdx(mod:positionVectorToGridIndex(Vector(rx+ax,ry+ay))).SafeGridIndex
                            if(not alreadyAddedToTintedAura[newidx]) then
                                alreadyAddedToTintedAura[newidx] = true
                                
                                data.TINTED_ROOM_POSITIONS[newidx] = data.TINTED_ROOM_POSITIONS[newidx] or {Tints=0, Centers=0}

                                data.TINTED_ROOM_POSITIONS[newidx].Tints = data.TINTED_ROOM_POSITIONS[newidx].Tints | tintedType
                                if(ax==0 and ay==0) then
                                    data.TINTED_ROOM_POSITIONS[newidx].Centers = data.TINTED_ROOM_POSITIONS[newidx].Centers | tintedType
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end



local function resetTintedRoomsOnLevelGen(_)
    mod:setExtraData("TINTED_ROOM_POSITIONS", {})
end
mod:AddCallback(ModCallbacks.MC_POST_LEVEL_LAYOUT_GENERATED, resetTintedRoomsOnLevelGen)




---@param player EntityPlayer
local function test(_, _, rng, player, flags)
    local numblablabla = 0
    for _, _ in pairs(mod.TINTED_ROOM) do numblablabla = numblablabla+1 end

    local sel = rng:RandomInt(numblablabla)
    mod:makeTintedRoom(Game():GetLevel():GetCurrentRoomDesc().SafeGridIndex, 1<<(sel))
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, test)