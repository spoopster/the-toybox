local EARWORM_DURATION = 10*30

local EARWORM_CHANCE = 0.15 -- chance to inflict at 0 luck
local EARWORM_CHANCEMULT = 0.10
local EARWORM_MAXLUCK = 30 -- max luck value for scaling
local EARWORM_MAXCHANCE = 1 -- chance at max luck

local function postNewRoom(_)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_EARWORM)) then return end

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ent:Exists() and ent:IsEnemy()) then
            local willEarworm = false
            local earwormPlayer = nil

            for i=0, Game():GetNumPlayers()-1 do
                local p = Isaac.GetPlayer(i)
                if(p:HasTrinket(ToyboxMod.TRINKET_EARWORM)) then
                    local mult = p:GetTrinketMultiplier(ToyboxMod.TRINKET_EARWORM)
                    local chance = ToyboxMod:getLuckAffectedChance(p.Luck, EARWORM_CHANCE+EARWORM_CHANCEMULT*(mult-1), EARWORM_MAXLUCK, EARWORM_MAXCHANCE)
                    local rng = p:GetTrinketRNG(ToyboxMod.TRINKET_EARWORM)

                    if(rng:RandomFloat()<chance) then
                        willEarworm = true
                        earwormPlayer = p
                        break
                    end
                end
            end

            if(willEarworm) then
                ToyboxMod:applyEarworm(ent, EARWORM_DURATION, EntityRef(earwormPlayer))
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)