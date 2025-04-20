local mod = ToyboxMod

---@param player EntityPlayer
local function goldenPrayerCardUse(_, item, rng, player, flags, slot, vdata)
    local freePos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 80)
    Isaac.Spawn(5,mod.PICKUP_VARIANT.ETERNAL_MOUND,0,freePos,Vector.Zero,nil):ToPickup()

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, goldenPrayerCardUse, mod.COLLECTIBLE.GOLDEN_PRAYER_CARD)