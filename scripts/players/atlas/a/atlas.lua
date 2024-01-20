local mod = MilcomMOD

--#region DATA
local ATLAS_A_BASEDATA = {
    CHARACTER_SIDE = "A",

    MANTLES = {
        mod.MANTLES.DEFAULT,
        mod.MANTLES.DEFAULT,
        mod.MANTLES.DEFAULT,
    },
    TRANSFORMATION = mod.MANTLES.NONE,
}

mod.ATLAS_A_BASEDATA = ATLAS_A_BASEDATA
mod.ATLAS_A_DATA = {}

---@param player EntityPlayer
local function postAtlasInit(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postAtlasInit)

---@param player EntityPlayer
local function postAtlasUpdate(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postAtlasUpdate)

---@param player EntityPlayer
local function postAtlasRender(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    --! FOR TESTING PURPOSES, DELETE ON RELEASE
    if(mod.ATLAS_A_DATA[player.InitSeed]==nil) then mod.ATLAS_A_DATA[player.InitSeed] = mod:cloneTable(mod.ATLAS_A_BASEDATA) end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postAtlasRender)

local function replaceAtlasPeeStain(_)
    local splat = Isaac.FindByType(1000,7,0)[1]
    
    if(splat and mod:isAnyPlayerAtlasA()) then
        splat.Color = Color(0,0,0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, replaceAtlasPeeStain)