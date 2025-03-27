local mod = ToyboxMod

--#region DATA
local JONAS_A_BASEDATA = {
    CHARACTER_SIDE = "A",

    PILLS_POPPED = 0,
    PILL_BONUS_COUNT = 0,

    PILLS_FOR_BONUS = 1,
    PILLS_FOR_NEXT_BONUS = 1,
    PILLS_FOR_BONUS_BASE = 1,
    PILLBONUS_INCREMENT = 0,--3,
    --PILLBONUS_INCREMENT_EXTRA = 5,
    --PILLBONUS_EXTRA_REQ = 3,
    PILLBONUS_INCREMENT_BONUSES = 1,

    PILBONUS_GOLD_MULT = 0.2,
    PILBONUS_HORSE_MULT = 2,

    PILLBONUS_SPEED = 0.1,
    PILLBONUS_TEARS = 0.35,
    PILLBONUS_DMG = 0.5,
    PILLBONUS_RANGE = 0.5,
    PILLBONUS_SHOTSPEED = 0.04,
    PILLBONUS_LUCK = 0.7,

    PILLBONUS_DIMINISHING_POW = 0.65,

    RESET_BOOST_ROOMS = 0,
    RESET_BOOST_ROOMSREQ = 4,
    RESET_BOOST_ROOMSREQ_GREED = 5,
    RESET_BOOST_SHAKEINTENSITY = 0.25,
    RESET_BOOST_SHAKECLOSENESS = 1,

    NEWFLOOR_MULT = 1/3,

    MONSTER_PILLDROP_CHANCE = 0.05,-- 0.0777, -- 7.77%
    BIRTHRIGHT_PILLDROP_CHANCE = 0.075,
    BIRTHRIGHT_CARD_CHANCE = 0.20,

    --BAD_PILLNUM = 3,
    --NEUTRAL_PILLNUM = 4,
    --GOOD_PILLNUM = 6,

    --LAST_PHD_VAL = nil,
}

mod.JONAS_A_BASEDATA = JONAS_A_BASEDATA
--mod.JONAS_A_DATA = {}
--#endregion

local canRerollPool = true
local function resetPoolRerollPleaseee(_)
    canRerollPool = true
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, resetPoolRerollPleaseee)

---@param player EntityPlayer
local function postJonasInit(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_TYPE.JONAS_A) then return end

    --make pill pool
    if(Game():GetFrameCount()==0 or not mod:getExtraData("CUSTOM_PILL_POOL")) then
        local data = mod:getJonasATable(player)
        if(canRerollPool) then
            mod:calcPillPool(mod:generateRng())
            canRerollPool = false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postJonasInit)

---@param player EntityPlayer
local function rerollPillPoolNewLevel(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_TYPE.JONAS_A) then return end
    if(player.FrameCount==0) then return end

    local data = mod:getJonasATable(player)
    if(canRerollPool) then
        mod:calcPillPool(mod:generateRng())
        mod:unidentifyPillPool()
        canRerollPool = false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, rerollPillPoolNewLevel)

---@param player EntityPlayer
local function postJonasRender(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_TYPE.JONAS_A) then return end
    --! FOR TESTING PURPOSES, DELETE ON RELEASE
    --if(mod.JONAS_A_DATA[player.InitSeed]==nil) then mod.JONAS_A_DATA[player.InitSeed] = mod:cloneTable(mod.JONAS_A_BASEDATA) end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postJonasRender)

local strokinMyShit = false

local function replaceGoldPillEffect(_, pilleffect, color)
    if(strokinMyShit) then return end

    local dataTable = mod:getExtraDataTable()
    local pillpool = dataTable.CUSTOM_PILL_POOL
    if(pillpool and pillpool~=0 and (color==PillColor.PILL_GOLD or color==PillColor.PILL_GOLD|PillColor.PILL_GIANT_FLAG)) then
        local chosenPlayer = Isaac.GetPlayer()
        local phdVal = mod:getTotalPhdMask()

        if(chosenPlayer:GetPlayerType()==mod.PLAYER_TYPE.JONAS_A) then
            --print("y")
            local rng = mod:generateRng()
            return mod:getRandomPillEffect(rng, chosenPlayer, phdVal, {})
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_GET_PILL_EFFECT, CallbackPriority.LATE-1, replaceGoldPillEffect)