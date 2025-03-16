ToyboxMod = RegisterMod("toyboxMod", 1) ---@type ModReference
local mod = ToyboxMod

mod.HiddenItemManager = include("scripts.libraries.hiddenitemmanager")
mod.HiddenItemManager:Init(mod)

--! INCLUDE SHIT
local mod_files = {
    "scripts.enums",

    "scripts.custom.data",
    "scripts.custom.callback_includes",
    "scripts.custom.bombflags",
    "scripts.custom.ludo_trigger",
    "scripts.custom.statuseffects",
    "scripts.custom.tearvariants",
    "scripts.custom.throwables",
    "scripts.custom.achievement_system",

    "scripts.helper",

    "scripts.libraries.custom_object_spawn",

    "scripts.config",
    "scripts.savedata.save_data",

    "scripts.statuseffects.electrified",
    "scripts.statuseffects.overflowing",

    "scripts.bosses.toinclude",
    "scripts.enemies.toinclude",

    "scripts.players.milcom.toinclude",
    "scripts.players.atlas.toinclude",
    "scripts.players.jonas.toinclude",

    "scripts.items.toinclude",
    "scripts.pickups.toinclude",

    "scripts.modcompat.eid.eid",
    "scripts.modcompat.accurate blurbs.accurate_blurbs",

    "scripts.toybox_imgui",

    --"scripts.funny_shaders",

    --"scripts.fortnite funnies.silly healthbar",
    --"scripts.fortnite funnies.silly hearts",
    "scripts.fortnite funnies.mattman chance",
    "scripts.fortnite funnies.gold mode",
    "scripts.fortnite funnies.retro mode",
    --"scripts.fortnite funnies.yes",
    --"scripts.fortnite funnies.black_souls",
    --"scripts.fortnite funnies.deja_vu",

    --"scripts.test",
}
for _, path in ipairs(mod_files) do
    include(path)
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