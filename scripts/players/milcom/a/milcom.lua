local mod = MilcomMOD

mod.MILCOM_CHAMPION_CHANCE_INC = 1--0.5

mod.MILCOM_BOMB_VALUE = 4
mod.MILCOM_KEY_VALUE = 7

mod.MILCOM_BOMB_VALUE_BIRTHRIGHT = 3
mod.MILCOM_KEY_VALUE_BIRTHRIGHT = 5

--#region DATA
local MILCOM_A_BASEDATA = {
    --JUMPING STUFF
    CURRENT_JUMPHEIGHT = 0,
    MAX_JUMPHEIGHT = 11,

    JUMP_FRAMES = 0,
    MAX_JUMPDURATION = 18,
}

mod.MILCOM_A_BASEDATA = MILCOM_A_BASEDATA

--#endregion

---@param player EntityPlayer
local function postMilcomInit(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_TYPE.MILCOM_A) then return end
    local data = mod:getMilcomATable(player)

    player:GetSprite():Load("gfx/characters/tb_character_milcom_a.anm2", true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postMilcomInit)

---@param player EntityPlayer
local function postMilcomUpdate(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_TYPE.MILCOM_A) then return end
    local data = mod:getMilcomATable(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postMilcomUpdate)