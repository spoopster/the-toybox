---@param player EntityPlayer
local function usePliers(_, _, rng, player, flags)
    player:ResetDamageCooldown()
    player:TakeDamage(1, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(nil), 30)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, usePliers, ToyboxMod.COLLECTIBLE_PLIERS)