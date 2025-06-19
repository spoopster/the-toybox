

local COINS_CONSUME = 3

local BIAS_MAX_DIF = 10
local BIAS_MAX_CHANCE_MOD = 0.25

---@param pl EntityPlayer
---@param rng RNG
local function useDeliveryBox(_, _, rng, pl, flag, slot, varData)
    local discharge = false

    if(pl:GetNumCoins()>=COINS_CONSUME) then
        discharge = true
        pl:AddCoins(-COINS_CONSUME)

        local quantityDif = (pl:GetNumKeys()-pl:GetNumBombs())/BIAS_MAX_DIF
        quantityDif = ToyboxMod:sign(quantityDif)*math.min(math.abs(quantityDif), 1)

        local pickedVariant
        if(rng:RandomFloat()<0.5+quantityDif*BIAS_MAX_CHANCE_MOD) then
            pickedVariant = PickupVariant.PICKUP_BOMB
        else
            pickedVariant = PickupVariant.PICKUP_KEY
        end

        local spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(pl.Position, 40)
        local spawnedPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, pickedVariant, 0, spawnPos, Vector.Zero, pl):ToPickup()
    end

    return {
        Discharge = discharge,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useDeliveryBox, ToyboxMod.COLLECTIBLE_DELIVERY_BOX)