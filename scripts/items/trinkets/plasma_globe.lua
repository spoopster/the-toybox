local mod = MilcomMOD

local ELECTRIFIED_DURATION = 90
local ELECTRIFIED_DMG = 0.7

local TMULT_DURATION_MOD = 1.5

local ELECTRIFIED_CHANCE = 0.15 -- chance to inflict at 0 luck
local ELECTRIFIED_MAXLUCK = 40 -- luck value where its guaranteed to inflict

local function postNewRoom(_)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(mod:isValidEnemy(ent)) then
            local willElectrify = nil

            for i=0, Game():GetNumPlayers()-1 do
                local p = Isaac.GetPlayer(i)
                local tMult = p:GetTrinketMultiplier(mod.TRINKET_PLASMA_GLOBE)

                if(tMult>0 and p:GetTrinketRNG(mod.TRINKET_PLASMA_GLOBE):RandomFloat()<mod:getLuckAffectedChance(p.Luck, ELECTRIFIED_CHANCE, ELECTRIFIED_MAXLUCK)) then
                    willElectrify = {p,tMult}
                    break
                end
            end

            if(willElectrify) then
                mod:addElectrified(ent, willElectrify[1], math.floor(ELECTRIFIED_DURATION*(TMULT_DURATION_MOD^(willElectrify[2]-1))), ELECTRIFIED_DMG)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
