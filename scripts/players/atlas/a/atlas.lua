local mod = MilcomMOD

--* TODO:
-- polish mantle effects a bit
-- hopefully wait for 1.0.6 to add player healing hook

--#region DATA
local ATLAS_A_BASEDATA = {
    CHARACTER_SIDE = "A",

    HP_CAP = 3,
    -- [[
    MANTLES = {
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=mod.MANTLE_DATA.DEFAULT.HP, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), },
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=mod.MANTLE_DATA.DEFAULT.HP, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), },
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=mod.MANTLE_DATA.DEFAULT.HP, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), },
    },
    --]]
    --[[
    MANTLES = {
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=0, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), },
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=0, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), },
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=0, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), },
    },
    --]]
    TRANSFORMATION = mod.MANTLE_DATA.TAR.ID,
    BIRTHRIGHT_TRANSFORMATION = mod.MANTLE_DATA.NONE.ID,
    TIME_HAS_BEEN_IN_TRANSFORMATION = 0,
    MANTLE_SHARDS = {},

    SALT_AUTOTARGET_ENABLED = false,
}

mod.ATLAS_A_BASEDATA = ATLAS_A_BASEDATA
mod.ATLAS_A_DATA = {}

---@param player EntityPlayer
local function postAtlasInit(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    mod:updateMantles(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postAtlasInit)

---@param player EntityPlayer
local function postAtlasUpdate(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    if(not (player:IsFootstepFrame(-1) and player.Velocity:Length()>1)) then return end

    local splat = Isaac.Spawn(1000,7,1,player.Position,Vector.Zero,player):ToEffect()
    splat.SpriteScale = Vector(1,1)*0.2
    splat.Color = Color(59/255, 56/255, 67/255, 0.5)

    splat:Update()
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postAtlasUpdate)

---@param player EntityPlayer
local function postAtlasRender(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    --! FOR TESTING PURPOSES, DELETE ON RELEASE
    if(mod.ATLAS_A_DATA[player.InitSeed]==nil) then mod.ATLAS_A_DATA[player.InitSeed] = mod:cloneTable(mod.ATLAS_A_BASEDATA) end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postAtlasRender)

local function cancelHeartCollision(_, pickup, player)
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    return false
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, -1e12+1, cancelHeartCollision, PickupVariant.PICKUP_HEART)