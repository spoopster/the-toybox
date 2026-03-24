ToyboxMod.SPECIAL_ROOM_TYPE_TEMPLATE = RoomType.ROOM_TELEPORTER

ToyboxMod.ROOM_TYPE_DATA = {
    GRAVEYARD_ROOM = {
        Id = 100,
        IconAnim = "IconGraveyardRoom",
        MinimapIcon = "ToyboxGraveyardRoom",
        Backdrop = ToyboxMod.BACKDROOP_GRAVEYARD,
        DoorGfx = "gfx_tb/grid/graveyard_door.png",
        Locked = true,
        Pool = ToyboxMod.POOL_GRAVEYARD,
    },
    TEMPLE_ROOM = {
        Id = 101,
        IconAnim = "IconTempleRoom",
        MinimapIcon = "ToyboxTempleRoom",
        Backdrop = ToyboxMod.BACKDROOP_GRAVEYARD,
    }
}

local ID_TO_TABLEKEY = {}
for key, val in pairs(ToyboxMod.ROOM_TYPE_DATA) do
    ID_TO_TABLEKEY[val.Id] = key
end

for _, data in pairs(ToyboxMod.ROOM_TYPE_DATA) do
    ToyboxMod:addCustomRoomIcon(
        data.MinimapIcon,
        function(room)
            if(room.Type==ToyboxMod.SPECIAL_ROOM_TYPE_TEMPLATE) then
                if(room.Descriptor and room.Descriptor.Data and room.Descriptor.Data.Subtype==data.Id) then
                    return true
                end
            end
            return false
        end
    )
end

---@param roomDesc RoomDescriptor
---@param key string
function ToyboxMod:isCustomSpecialRoom(roomDesc, key)
    local dat = roomDesc and roomDesc.Data
    if(not dat) then return false end

    if((dat.Type==ToyboxMod.SPECIAL_ROOM_TYPE_TEMPLATE) and (ID_TO_TABLEKEY[dat.Subtype]==key)) then
        return true
    end
    return false
end

-- replace pool
local function setRoomPool(_)
    local desc = Game():GetLevel():GetCurrentRoomDesc()
    if(not (desc.Data and desc.Data.Type==ToyboxMod.SPECIAL_ROOM_TYPE_TEMPLATE and ID_TO_TABLEKEY[desc.Data.Subtype])) then return end

    local pool = ToyboxMod.ROOM_TYPE_DATA[ID_TO_TABLEKEY[desc.Data.Subtype]].Pool
    if(pool) then
        Game():GetRoom():SetItemPool(pool)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT, setRoomPool)

local function setPoolWhenItemSpawns(_, t, v)
    if(t==EntityType.ENTITY_PICKUP and v==PickupVariant.PICKUP_COLLECTIBLE) then
        setRoomPool()
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN, CallbackPriority.IMPORTANT, setPoolWhenItemSpawns)

-- replace backdrop
local function replaceBackdrop()
    local desc = Game():GetLevel():GetCurrentRoomDesc()
    if(not (desc.Data and desc.Data.Type==ToyboxMod.SPECIAL_ROOM_TYPE_TEMPLATE and ID_TO_TABLEKEY[desc.Data.Subtype])) then return end
    local backdrop = ToyboxMod.ROOM_TYPE_DATA[ID_TO_TABLEKEY[desc.Data.Subtype]].Backdrop
    return backdrop
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_BACKDROP_CHANGE, CallbackPriority.IMPORTANT, replaceBackdrop)

---@param ent GridEntity
local function makeLockedDoor(_, ent, _, first)
    local door = ent:ToDoor()
    local room = Game():GetLevel():GetRoomByIdx(door.TargetRoomIndex)
    if(not (room.Data and room.Data.Type==ToyboxMod.SPECIAL_ROOM_TYPE_TEMPLATE and ID_TO_TABLEKEY[room.Data.Subtype])) then return end
    if(string.find(string.lower(door:GetSprite():GetFilename()), "holeinwall")) then return end

    local data = ToyboxMod.ROOM_TYPE_DATA[ID_TO_TABLEKEY[room.Data.Subtype]]

    if(data.DoorGfx) then
        local sp = door:GetSprite()
        for i, _ in pairs(sp:GetAllLayers()) do
            sp:ReplaceSpritesheet(i-1, data.DoorGfx, false)
        end
        sp:LoadGraphics()
    end
    if(data.Locked and room.VisitedCount==0) then
        door:SetLocked(true)
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, makeLockedDoor, GridEntityType.GRID_DOOR)

-- room icon rendering

local MINIMAP_ICON_SPRITE = Sprite("gfx_tb/ui/ui_minimap_icons.anm2", true)
MINIMAP_ICON_SPRITE:Play("IconGraveyardRoom", true)

local function roomIconRender(_, isBig, idx, pos, size, alpha, tlclamp, brclamp, brclamp2)
    local room = Game():GetLevel():GetRoomByIdx(idx)
    if(not (room.Data and ID_TO_TABLEKEY[room.Data.Subtype])) then return end

    local anim = ToyboxMod.ROOM_TYPE_DATA[ID_TO_TABLEKEY[room.Data.Subtype]].IconAnim

    MINIMAP_ICON_SPRITE:Play(anim, true)
    MINIMAP_ICON_SPRITE.Color = Color(1,1,1,alpha)
    local rpos = pos
    if(isBig) then
        rpos = rpos+size/2-Vector(2,2)+ToyboxMod:getRoomIconPosOffset(room)
    end

    MINIMAP_ICON_SPRITE:Render(rpos, tlclamp, (brclamp2 and brclamp2+Vector(5,6)))
end
--ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_RENDER_MINIMAP_ROOM, roomIconRender, ToyboxMod.SPECIAL_ROOM_TYPE_TEMPLATE)

local function removeMissingIcons(_)
    local sp = Minimap.GetIconsSprite()
    local layer = sp:GetLayer(0)
    if(layer:GetSpritesheetPath()==layer:GetSpritesheetPath()) then
        --sp:ReplaceSpritesheet(0, "gfx_tb/ui/ui_vanilla_icons_missing.png", true)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_PRE_MINIMAP_RENDER, removeMissingIcons)