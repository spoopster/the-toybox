local mod = MilcomMOD

---@param player EntityPlayer
local function gildedAppleUse(_, item, rng, player, flags, slot, vdata)
    SFXManager():Play(SoundEffect.SOUND_CASH_REGISTER)
    player:AddGoldenHearts(1)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, gildedAppleUse, mod.COLLECTIBLE_GILDED_APPLE)