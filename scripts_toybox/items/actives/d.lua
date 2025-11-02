local TIME_MIN = -3
local TIME_MAX = 3

---@param player EntityPlayer
local function useD(_, _, rng, player, flags)
    local timeToAdd = (rng:RandomFloat()-0.5)*2
    timeToAdd = (((timeToAdd<0 and -1 or 1)*math.abs(timeToAdd)^2)*0.5)+0.5
    Game().TimeCounter = math.max(0, Game().TimeCounter+math.floor(60*30*(timeToAdd*(TIME_MAX-TIME_MIN)+TIME_MIN)))

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useD, ToyboxMod.COLLECTIBLE_D)