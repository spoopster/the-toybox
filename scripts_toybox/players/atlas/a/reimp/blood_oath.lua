

---@param fam EntityFamiliar
local function familiarUpdate(_, fam)
    local pl = fam.Player
    if(not ToyboxMod:isAtlasA(pl)) then return end

    if(fam:GetSprite():IsEventTriggered("Hit")) then
        local totalMantleHp = 0
        local data = ToyboxMod:getAtlasATable(pl)
        for i=1, data.HP_CAP do
            totalMantleHp = totalMantleHp+data.MANTLES[i].HP
        end

        pl:TakeDamage(totalMantleHp, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(fam), 30)
        fam.Hearts = fam.Hearts+totalMantleHp
        
        return true
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, familiarUpdate, FamiliarVariant.BLOOD_OATH)