
local sfx = SFXManager()

---@param player EntityPlayer
local function gildedAppleUse(_, item, rng, player, flags, slot, vdata)
    sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
    player:AddGoldenHearts(1)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, gildedAppleUse, ToyboxMod.COLLECTIBLE_GILDED_APPLE)