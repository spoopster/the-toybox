ToyboxMod = RegisterMod("toyboxMod", 1) ---@type ModReference
local mod = ToyboxMod

mod.HiddenItemManager = include("scripts_toybox.libraries.hiddenitemmanager")
mod.HiddenItemManager:Init(mod)

--! INCLUDE SHIT
local mod_files = {
    "scripts_toybox.enums",

    "scripts_toybox.custom.data",
    "scripts_toybox.custom.callback_includes",
    "scripts_toybox.custom.bombflags",
    "scripts_toybox.custom.ludo_trigger",
    "scripts_toybox.custom.statuseffects",
    "scripts_toybox.custom.tearvariants",
    "scripts_toybox.custom.throwables",
    "scripts_toybox.custom.achievement_system",

    "scripts_toybox.helper",

    "scripts_toybox.libraries.custom_object_spawn",

    "scripts_toybox.config",
    "scripts_toybox.savedata.save_data",

    "scripts_toybox.statuseffects.electrified",
    "scripts_toybox.statuseffects.overflowing",

    "scripts_toybox.bosses.toinclude",
    "scripts_toybox.enemies.toinclude",

    "scripts_toybox.players.milcom.toinclude",
    "scripts_toybox.players.atlas.toinclude",
    "scripts_toybox.players.jonas.toinclude",

    "scripts_toybox.items.toinclude",
    "scripts_toybox.pickups.toinclude",

    "scripts_toybox.modcompat.eid.core",
    "scripts_toybox.modcompat.accurate blurbs.accurate_blurbs",
    "scripts_toybox.modcompat.cain rework.main",

    "scripts_toybox.toybox_imgui",

    --"scripts_toybox.funny_shaders",

    --"scripts_toybox.fortnite funnies.silly healthbar",
    --"scripts_toybox.fortnite funnies.silly hearts",
    "scripts_toybox.fortnite funnies.mattman chance",
    "scripts_toybox.fortnite funnies.gold mode",
    "scripts_toybox.fortnite funnies.retro mode",
    "scripts_toybox.fortnite funnies.yes",
    --"scripts_toybox.fortnite funnies.black_souls",
    --"scripts_toybox.fortnite funnies.deja_vu",
    --"scripts_toybox.fortnite funnies.lupustro",
    --"scripts_toybox.fortnite funnies.stupid enemy title",
    "scripts_toybox.fortnite funnies.cool title screen",
    "scripts_toybox.fortnite funnies.slop o meter",

    --"scripts_toybox.test",
}
for _, path in ipairs(mod_files) do
    local res = include(path)

    if(type(res)=="function") then
        res()
    end
end

--[[
local circule = 8
local heeelp = false
---@param pl EntityPlayer
local function getParams(_, pl)
    if(heeelp) then return end
    heeelp = true

    print("yo")
    local params = pl:GetMultiShotParams(WeaponType.WEAPON_TEARS)
    params:SetNumTears(params:GetNumTears()*circule)
    params:SetNumEyesActive(circule)
    params:SetMultiEyeAngle(1260/circule)

    heeelp = false
    return params
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, getParams)
--]]

--[[

local rot = 90

local function getrotation(player)
    local headrot = player:GetHeadDirection()
    local rotation = ((headrot==Direction.LEFT or headrot==Direction.UP) and -1 or 1)*rot
    if(headrot==Direction.LEFT or headrot==Direction.RIGHT) then rotation = rotation*0.7 end

    return rotation
end

---@param pl EntityPlayer
local function postRenderHead(_, pl, renderpos)
    local rotation = getrotation(pl)
    pl:GetSprite().Rotation = rotation
    return renderpos+(Vector(0,-10)-Vector(0,-10):Rotated(rotation))
end
mod:AddCallback(ModCallbacks.MC_PRE_RENDER_PLAYER_HEAD, postRenderHead)

---@param pl EntityPlayer
local function prePlayerRender(_, pl, offset)
    local cLayers = pl:GetCostumeLayerMap()
    local cost = pl:GetCostumeSpriteDescs()

    pl:GetSprite().Rotation = 0

    --rot = math.sin(math.rad(pl.FrameCount)*18)*30

    local activeHeadCostumidx = {}
    for _, data in ipairs(cLayers) do
        if(not data.isBodyLayer and data.costumeIndex~=-1) then table.insert(activeHeadCostumidx, data.costumeIndex+1) end
    end

    local rotation = getrotation(pl)
    for _, idx in ipairs(activeHeadCostumidx) do
        local sp = cost[idx]:GetSprite()
        sp.Rotation = rotation
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, prePlayerRender)

--]]

