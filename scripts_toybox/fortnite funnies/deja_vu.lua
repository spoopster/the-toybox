local mod = ToyboxMod

local prePlacedRooms = {}

---@param generator LevelGenerator
local function postLayoutGenerated(_, generator)
    prePlacedRooms = {}
end
mod:AddCallback(ModCallbacks.MC_POST_LEVEL_LAYOUT_GENERATED, postLayoutGenerated)

---@param genRoom LevelGeneratorRoom
---@param roomConf RoomConfigRoom
local function placeRoom(_, genRoom, roomConf, seed)
    if(roomConf.Name=="Start Room") then return end

    prePlacedRooms[genRoom:Shape()] = prePlacedRooms[genRoom:Shape()] or {}

    for _, prevConfData in ipairs(prePlacedRooms[genRoom:Shape()]) do
        if(prevConfData.Doors & genRoom:DoorMask() == genRoom:DoorMask() and prevConfData.Type==roomConf.Type) then
            return prevConfData
        end
    end

    table.insert(prePlacedRooms[genRoom:Shape()], roomConf)
end
mod:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, placeRoom)