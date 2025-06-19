

local CHANCE_INCREASE = 1 -- increase per mult

ToyboxMod:addGoldenChance(
    function(val)
        return val*(1+CHANCE_INCREASE*PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_WONDER_DRUG))
    end,
    function()
        return PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_WONDER_DRUG)
    end
)
ToyboxMod:addHorseChance(
    function(val)
        return val*(1+CHANCE_INCREASE*PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_WONDER_DRUG))
    end,
    function()
        return PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_WONDER_DRUG)
    end
)