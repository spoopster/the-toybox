

local PILL_POOP_CHANCE = 0.2

local function replaceDropWithPill(_, pickup, poop)
    local numTrinkets = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_SUPPOSITORY)
    if(numTrinkets==0) then return end

    local rng = ToyboxMod:generateRng(poop.Desc.SpawnSeed)
    if(pickup and rng:RandomFloat()<numTrinkets*PILL_POOP_CHANCE) then
        return {
            Type = 5,
            Variant = 70,
            SubType = 0,
        }
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POOP_SPAWN_DROP, replaceDropWithPill)