MilcomMOD = RegisterMod("milcomMod", 1)
local mod = MilcomMOD

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

    "scripts.helper",

    "scripts.libraries.custom_object_spawn",

    "scripts.config",
    "scripts.savedata.save_data",

    "scripts.statuseffects.electrified",
    "scripts.statuseffects.overflowing",

    "scripts.bosses.toinclude",

    "scripts.players.milcom.toinclude",
    "scripts.players.atlas.toinclude",
    "scripts.players.jonas.toinclude",

    "scripts.items.toinclude",
    "scripts.consumables.toinclude",

    "scripts.modcompat.eid.eid",

    "scripts.toybox_imgui",

    "scripts.funny_shaders",

    --"scripts.test",
}
for _, path in ipairs(mod_files) do
    include(path)
end

--[[

local rot = 25
local offset = Vector(0,-10)-Vector(0,-10):Rotated(rot)

local function getrotation(player)
    local headrot = player:GetHeadDirection()
    local rotation = ((headrot==Direction.LEFT or headrot==Direction.UP) and -1 or 1)*rot
    if(headrot==Direction.LEFT or headrot==Direction.RIGHT) then rotation = rotation*0.7 end

    return rotation
end

---@param pl EntityPlayer
local function postRenderHead(_, pl, renderpos)
    local rotation = getrotation(player)
    pl:GetSprite().Rotation = rotation
    return renderpos+(Vector(0,-10)-Vector(0,-10):Rotated(rotation))
end
mod:AddCallback(ModCallbacks.MC_PRE_RENDER_PLAYER_HEAD, postRenderHead)

---@param pl EntityPlayer
local function prePlayerRender(_, pl, offset)
    local cLayers = pl:GetCostumeLayerMap()
    local cost = pl:GetCostumeSpriteDescs()

    pl:GetSprite().Rotation = 0

    local activeHeadCostumidx = {}
    for _, data in ipairs(cLayers) do
        if(not data.isBodyLayer and data.costumeIndex~=-1) then table.insert(activeHeadCostumidx, data.costumeIndex+1) end
    end

    local rotation = getrotation(player)
    for _, idx in ipairs(activeHeadCostumidx) do
        local sp = cost[idx]:GetSprite()
        sp.Rotation = rotation
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, prePlayerRender)

--]]