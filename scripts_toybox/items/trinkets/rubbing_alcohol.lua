local INITIAL_INCREASE = 1
local MULT_INCREASE = 0.5

---@param ent Entity
---@param dmg integer
---@param flags DamageFlag
local function increaseDebuffDamage(_, ent, dmg, flags, _, cnt)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_RUBBING_ALCOHOL)) then return end

    if(flags & DamageFlag.DAMAGE_POISON_BURN == DamageFlag.DAMAGE_POISON_BURN) then
        local mult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_RUBBING_ALCOHOL)
        return {
            Damage = dmg*(1+INITIAL_INCREASE+(mult-1)*MULT_INCREASE),
            DamageFlags = flags,
            DamageCountdown = cnt,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, increaseDebuffDamage)