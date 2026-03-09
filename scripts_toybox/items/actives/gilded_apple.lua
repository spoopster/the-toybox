
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

---@param pl EntityPlayer
---@param slot EntitySlot
local function renderWhiteDaisy(_, pl, slot)
    return {
        HideOutline = true,
        CropOffset = Vector(32*(pl:GetActiveCharge(slot)>=pl:GetActiveMaxCharge(slot) and 1 or 0),0),
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, renderWhiteDaisy, ToyboxMod.COLLECTIBLE_GILDED_APPLE)