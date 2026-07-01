--[[] ]

local ROOM_TYPE_CHANCES = {
    [RoomType.ROOM_CHEST] = {Weight=1, Subtype={0}},

    [RoomType.ROOM_TREASURE] = {Weight=0.5, Subtype={0}},
    [RoomType.ROOM_SHOP] = {Weight=0.5, Subtype=function()
        local shopLevel = 0
        local levelAch = {
            [Achievement.STORE_UPGRADE_LV1] = 1,
            [Achievement.STORE_UPGRADE_LV2] = 2,
            [Achievement.STORE_UPGRADE_LV3] = 3,
            [Achievement.STORE_UPGRADE_LV4] = 4,
        }
        local pgd = Isaac.GetPersistentGameData()
        for ach, lvl in pairs(levelAch) do
            if(pgd:Unlocked(ach)) then
                shopLevel = math.max(shopLevel, lvl)
            end
        end

        local tb = {}
        for i=0, shopLevel do table.insert(tb, i) end
        return tb
    end},
    [RoomType.ROOM_ARCADE] = {Weight=0.5, Subtype={0}},

    --[[] ]
    [RoomType.ROOM_SECRET] = {Weight=0.2},
    [RoomType.ROOM_CURSE] = {Weight=0.2},
    [RoomType.ROOM_SACRIFICE] = {Weight=0.2},
    [RoomType.ROOM_CHALLENGE] = {Weight=0.2},
    [RoomType.ROOM_ISAACS] = {Weight=0.2},
    [ToyboxMod.SPECIAL_ROOM_TYPE_TEMPLATE] = {Weight=0.2, Subtype=ToyboxMod.ROOM_TYPE_DATA.GRAVEYARD_ROOM.Id}, -- graveyard

    [RoomType.ROOM_SUPERSECRET] = {Weight=0.1},
    [RoomType.ROOM_DEVIL] = {Weight=0.1},
    [RoomType.ROOM_ANGEL] = {Weight=0.1},
    [RoomType.ROOM_ERROR] = {Weight=0.1},
    [RoomType.ROOM_PLANETARIUM] = {Weight=0.1},
    --] ]
}

---@param rng RNG
---@param referenceRoom RoomDescriptor
---@return {Type:RoomType, Subtype:integer?}
local function getRoomType(rng, referenceRoom)
    local isRoomValid = {}
    local roomStringToType = {}
    for roomType, data in pairs(ROOM_TYPE_CHANCES) do
        
        if(data.Subtype) then
            local subTable = data.Subtype
            if(type(data.Subtype)=="function") then
                subTable = data.Subtype()
            end

            for _, sub in ipairs(subTable) do
                local st = tostring(roomType).."."..tostring(sub)
                isRoomValid[st] = false
                roomStringToType[st] = {Type=roomType, Subtype=sub, ChanceMult=1/#subTable}
            end
        else
            local st = tostring(roomType)
            isRoomValid[st] = false
            roomStringToType[st] = {Type=roomType, ChanceMult=1}
        end
    end

    local roomset = RoomConfig.GetStage(StbType.SPECIAL_ROOMS):GetRoomSet(0)
    for i=0, #roomset-1 do
        local checkroom = roomset:Get(i)
        if(checkroom.Shape==referenceRoom.Data.Shape and (checkroom.Doors & referenceRoom.AllowedDoors == referenceRoom.AllowedDoors)) then
            local st = tostring(checkroom.Type)
            if(isRoomValid[st]~=nil) then
                isRoomValid[st] = true
            else
                st = st.."."..tostring(checkroom.Subtype)
                if(isRoomValid[st]~=nil) then
                    isRoomValid[st] = true
                end
            end
        end
    end

    local picker = WeightedOutcomePicker()
    local outcomeTable = {}
    for st, isValid in pairs(isRoomValid) do
        if(isValid) then
            local typeTable = roomStringToType[st]
            local chanceTable = ROOM_TYPE_CHANCES[typeTable.Type]

            table.insert(outcomeTable, st)
            picker:AddOutcomeFloat(#outcomeTable, chanceTable.Weight*typeTable.ChanceMult)
        end
    end

    local outcome = outcomeTable[picker:PickOutcome(rng)]
    return roomStringToType[outcome]
end

local function tryChangeStartingRoom(_, roomidx, dim)
    local level = ToyboxMod.GAME:GetLevel()
    local desc = level:GetRoomByIdx(roomidx, dim)
    if(not (desc.SafeGridIndex==level:GetStartingRoomIndex() and desc.VisitedCount==0)) then return end

    local rng = ToyboxMod:generateRng()
    local roomType = getRoomType(rng, desc)

    local newRoom = RoomConfig.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, roomType.Type, desc.Data.Shape, nil, nil, nil, nil, desc.AllowedDoors, roomType.Subtype)
    if(newRoom) then
        desc.OverrideData = desc.Data
        desc.Data = newRoom
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, tryChangeStartingRoom)

local diday = false

---@param room Room
---@param desc RoomDescriptor
local function newLevel(_, room, desc)
    local level = ToyboxMod.GAME:GetLevel()
    if(not diday and desc.SafeGridIndex==level:GetStartingRoomIndex() and desc.VisitedCount==0) then
        diday = true
        ToyboxMod.GAME:ChangeRoom(desc.SafeGridIndex, desc:GetDimension())
        diday = false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, newLevel)

local function changePlayerPositions(_)
    local level = ToyboxMod.GAME:GetLevel()
    local desc = level:GetCurrentRoomDesc()
    if(desc.SafeGridIndex==level:GetStartingRoomIndex() and desc.VisitedCount<=2) then
        Isaac.CreateTimer(function()
            local room = ToyboxMod.GAME:GetRoom()
            for i=0, ToyboxMod.GAME:GetNumPlayers()-1 do
                local pl = Isaac.GetPlayer(i)

                pl.Position = room:FindFreePickupSpawnPosition(pl.Position, 0, true, false)
            end
        end, 0, 1, false)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, changePlayerPositions)

---@param door GridEntityDoor
local function mango(_, door)
    local level = ToyboxMod.GAME:GetLevel()
    if(door.TargetRoomIndex==level:GetStartingRoomIndex()) then
        door:SetVariant(DoorVariant.DOOR_UNSPECIFIED)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, mango)
--]]