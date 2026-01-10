local function isSilverTreasureRoom(idx)
    if(Game():IsGreedMode()) then
        return idx==98
    end
    return false
end

local function isLibraryCardLibrary(idx)
    if(isSilverTreasureRoom(idx)) then return false end

    local room = Game():GetLevel():GetRoomByIdx(idx)
    if(room.VisitedCount>0 and (ToyboxMod:getExtraData("LIBRARY_CARD_VISITED_IDXS") or {})[room.SafeGridIndex]) then
        return true
    elseif(room.VisitedCount==0 and room.Data and room.Data.Type==RoomType.ROOM_TREASURE and PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_LIBRARY_CARD)) then
        return true
    end
    return false
end

-- replace backdrop
local function replaceBackdrop()
    if(isLibraryCardLibrary(Game():GetLevel():GetCurrentRoomIndex())) then
        return BackdropType.LIBRARY
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_BACKDROP_CHANGE, replaceBackdrop)

local function tryMarkRoomAsPermaLibrary()
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_LIBRARY_CARD)) then return end

    local room = Game():GetLevel():GetCurrentRoomDesc()
    if(isLibraryCardLibrary(room.SafeGridIndex) or (room.VisitedCount==1 and room.Data and room.Data.Type==RoomType.ROOM_TREASURE)) then
        room.Flags = room.Flags & (~RoomDescriptor.FLAG_DEVIL_TREASURE)

        local data = ToyboxMod:getExtraDataTable()
        data.LIBRARY_CARD_VISITED_IDXS = data.LIBRARY_CARD_VISITED_IDXS or {}
        data.LIBRARY_CARD_VISITED_IDXS[room.SafeGridIndex] = true

        Game():GetRoom():SetItemPool(ItemPoolType.POOL_LIBRARY)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, tryMarkRoomAsPermaLibrary)

local function gggg()
    local level = Game():GetLevel()
    local markupdate = false
    for i=0, 168 do
        local room = level:GetRoomByIdx(i)
        if(room and room.Data and isLibraryCardLibrary(i)) then
            if(room.Flags & RoomDescriptor.FLAG_DEVIL_TREASURE == RoomDescriptor.FLAG_DEVIL_TREASURE) then
                room.Flags = room.Flags & (~RoomDescriptor.FLAG_DEVIL_TREASURE)
                markupdate = true
            end
        end
    end
    if(markupdate) then
        level:UpdateVisibility()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, gggg)

local function setPool(_, t, v)
    if(t==EntityType.ENTITY_PICKUP and v==PickupVariant.PICKUP_COLLECTIBLE) then
        tryMarkRoomAsPermaLibrary()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, setPool)

---@param door GridEntityDoor
local function changeToLibrary(_, door)
    if(string.find(string.lower(door:GetSprite():GetFilename()), "holeinwall")) then return end

    local iscurrentlibrary = isLibraryCardLibrary(Game():GetLevel():GetCurrentRoomIndex())
    if(not (door and door.TargetRoomIndex>0 and (iscurrentlibrary or door.TargetRoomType==RoomType.ROOM_TREASURE))) then return end

    local sp = door:GetSprite()
    local islibrary = isLibraryCardLibrary(door.TargetRoomIndex) or iscurrentlibrary
    local haslibrarypath = string.find(string.lower(sp:GetLayer(3):GetSpritesheetPath()), "library")

    local spawnpoof = false

    if(haslibrarypath and not islibrary) then
        spawnpoof = true

        local room = Game():GetLevel():GetRoomByIdx(door.TargetRoomIndex)
        local shoulddevil = ((room.Flags & RoomDescriptor.FLAG_DEVIL_TREASURE ~= 0) or (room.VisitedCount==0 and PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_DEVILS_CROWN)))
        local desiredpath = "gfx/grid/door_02_treasureroomdoor"..(shoulddevil and "_devil" or "")..".png"
        for i, _ in pairs(sp:GetAllLayers()) do
            sp:ReplaceSpritesheet(i-1, desiredpath, false)
        end
        sp:LoadGraphics()
    elseif(not haslibrarypath and islibrary) then
        spawnpoof = not iscurrentlibrary

        for i, _ in pairs(sp:GetAllLayers()) do
            sp:ReplaceSpritesheet(i-1, "gfx/grid/door_13_librarydoor.png", false)
        end
        sp:LoadGraphics()
    end

    if(Game():GetRoom():GetFrameCount()>0 and spawnpoof) then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, door.Position, Vector.Zero, nil):ToEffect()
        door:Close()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, changeToLibrary)

local function resetPermaLibraries(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end

    ToyboxMod:setExtraData("LIBRARY_CARD_VISITED_IDXS", {})
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetPermaLibraries)

local MINIMAP_ICON_SPRITE = Sprite("gfx_tb/ui/ui_minimap_icons.anm2", true)
MINIMAP_ICON_SPRITE:Play("IconLibraryTreasureRoom", true)

local function roomIconRender(_, isBig, idx, pos, size, alpha, tlclamp, brclamp, brclamp2)
    if(isSilverTreasureRoom(idx)) then return end

    if(isLibraryCardLibrary(idx)) then
        MINIMAP_ICON_SPRITE:Play("IconLibraryTreasureRoom", true)
    else
        MINIMAP_ICON_SPRITE:Play("IconVanillaTreasureRoom", true)
    end

    local rpos = pos
    if(isBig) then
        rpos = rpos+size/2-Vector(2,2)+ToyboxMod:getRoomIconPosOffset(Game():GetLevel():GetRoomByIdx(idx))
    end

    MINIMAP_ICON_SPRITE.Color = Color(1,1,1,alpha)
    MINIMAP_ICON_SPRITE:Render(rpos, tlclamp, (brclamp2 and brclamp2+Vector(5,6)))
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_RENDER_MINIMAP_ROOM, roomIconRender, RoomType.ROOM_TREASURE)