--[[] ]
local bleh = mod:generateRng()
local FRAMES_TO_SPIN = 150
local NUM_SHADOWS = 3
local DIST = 4
local zorking = false

---@param rock GridEntity
local function darkRedRegen(_, rock, off)
    if(zorking) then return end
    zorking = true

    local oldCol = rock:GetSprite().Color
    local col = Color(oldCol.R,oldCol.G,oldCol.B,oldCol.A,oldCol.RO,oldCol.GO,oldCol.BO)

    rock:GetSprite().Color = Color(col.R,col.G,col.B,col.A*0.4,col.RO,col.GO,col.BO)
    for i=0,NUM_SHADOWS-1 do
        local ang = Game():GetFrameCount()/FRAMES_TO_SPIN*360+i/NUM_SHADOWS*360

        rock:Render(Vector.FromAngle(ang)*DIST)
    end
    rock:GetSprite().Color = col

    zorking = false
    --return false
end
mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_ROCK_RENDER, darkRedRegen)
--]]

--[[
■■■■■■■■■■■■■■■■■■■■■
■     ■       ■     ■
■■■■■ ■■■ ■■■■■ ■ ■■■
■   ■   ■ ■   ■ ■   ■
■ ■■■■■ ■ ■ ■ ■ ■■■ ■
■     ■ ■   ■   ■   ■
■ ■■■ ■ ■■■■■■■■■ ■■■
■   ■   ■       ■   ■
■■■ ■■■■■ ■■■■■ ■ ■ ■
■ ■ ■     ■   ■ ■ ■ ■
■ ■ ■ ■■■ ■ ■ ■ ■■■ ■
■   ■   ■ ■ ■ ■     ■
■ ■■■ ■■■ ■ ■ ■■■■■ ■
■ ■ ■ ■   ■ ■     ■ ■
■ ■ ■ ■ ■■■ ■■■ ■■■ ■
■ ■   ■   ■   ■   ■ ■
■ ■■■■■ ■ ■■■ ■■■ ■ ■
■     ■ ■ ■ ■   ■   ■
■■■■■ ■■■ ■ ■■■ ■■■■■
■         ■         ■
■■■■■■■■■■■■■■■■■■■■■
--]]

--[[

local PILLBONUS_FONT = Font()
PILLBONUS_FONT:Load("font/pftempestasevencondensed.fnt")

---@param slot EntitySlot
local function reSlotUpdate(_, slot, offset)
    mod:setEntityData(slot, "MAX_TIMEOUT", math.max(mod:getEntityData(slot, "MAX_TIMEOUT") or 0, slot:GetTimeout()))

    local tb = {}

    table.insert(tb, {NAME="STATE", VAL=slot:GetState()})
    table.insert(tb, {NAME="TIMEOUT", VAL=slot:GetTimeout()})
    table.insert(tb, {NAME="MAX TIMEOUT", VAL=(mod:getEntityData(slot, "MAX_TIMEOUT") or 0)})
    table.insert(tb, {NAME="PRIZE TYPE", VAL=slot:GetPrizeType()})
    table.insert(tb, {NAME="DONATION VALUE", VAL=slot:GetDonationValue()})

    mod:setEntityData(slot, "SLOT_RENDERS", tb)
end
mod:AddCallback(ModCallbacks.MC_PRE_SLOT_UPDATE, reSlotUpdate)

---@param slot EntitySlot
local function postSlotUpdate(_, slot, offset)
    local oldTb = mod:getEntityData(slot, "SLOT_RENDERS")

    oldTb[1].VAL = tostring(oldTb[1].VAL).." / "..slot:GetState()
    oldTb[2].VAL = tostring(oldTb[2].VAL).." / "..slot:GetTimeout()
    oldTb[4].VAL = tostring(oldTb[4].VAL).." / "..slot:GetPrizeType()
    oldTb[5].VAL = tostring(oldTb[5].VAL).." / "..slot:GetDonationValue()

    mod:setEntityData(slot, "SLOT_RENDERS", oldTb)
end
mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, postSlotUpdate)

---@param slot EntitySlot
local function postSlotRender(_, slot, offset)

    local off = 7
    local pos = Isaac.WorldToRenderPosition(slot.Position)+offset+Vector(0,off)
    local renders = mod:getEntityData(slot, "SLOT_RENDERS") or {}

    for _, renderData in ipairs(renders) do
        PILLBONUS_FONT:DrawStringScaled(renderData.NAME..": "..renderData.VAL, pos.X, pos.Y, 0.5,0.5, KColor(1,1,1,1))

        pos.Y = pos.Y+off
    end
end
mod:AddCallback(ModCallbacks.MC_POST_SLOT_RENDER, postSlotRender)

--]]

