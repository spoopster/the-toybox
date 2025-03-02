local mod = MilcomMOD

mod.DONT_IGNORE_ATLAS_HEALING = false

--#region DATA
local ATLAS_A_BASEDATA = {
    CHARACTER_SIDE = "A",

    HP_CAP = 3,
    MANTLES = {
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=mod.MANTLE_DATA.DEFAULT.HP, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), DATA={}, },
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=mod.MANTLE_DATA.DEFAULT.HP, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), DATA={}, },
        { TYPE=mod.MANTLE_DATA.DEFAULT.ID, HP=mod.MANTLE_DATA.DEFAULT.HP, MAXHP=mod.MANTLE_DATA.DEFAULT.HP, COLOR=Color(1,1,1,1), DATA={}, },
    },
    TRANSFORMATION = mod.MANTLE_DATA.DEFAULT.ID,
    BIRTHRIGHT_TRANSFORMATION = mod.MANTLE_DATA.NONE.ID,
    TIME_HAS_BEEN_IN_TRANSFORMATION = 0,
    MANTLE_SHARDS = {},

    SALT_CHARIOT_ENABLED = false,
    SALT_EASTEREGG = false,

    HOLY_SIZE = 1,

    MARKED_FOR_DEATH_DEVILDEAL = 0,
}

mod.ATLAS_A_BASEDATA = ATLAS_A_BASEDATA
--mod.ATLAS_A_DATA = {}
--#endregion

---@param player EntityPlayer
local function postAtlasInit(_, player)
    if(not mod:isAtlasA(player)) then return end
    mod:updateMantles(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postAtlasInit)

---@param player EntityPlayer
local function postAtlasUpdate(_, player)
    if(not mod:isAtlasA(player)) then return end
    if(not (player:IsFootstepFrame(-1) and player.Velocity:Length()>1)) then return end

    local splat = Isaac.Spawn(1000,7,1,player.Position,Vector.Zero,player):ToEffect()
    splat.SpriteScale = Vector(1,1)*0.2
    splat.Color = Color(59/255, 56/255, 67/255, 0.5)

    splat:Update()
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postAtlasUpdate)

---@param player EntityPlayer
local function postAtlasRender(_, player)
    if(not mod:isAtlasA(player)) then return end
    --! FOR TESTING PURPOSES, DELETE ON RELEASE
    --if(mod.ATLAS_A_DATA[player.InitSeed]==nil) then mod.ATLAS_A_DATA[player.InitSeed] = mod:cloneTable(mod.ATLAS_A_BASEDATA) end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postAtlasRender)

local function cancelHeartCollision(_, pickup, player)
    if(not (player and player:ToPlayer() and mod:isAtlasA(player:ToPlayer()))) then return end
    return false
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, cancelHeartCollision, PickupVariant.PICKUP_HEART)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not mod:isAtlasA(player)) then return end
    
    if(flag==CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = Color(0.2,0.2,0.2,1,0,0,0)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function badsifbaf(_, pl)
    return 6
end
mod:AddPriorityCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, math.huge, badsifbaf, mod.PLAYER_TYPE.ATLAS_A)
mod:AddPriorityCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, math.huge, badsifbaf, mod.PLAYER_TYPE.ATLAS_A_TAR)

local function bibidibabidibu(_, pl)
    return HealthType.DEFAULT
end
mod:AddPriorityCallback(ModCallbacks.MC_PLAYER_GET_HEALTH_TYPE, math.huge, bibidibabidibu, mod.PLAYER_TYPE.ATLAS_A)
mod:AddPriorityCallback(ModCallbacks.MC_PLAYER_GET_HEALTH_TYPE, math.huge, bibidibabidibu, mod.PLAYER_TYPE.ATLAS_A_TAR)

---@param player EntityPlayer
local function forceHealth(_, player)
    if(not mod:isAtlasA(player)) then return end

    mod.DONT_IGNORE_ATLAS_HEALING = true
    if(player:GetMaxHearts()<6) then
        player:AddMaxHearts(6)
    end
    if(player:GetHearts()<6) then
        player:AddHearts(6)
    end
    mod.DONT_IGNORE_ATLAS_HEALING = false
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, math.huge, forceHealth, 0)