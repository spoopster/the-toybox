local mod = MilcomMOD

local MILCOM_A_BASEDATA = {
    CHARACTER_SIDE = "A",

    CURRENT_JUMPHEIGHT = 0,
    MAX_JUMPHEIGHT = 10,

    JUMP_FRAMES = 0,
    MAX_JUMPDURATION = 15,
    
    POS_OFFSET = Vector(1e5, 1e5),

    RENDERING_PLAYER = false,
}

mod.MILCOM_A_BASEDATA = MILCOM_A_BASEDATA
mod.MILCOM_A_DATA = {}

---@param player EntityPlayer
function mod:getMilcomATable(player)
    return mod.MILCOM_A_DATA[player.InitSeed]
end
---@param player EntityPlayer
---@param key string
function mod:getMilcomAData(player, key)
    return mod.MILCOM_A_DATA[player.InitSeed][key]
end
---@param player EntityPlayer
---@param key string
function mod:setMilcomAData(player, key, val)
    mod.MILCOM_A_DATA[player.InitSeed][key] = val
end

---@param player EntityPlayer
local function postMilcomInit(_, player)
    if(player:GetPlayerType()~=mod.MILCOM_A_ID) then return end

    player:GetSprite():Load("gfx/characters/players/milcom_a.anm2", true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postMilcomInit, 0)

---@param player EntityPlayer
local function postMilcomUpdate(_, player)
    if(player:GetPlayerType()~=mod.MILCOM_A_ID) then return end

end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postMilcomUpdate, 0)

---@param player EntityPlayer
local function postMilcomRender(_, player)
    if(player:GetPlayerType()~=mod.MILCOM_A_ID) then return end

    --! FOR TESTING PURPOSES, DELETE ON RELEASE
    if(mod.MILCOM_A_DATA[player.InitSeed]==nil) then mod.MILCOM_A_DATA[player.InitSeed] = mod:cloneTable(mod.MILCOM_A_BASEDATA) end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postMilcomRender, 0)

