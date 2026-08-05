---@param player EntityPlayer
---@param rng RNG
local function usePick(_, _, rng, player, flags)
    local room = ToyboxMod.GAME:GetRoom()
    local pos = room:FindFreePickupSpawnPosition(player.Position,40)

    room:SpawnGridEntity(room:GetGridIndex(pos), GridEntityType.GRID_PRESSURE_PLATE, PressurePlateVariant.REWARD)

    ToyboxMod.SFX:Play(SoundEffect.SOUND_BUTTON_PRESS)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, usePick, ToyboxMod.COLLECTIBLE_INSTANT_GRATIFICATION)