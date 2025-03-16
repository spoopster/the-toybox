local mod = ToyboxMod

local CHANCE_INCREASE = 1 -- increase per mult

mod:addGoldenChance(
    function(val)
        return val*(1+CHANCE_INCREASE*PlayerManager.GetTotalTrinketMultiplier(mod.TRINKET.WONDER_DRUG))
    end,
    function()
        return PlayerManager.AnyoneHasTrinket(mod.TRINKET.WONDER_DRUG)
    end
)
mod:addHorseChance(
    function(val)
        return val*(1+CHANCE_INCREASE*PlayerManager.GetTotalTrinketMultiplier(mod.TRINKET.WONDER_DRUG))
    end,
    function()
        return PlayerManager.AnyoneHasTrinket(mod.TRINKET.WONDER_DRUG)
    end
)