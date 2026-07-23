
---@param slot LevelGeneratorRoom
---@param conf RoomConfigRoom
---@param seed int
local function mangoLicious(_, slot, conf, seed)
    if(slot:GenerationIndex()==0 and seed==ToyboxMod.GAME:GetLevel():GetGenerationRNG():GetSeed()) then
        if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_AKBAL_HOUSE)) then return end

        local rng = ToyboxMod:generateRng()
        local newRoom
        while(not newRoom) do
            newRoom = RoomConfig.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_ISAACS, RoomShape.ROOMSHAPE_1x1, nil, nil, nil, nil, conf.Doors, 0)
            if(newRoom) then
                local entConf = EntityConfig
                for i=0, newRoom.Spawns.Size-1 do
                    local sp = newRoom.Spawns:Get(i)
                    for j=0, sp.Entries.Size-1 do
                        local ent = sp.Entries:Get(j)
                        if(ent.Type>=10 and ent.Type<999) then
                            local econf = entConf.GetEntity(ent.Type, ent.Variant, ent.Subtype)
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

        return newRoom or conf
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, mangoLicious)

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