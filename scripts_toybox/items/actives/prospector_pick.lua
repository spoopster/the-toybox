local sfx = SFXManager()

---@param player EntityPlayer
---@param rng RNG
local function usePick(_, _, rng, player, flags)
    local room = Game():GetRoom()
    local pos = room:FindFreePickupSpawnPosition(player.Position,10)

    local grid = room:GetGridEntityFromPos(player.Position)
    if(grid and grid:GetType()==GridEntityType.GRID_DECORATION) then
        local pickup = Isaac.Spawn(5, ToyboxMod.PICKUP_RANDOM_SELECTOR, ToyboxMod.PICKUP_RANDOM_MANTLE, pos, Vector.Zero, nil):ToPickup()
    else
        local pool = Game():GetItemPool()
        local sub = pool:GetCard(math.max(1, rng:Next()), false, true, true)

        local pickup = Isaac.Spawn(5, PickupVariant.PICKUP_TAROTCARD, sub, pos, Vector.Zero, nil):ToPickup()
    end

    sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, usePick, ToyboxMod.COLLECTIBLE_PROSPECTORS_PICK)