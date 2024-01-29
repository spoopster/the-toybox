local mod = MilcomMOD

--* TODO:
-- polish mantle effects a bit
-- add functionality for healing items

--#region DATA
local ATLAS_A_BASEDATA = {
    CHARACTER_SIDE = "A",

    HP_CAP = 3,
    MANTLES = {
        { TYPE=mod.MANTLES.DEFAULT, HP=mod.MANTLES_HP.DEFAULT, MAXHP=mod.MANTLES_HP.DEFAULT, },
        { TYPE=mod.MANTLES.DEFAULT, HP=mod.MANTLES_HP.DEFAULT, MAXHP=mod.MANTLES_HP.DEFAULT, },
        { TYPE=mod.MANTLES.DEFAULT, HP=mod.MANTLES_HP.DEFAULT, MAXHP=mod.MANTLES_HP.DEFAULT, },
    },
    TRANSFORMATION = mod.MANTLES.DEFAULT,
    BIRTHRIGHT_TRANSFORMATION = mod.MANTLES.NONE,
    TIME_HAS_BEEN_IN_TRANSFORMATION = 0,
    MANTLE_SHARDS = {},

    SALT_AUTOTARGET_ENABLED = false,
}

mod.ATLAS_A_BASEDATA = ATLAS_A_BASEDATA
mod.ATLAS_A_DATA = {}

---@param player EntityPlayer
local function postAtlasInit(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)

    player:AddNullCostume(mod.TAR_COSTUME)

    mod:updateMantles(player)
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

-- [[
local function replaceAtlasPeeStain(_, effect)
    if(not mod:isAnyPlayerAtlasA()) then return end
    if(effect.FrameCount~=0) then return end

    local tint = effect:GetColor():GetOffset()
    local isYellow = (tint.R>0.001 and tint.G>0.001 and math.abs(tint.R-tint.G)<0.001) and (tint.B<0.001)

    if(isYellow and math.abs(tint.R-244/255)<0.001) then
        if(mod:anyAtlasAHasTransformation(mod.MANTLES.TAR)) then effect.Color = Color(0,0,0)
        elseif(mod:anyAtlasAHasTransformation(mod.MANTLES.POOP)) then effect.Color = Color(0,0,0,1,124/255,86/255,52/255)
        else effect:Remove() end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, replaceAtlasPeeStain, EffectVariant.BLOOD_SPLAT)
-- ]]

local function cancelHeartCollision(_, pickup, player)
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    
    return false
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 1e6, cancelHeartCollision, PickupVariant.PICKUP_HEART)