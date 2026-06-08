local TIME_MIN = -3
local TIME_MAX = 3

---@param player EntityPlayer
local function useD(_, _, rng, player, flags)
    local timeToAdd = (rng:RandomFloat()-0.5)*2
    timeToAdd = (((timeToAdd<0 and -1 or 1)*math.abs(timeToAdd)^2)*0.5)+0.5
    ToyboxMod.GAME.TimeCounter = math.max(0, ToyboxMod.GAME.TimeCounter+math.floor(60*30*(timeToAdd*(TIME_MAX-TIME_MIN)+TIME_MIN)))

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useD, ToyboxMod.COLLECTIBLE_D)



-- < BOOK OF VIRTUES > --

local WISP_TIMER_REMOVE = 30*15 -- 15 seconds

---@param fam EntityFamiliar
local function virtuesWispDeath(_, fam)
    if(not (fam.Variant==FamiliarVariant.WISP and fam.SubType==ToyboxMod.COLLECTIBLE_D)) then return end

    ToyboxMod.GAME.TimeCounter = math.max(0, ToyboxMod.GAME.TimeCounter-WISP_TIMER_REMOVE)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, virtuesWispDeath, EntityType.ENTITY_FAMILIAR)