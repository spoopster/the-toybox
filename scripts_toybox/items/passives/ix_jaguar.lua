local sfx = SFXManager()

local function revealAdjacentDoors()
    local desIdx = ToyboxMod:getExtraData("IX_REVEALED_ROOM")
    if((desIdx or -1)==-1) then return end

    local hasDoor = false

    local level = ToyboxMod.GAME:GetLevel()
    local room = ToyboxMod.GAME:GetRoom()
    local roomDesc = level:GetCurrentRoomDesc()

    local isRed = (roomDesc.Flags & RoomDescriptor.FLAG_RED_ROOM ~= 0) or (roomDesc.Data and roomDesc.Data.Type==RoomType.ROOM_ULTRASECRET)

    for slot, desc in pairs(roomDesc:GetNeighboringRooms()) do
        if(desc and desc.SafeGridIndex==desIdx) then
            level:UncoverHiddenDoor(roomDesc.SafeGridIndex, slot)
            local door = room:GetDoor(slot)
            if(door) then
                local shouldLock = not isRed and desc.VisitedCount<=0 and (ToyboxMod:getExtraData("IX_FAILED")>=PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_IX_JAGUAR))

                if(shouldLock) then
                    ToyboxMod:setGridEntityData(door, "IX_SHUT", true)

                    door:Close(true)
                    door:Bar()
                else
                    door:SetLocked(false)
                    if(isRed) then
                        door:Open()
                    end
                end
                --door:Open()
            end
            hasDoor = true
        end
    end

    if(hasDoor) then
        room:Update()
    end
end

local function addNewBossRoom(_)
    if(not ToyboxMod.GAME:GetRoom():IsFirstVisit()) then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_IX_JAGUAR)) then return end

    ToyboxMod:setExtraData("IX_REVEALED_ROOM", -1)
    ToyboxMod:setExtraData("IX_FAILED", 0)

    local level = ToyboxMod.GAME:GetLevel()
    local rng = ToyboxMod:generateRng(level:GetGenerationRNG():GetSeed())

    local usRoom
    for i=0, 168 do
        local room = level:GetRoomByIdx(i, -1)
        if(room and room.Data and room.Data.Type==RoomType.ROOM_ULTRASECRET) then
            room.DisplayFlags = RoomDescriptor.DISPLAY_ICON | RoomDescriptor.DISPLAY_LOCK

            usRoom = room
            break
        end
    end

    if(not usRoom) then return end

    local redRoomAttempts = {}
    for idx=0, 7 do
        if(usRoom.Doors[idx]~=-1) then
            local newBaseRoom = usRoom.Doors[idx]
            for _, desc in pairs(level:GetNeighboringRooms(newBaseRoom, RoomShape.ROOMSHAPE_1x1, -1)) do
                if(desc.SafeGridIndex~=usRoom.SafeGridIndex and desc.Data) then
                    for idx2=0, 7 do
                        if(desc.Doors[idx2]==newBaseRoom) then
                            table.insert(redRoomAttempts, {Result=newBaseRoom, Origin=desc.SafeGridIndex, Slot=idx2})
                        end
                    end
                end
            end
        end
    end

    local finalData
    while(not finalData) do
        local chosen = redRoomAttempts[rng:RandomInt(1,#redRoomAttempts)]
        if(level:MakeRedRoomDoor(chosen.Origin, chosen.Slot)) then
            finalData = {Result=chosen.Result, Origin=chosen.Origin, Slot=chosen.Slot}

            local room = level:GetRoomByIdx(chosen.Result, -1)
            room.DisplayFlags = RoomDescriptor.DISPLAY_ALL
        else
            local idx = chosen.Result
            local j = 1
            while(j<=#redRoomAttempts) do
                if(redRoomAttempts[j].Result==idx) then
                    table.remove(redRoomAttempts, j)
                else
                    j = j+1
                end
            end
        end
    end

    if(finalData) then
        ToyboxMod:setExtraData("IX_REVEALED_ROOM", finalData.Result)

        local hasNeighbor = false
        local croom = level:GetCurrentRoomDesc()
        for i=0,7 do
            if(croom.Doors[i]==finalData.Result) then
                hasNeighbor = true
            end
        end

        if(hasNeighbor) then
            ToyboxMod.GAME:ChangeRoom(level:GetCurrentRoomIndex())
        end

        revealAdjacentDoors()
    end

    level:UpdateVisibility()
    if(MinimapAPI) then
        MinimapAPI:CheckForNewRedRooms()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, addNewBossRoom)

local function addNewBossRoomMango(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_IX_JAGUAR)) then return end

    revealAdjacentDoors()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, addNewBossRoomMango)

---@param player Entity
local function applyMarkPenalties(_, player, _, flags, source)
    player = player:ToPlayer()
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_IX_JAGUAR)) then return end
    if((ToyboxMod:getExtraData("IX_REVEALED_ROOM") or -1)==-1) then return end

    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES)~=0) then return end

    local room = ToyboxMod.GAME:GetLevel():GetRoomByIdx(ToyboxMod:getExtraData("IX_REVEALED_ROOM"), -1)
    if(room.VisitedCount>0) then return end

    if(ToyboxMod:getExtraData("IX_FAILED")<PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_IX_JAGUAR)) then
        sfx:Play(ToyboxMod.SFX_BELL)

        player:AnimateSad()
    end
    ToyboxMod:setExtraData("IX_FAILED", (ToyboxMod:getExtraData("IX_FAILED") or 0)+1)
    revealAdjacentDoors()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, applyMarkPenalties, EntityType.ENTITY_PLAYER)

---@param door GridEntityDoor
local function doorupdate(_, door)
    if(not ToyboxMod:getGridEntityData(door, "IX_SHUT")) then return end

    door:SetVariant(DoorVariant.DOOR_LOCKED_BARRED)
    door:Bar()
    door:Close(true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_DOOR_UPDATE, doorupdate)