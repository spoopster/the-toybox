local MIN_PICKUPS = 3
local INCR_MULT = 1

local function giveMinPickups(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_LIFETIME_SUPPLY)) then return end

    local pl = PlayerManager.FirstTrinketOwner(ToyboxMod.TRINKET_LIFETIME_SUPPLY)
    local minnum = MIN_PICKUPS+INCR_MULT*(PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_LIFETIME_SUPPLY)-1)
    
    pl:AddKeys(math.max(0, minnum-pl:GetNumKeys()))
    pl:AddBombs(math.max(0, minnum-pl:GetNumBombs()))
    pl:AddCoins(math.max(0, minnum-pl:GetNumCoins()))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, giveMinPickups)