--[[
---@param pickup EntityPickup
local function postCollectableUpdate(_, pickup)
    if pickup.SubType ~= 0 then return end
    if pickup:GetData().AlreadyChecked then return end

    local nearby_pickup_num = 0
    for _, other in ipairs(Isaac.FindByType(5)) do
        if other.FrameCount==1 and other.Position:DistanceSquared(pickup.Position)<3*3 then
            nearby_pickup_num = nearby_pickup_num+1
        end
    end

    if(nearby_pickup_num>0) then
        for _, other in ipairs(Isaac.FindByType(5)) do
            if other.FrameCount==1 and other.Position:DistanceSquared(pickup.Position)<3*3 then
                other:Remove()
            end
        end
    end

    pickup:GetData().AlreadyChecked = true
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postCollectableUpdate, PickupVariant.PICKUP_COLLECTIBLE)
--]]

--[[
local function postNewRoom()
    local room = Game():GetRoom()
    --if(not room:IsFirstVisit()) then return end
    
    for _, slot in pairs(DoorSlot) do
        local door = room:GetDoor(slot)
        if(door) then
            local doorNormal = (door.Position-room:GetClampedPosition(door.Position, 0)):Normalized()

            local newIdx = room:GetGridIndex(door.Position+doorNormal:Rotated(90)*80)

            room:RemoveGridEntityImmediate(newIdx, 0, false)
            room:SpawnGridEntity(newIdx, door:GetSaveState())

            local newDoor = room:GetGridEntity(newIdx)
            if(newDoor and newDoor:ToDoor()) then
                newDoor = newDoor:ToDoor() ---@cast newDoor GridEntityDoor

                newDoor:Init(newDoor:GetSaveState().SpawnSeed)

                newDoor.CollisionClass = GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
                newDoor.TargetRoomIndex = door.TargetRoomIndex
                newDoor.TargetRoomType = door.TargetRoomType

                newDoor:GetSaveState().VarData = slot+100

                newDoor:Update()

                print(newDoor:GetSaveState().VarData)
            end

            print(door.CollisionClass)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param door GridEntityDoor
local function postGridEntityDoorRender(_, door, offset)
    local slot = door:GetSaveState().VarData-100
    if(slot<0) then return end

    local ogDoor = Game():GetRoom():GetDoor(slot)
    ogDoor:GetSprite():Render(Isaac.WorldToRenderPosition(door.Position))
    Isaac.RenderText("PENOR", Isaac.WorldToRenderPosition(door.Position).X, Isaac.WorldToRenderPosition(door.Position).Y,1,1,1,1)
end
mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_DOOR_RENDER, postGridEntityDoorRender)

---@param ent GridEntity?
local function collideithgrid(_, pl, idx, ent)
    if(ent and ent:ToWall()) then return true end

    if(not (ent and ent:ToDoor())) then return end
    local slot = ent:GetSaveState().VarData-100
    if(slot<0) then return end

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, collideithgrid)
--]]