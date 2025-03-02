local mod = MilcomMOD

local PILL_POOP_CHANCE = 0.2

local function replaceDropWithPill(_, pickup, poop)
    local numTrinkets = PlayerManager.GetTotalTrinketMultiplier(mod.TRINKET.SUPPOSITORY)
    if(numTrinkets==0) then return end

    local rng = mod:generateRng(poop.Desc.SpawnSeed)
    if(pickup and rng:RandomFloat()<numTrinkets*PILL_POOP_CHANCE) then
        return {
            Type = 5,
            Variant = 70,
            SubType = 0,
        }
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POOP_SPAWN_DROP, replaceDropWithPill)