local mod = MilcomMOD

local LIGHT_FAM_ID = Isaac.GetEntityVariantByName("MILCOM LIGHT FAMILIAR")

--#region DATA
local MILCOM_A_BASEDATA = {
    CHARACTER_SIDE = "A",

    --JUMPING STUFF
    CURRENT_JUMPHEIGHT = 0,
    MAX_JUMPHEIGHT = 10,

    JUMP_FRAMES = 0,
    MAX_JUMPDURATION = 15,
    
    POS_OFFSET = Vector(1,1)*1e2,
    RENDERING_PLAYER = false,
    LIGHT_RENDERER = nil, 

    --CRAFTING STUFF
    MENU_OPEN_FRAMES = 0,
    SHOULD_RENDER_MENU = false,
    RENDER_FRAMES = 0,
    SELECTED_MENU = 1, -- 1 = crafting, 2 = inventory
    SELECTED_CRAFT_INDEX = 1,
    SELECTED_INV_INDEX = 1,
    OWNED_CRAFTABLES = {
    },

    INV_CRAFTABLE_OFFSET = Vector(-120,-44),
    DATA_CRAFTABLE_OFFSET = Vector(-251, -43),

    DATA_TITLESIZE = Vector(70,40),
    DATA_DESCRIPTIONSIZE = Vector(110, 44),

    SHIFT_INPUTFRAMES_LEFT = 0,
    SHIFT_INPUTFRAMES_RIGHT = 0,
    SHIFT_INPUTFRAMES_UP = 0,
    SHIFT_INPUTFRAMES_DOWN = 0,

    SHIFTING_DURATION = 10,
    SHIFTING_DURATIONFAST = 6,
    SHIFTING_FAST_REQ = 5, --num of slow held shifts before the fast held shifts start

    SHIFTING_LENGTH_CRAFT = nil,
    SHIFTING_FRAMES_CRAFT = nil,
    SHIFTING_DIRECTION_CRAFT = nil,

    SHIFTING_LENGTH_INV = nil,
    SHIFTING_FRAMES_INV = nil,
    SHIFTING_DIRECTION_INV = nil,
}

mod.MILCOM_A_BASEDATA = MILCOM_A_BASEDATA
mod.MILCOM_A_DATA = {}

mod.MILCOM_A_PICKUPS = {
    CARDBOARD = 0,
    DUCT_TAPE = 0,
    NAILS = 0,

    CARDBOARD_NOUPGRADE = 0,
    DUCT_TAPE_NOUPGRADE = 0,
    NAILS_NOUPGRADE = 0,
}

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

--[[
---@param player EntityPlayer
local function postCacheEval(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end

    player:CheckFamiliar(LIGHT_FAM_ID, 0, player:GetDropRNG())
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, postCacheEval, CacheFlag.CACHE_FAMILIARS)

local function lightFamInit(_, familiar)
    if(not (familiar.Player and familiar.Player:GetPlayerType()==mod.PLAYER_MILCOM_A)) then return end

    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, lightFamInit, LIGHT_FAM_ID)
---@param familiar EntityFamiliar
local function lightFamUpdate(_, familiar)
    if(not (familiar.Player and familiar.Player:GetPlayerType()==mod.PLAYER_MILCOM_A)) then return end

    familiar.Velocity = familiar.Player.Velocity
    familiar.Position = familiar.Player.Position
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, lightFamUpdate, LIGHT_FAM_ID)
--]]