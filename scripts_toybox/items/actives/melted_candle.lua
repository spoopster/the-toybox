local FIRE_DMG = 5

---@param player EntityPlayer
local function useMeltedCandle(_, _, rng, player, flags)
    local dir = (player:GetShootingJoystick():Length()<0.1 and player.Velocity or player:GetShootingJoystick())
    local helper = Isaac.Spawn(EntityType.ENTITY_EFFECT, ToyboxMod.EFFECT_VARIANT.FLAME_BREATH_HELPER, 0, player.Position, dir, player):ToEffect()
    helper.CollisionDamage = FIRE_DMG

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useMeltedCandle, ToyboxMod.COLLECTIBLE_MELTED_CANDLE)