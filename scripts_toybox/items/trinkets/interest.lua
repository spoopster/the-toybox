local INTEREST_PERCENT = 1/3
local MULT_PERCENT_ADD = 1/3

local MIN_COINS_GIVE = 3

local function giveMinPickups(_)
    if(not ToyboxMod.GAME:GetRoom():IsFirstVisit()) then return end
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_INTEREST)) then return end

    local pl = PlayerManager.FirstTrinketOwner(ToyboxMod.TRINKET_INTEREST)
    local mult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_INTEREST)

    pl:AddCoins(math.max(MIN_COINS_GIVE, math.floor(pl:GetNumCoins()*(INTEREST_PERCENT+(mult-1)*MULT_PERCENT_ADD)+0.5)))

    ToyboxMod.SFX:Play(SoundEffect.SOUND_CASH_REGISTER)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, giveMinPickups)