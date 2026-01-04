local SPECIAL_ROOM_TYPE_TEMPLATE = RoomType.ROOM_TELEPORTER

ToyboxMod.ROOM_TYPE_DATA = {
    GRAVEYARD_ROOM = {
        Id = 100,
        IconAnim = "IconGraveyardRoom",
    },
    TEMPLE_ROOM = {
        Id = 101,
        IconAnim = "IconTempleRoom",
    }
}

local ID_TO_TABLEKEY = {}
for key, val in pairs(ToyboxMod.ROOM_TYPE_DATA) do
    ID_TO_TABLEKEY[val.Id] = key
end

local MINIMAP_ICON_SPRITE = Sprite("gfx_tb/ui/ui_minimap_icons.anm2", true)
MINIMAP_ICON_SPRITE:Play("IconGraveyardRoom", true)

local entityPickupGroups = {
    ["5.10.-1"] = "heart",
    ["5.20.-1"] = "coin",
    ["5.30.-1"] = "key",
    ["5.40.-1"] = "bomb",
    ["5.42.-1"] = "poop",
    ["5.50.-1"] = "chest",
    ["5.51.-1"] = "chest",
    ["5.52.-1"] = "chest",
    ["5.53.-1"] = "chest",
    ["5.54.-1"] = "chest",
    ["5.55.-1"] = "chest",
    ["5.56.-1"] = "chest",
    ["5.57.-1"] = "chest",
    ["5.58.-1"] = "chest",
    ["5.60.-1"] = "chest",
    ["5.69.-1"] = "chest",
    ["5.360.-1"] = "chest",
    ["5.70.-1"] = "pill",
    ["5.90.-1"] = "battery",
    ["5.100.-1"] = "item",
    ["5.350.-1"] = "trinket",
    ["6.4.-1"] = "beggar",
    ["6.5.-1"] = "beggar",
    ["6.6.-1"] = "beggar",
    ["6.7.-1"] = "beggar",
    ["6.9.-1"] = "beggar",
    ["6.13.-1"] = "beggar",
    ["6.15.-1"] = "beggar",
    ["6.18.-1"] = "beggar",
    ["6.1.-1"] = "slot",
    ["6.2.-1"] = "slot",
    ["6.3.-1"] = "slot",
    ["6.8.-1"] = "slot",
    ["6.10.-1"] = "slot",
    ["6.12.-1"] = "slot",
    ["6.16.-1"] = "slot",
    ["6.17.-1"] = "slot",
    ["6.19.-1"] = "slot",
    ["1000.161.980"] = "portal",
}
local gridEntityGroups = {
    ["18.-1"] = "ladder",
}

---@param roomDesc RoomDescriptor
local function getNumPickupGroupsInRoom(roomDesc)
    roomDesc = roomDesc or Game():GetLevel():GetCurrentRoomDesc()

    local numgroups = 0
    local seenGroups = {}

    local entState = roomDesc:GetEntitiesSaveState()
    local gridState = roomDesc:GetGridEntitiesSaveState()

    for i=0, #entState-1 do
        local ent = entState:Get(i)
        if(ent) then
            local str1 = tostring(ent:GetType())
            local str2 = str1.."."..tostring(ent:GetVariant())
            local str3 = str2.."."..tostring(ent:GetSubType())
            str2 = str2..".-1"
            str1 = str1..".-1.-1"

            local group = entityPickupGroups[str1] or entityPickupGroups[str2] or entityPickupGroups[str3] or nil

            if(group and not seenGroups[group]) then
                seenGroups[group] = true
                numgroups = numgroups+1
            end
        end
    end
    for i=0, #gridState-1 do
        local ent = gridState:Get(i)
        if(ent) then
            local str1 = tostring(ent.Type)
            local str2 = str1.."."..tostring(ent.Variant)
            str1 = str1..".-1"

            local group = gridEntityGroups[str1] or gridEntityGroups[str2] or nil

            if(group and not seenGroups[group]) then
                seenGroups[group] = true
                numgroups = numgroups+1
            end
        end
    end

    return numgroups
end

local function gridInit(_, isBig, idx, pos, size, alpha, tlclamp, brclamp, brclamp2)
    local room = Game():GetLevel():GetRoomByIdx(idx)
    if(not (room.Data and room.Data.Type==SPECIAL_ROOM_TYPE_TEMPLATE and ID_TO_TABLEKEY[room.Data.Subtype])) then return end

    local anim = ToyboxMod.ROOM_TYPE_DATA[ID_TO_TABLEKEY[room.Data.Subtype]].IconAnim

    MINIMAP_ICON_SPRITE:Play(anim, true)
    MINIMAP_ICON_SPRITE.Color = Color(1,1,1,alpha)
    local rpos = pos
    if(isBig) then
        rpos = rpos+size/2-Vector(2,2)

        local numgroups = getNumPickupGroupsInRoom(room)+1
        if(numgroups>1) then
            rpos = rpos-Vector(4,0)
        end
        if(numgroups>2) then
            rpos = rpos-Vector(0,4)
        end
    end

    MINIMAP_ICON_SPRITE:Render(rpos, tlclamp, (brclamp2 and brclamp2+Vector(5,6)))
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_RENDER_MINIMAP_ROOM, gridInit)

local function removeTeleporterIcon(_)
    local sp = Minimap.GetIconsSprite()
    local layer = sp:GetLayer(0)
    if(layer:GetSpritesheetPath()==layer:GetSpritesheetPath()) then
        sp:ReplaceSpritesheet(0, "gfx_tb/ui/ui_vanilla_icons_notele.png", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_MINIMAP_RENDER, removeTeleporterIcon)