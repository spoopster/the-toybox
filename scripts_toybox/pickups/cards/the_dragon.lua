local sfx = SFXManager()

local NUM_HEARTS = 2
local NUM_HEARTS_TCLOTH = 3

---@param pl EntityPlayer
local function useTheDragon(_, _, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    local room = Game():GetRoom()
    for _=1, ((flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) and NUM_HEARTS_TCLOTH or NUM_HEARTS) do
        local pos = room:FindFreePickupSpawnPosition(pl.Position, 40)
        local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN, pos, Vector.Zero, nil):ToPickup()
    end

    sfx:Play(ToyboxMod.SFX_BREATH, 1, 2, false, math.random()*0.1+0.95)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheDragon, ToyboxMod.CARD_THE_DRAGON)