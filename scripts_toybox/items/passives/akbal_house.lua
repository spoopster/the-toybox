local function tryChangeStartingRoom(_, roomidx, dim)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_AKBAL_HOUSE)) then return end

    local level = ToyboxMod.GAME:GetLevel()
    local desc = level:GetRoomByIdx(roomidx, dim)
    if(not (desc.SafeGridIndex==level:GetStartingRoomIndex() and desc.VisitedCount==1)) then return end

    local rng = ToyboxMod:generateRng()

    local newRoom
    while(not newRoom) do
        newRoom = RoomConfig.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_ISAACS, RoomShape.ROOMSHAPE_1x1, nil, nil, nil, nil, desc.AllowedDoors, 0)
        if(newRoom) then
            local conf = EntityConfig
            for i=0, newRoom.Spawns.Size-1 do
                local sp = newRoom.Spawns:Get(i)
                for j=0, sp.Entries.Size-1 do
                    local ent = sp.Entries:Get(j)
                    if(ent.Type>=10 and ent.Type<999) then
                        local econf = conf.GetEntity(ent.Type, ent.Variant, ent.Subtype)
                        if(econf:CanShutDoors()) then
                            newRoom = nil
                            break
                        end
                    elseif(ent.Type>=1000 and sp.X==4 and sp.Y==0) then
                        newRoom = nil
                        break
                    end
                end
                if(not newRoom) then
                    break
                end
            end
        end
    end

    if(newRoom) then
        desc.OverrideData = desc.Data
        desc.Data = newRoom
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, tryChangeStartingRoom)

local diday = false

local function changePlayerPositions(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_AKBAL_HOUSE)) then return end

    local level = ToyboxMod.GAME:GetLevel()
    local desc = level:GetCurrentRoomDesc()
    if(desc.SafeGridIndex==level:GetStartingRoomIndex()) then
        if(desc.VisitedCount==1) then
            diday = true
            ToyboxMod.GAME:ChangeRoom(desc.SafeGridIndex, desc:GetDimension())
            diday = false
        elseif(desc.VisitedCount==2) then
            Isaac.Spawn(1000,EffectVariant.ISAACS_CARPET,0,ToyboxMod.GAME:GetRoom():GetCenterPos(),Vector(0,0),nil)
            Isaac.CreateTimer(function()
                local room = ToyboxMod.GAME:GetRoom()
                for i=0, ToyboxMod.GAME:GetNumPlayers()-1 do
                    local pl = Isaac.GetPlayer(i)

                    pl.Position = room:FindFreePickupSpawnPosition(pl.Position, 0, true, false)
                end
            end, 0, 1, false)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, changePlayerPositions)

---@param ent GridEntity
local function mango(_, ent)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_AKBAL_HOUSE)) then return end

    local door = ent:ToDoor()

    local level = ToyboxMod.GAME:GetLevel()
    if(door and door.TargetRoomIndex==level:GetStartingRoomIndex()) then
        door:SetRoomTypes(door.CurrentRoomType, RoomType.ROOM_DEFAULT)
        door:SetVariant(DoorVariant.DOOR_UNLOCKED)
        door:SetLocked(false)
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, mango, GridEntityType.GRID_DOOR)
--]]