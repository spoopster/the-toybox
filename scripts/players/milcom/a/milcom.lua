local mod = MilcomMOD

--local LIGHT_FAM_ID = Isaac.GetEntityVariantByName("MILCOM LIGHT FAMILIAR")

--#region DATA
local MILCOM_A_BASEDATA = {
    --JUMPING STUFF
    CURRENT_JUMPHEIGHT = 0,
    MAX_JUMPHEIGHT = 10,

    JUMP_FRAMES = 0,
    MAX_JUMPDURATION = 15,
}

mod.MILCOM_A_BASEDATA = MILCOM_A_BASEDATA
mod.MILCOM_A_DATA = {}

--#endregion

---@param player EntityPlayer
local function postMilcomInit(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    local data = mod:getMilcomATable(player)

    player:GetSprite():Load("gfx/characters/players/milcom_a.anm2", true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postMilcomInit)

---@param player EntityPlayer
local function postMilcomUpdate(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    local data = mod:getMilcomATable(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postMilcomUpdate)

---@param player EntityPlayer
local function postMilcomRender(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    --! FOR TESTING PURPOSES, DELETE ON RELEASE
    if(mod.MILCOM_A_DATA[player.InitSeed]==nil) then mod.MILCOM_A_DATA[player.InitSeed] = mod:cloneTable(mod.MILCOM_A_BASEDATA) end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postMilcomRender)