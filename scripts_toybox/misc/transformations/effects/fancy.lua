local NUM_COINS_TO_GIVE = 30

local function getFancyTransformation(_, pl, firstTime)
    if(not firstTime) then return end

    pl:AddCoins(NUM_COINS_TO_GIVE)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GET_CUSTOM_TRANSFORMATION, getFancyTransformation, "FANCY")