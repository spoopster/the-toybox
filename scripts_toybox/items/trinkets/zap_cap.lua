local HITS_REQ = 40
local STACK_REQ_DECREASE = 10

local DMG_MULT = 6
local FLAT_DMG = 15

---@param ent Entity
local function addToCounter(_, ent, amount, _, _, _)
    if(not (ent and ent:Exists() and ToyboxMod:isValidEnemy(ent))) then return end

    local data = ToyboxMod:getExtraDataTable()
    data.ZAP_CAP_COUNTER = (data.ZAP_CAP_COUNTER or 0)+1

    local mult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_ZAP_CAP)
    if(mult>0) then
        local req = math.max(10, HITS_REQ-STACK_REQ_DECREASE*(mult-1))

        if(data.ZAP_CAP_COUNTER>=req) then
            data.ZAP_CAP_COUNTER = 0

            local dmg = amount*DMG_MULT+FLAT_DMG
            Isaac.Explode(ent.Position, PlayerManager.FirstTrinketOwner(ToyboxMod.TRINKET_ZAP_CAP), dmg)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, addToCounter)