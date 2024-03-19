local mod = MilcomMOD

local ELECTRIFIED_DURATION = 120
local ELECTRIFIED_DMG = 0.5

local TMULT_DURATION_MOD = 1.5

local ELECTRIFIED_CHANCE = 0.15 -- chance to inflict at 0 luck
local ELECTRIFIED_MAXLUCK = 20 -- max luck value for scaling
local ELECTRIFIED_MAXCHANCE = 0.5 -- chance at max luck

local function postNewRoom(_)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(mod:isValidEnemy(ent)) then
            local willElectrify = nil

            for i=0, Game():GetNumPlayers()-1 do
                local p = Isaac.GetPlayer(i)
                local tMult = p:GetTrinketMultiplier(mod.TRINKET_PLASMA_GLOBE)

                if(tMult>0 and p:GetTrinketRNG(mod.TRINKET_PLASMA_GLOBE):RandomFloat()<mod:getLuckAffectedChance(p.Luck, ELECTRIFIED_CHANCE, ELECTRIFIED_MAXLUCK, ELECTRIFIED_MAXCHANCE)) then
                    willElectrify = {p,tMult}
                    break
                end
            end

            if(willElectrify) then
                mod:addElectrified(ent, willElectrify[1], math.floor(ELECTRIFIED_DURATION*(TMULT_DURATION_MOD^(willElectrify[2]-1)))*(willElectrify[1]:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND)+1), ELECTRIFIED_DMG)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
