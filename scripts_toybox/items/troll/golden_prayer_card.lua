

---@param player EntityPlayer
local function goldenPrayerCardUse(_, item, rng, player, flags, slot, vdata)
    local freePos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 80)
    Isaac.Spawn(5,ToyboxMod.PICKUP_ETERNAL_MOUND,0,freePos,Vector.Zero,nil):ToPickup()

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, goldenPrayerCardUse, ToyboxMod.COLLECTIBLE_GOLDEN_PRAYER_CARD)