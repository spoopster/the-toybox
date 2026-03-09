

local COINS_CONSUME = 3

local BIAS_MAX_DIF = 10
local BIAS_MAX_CHANCE_MOD = 0.25

---@param pl EntityPlayer
---@param rng RNG
local function useDeliveryBox(_, _, rng, pl, flag, slot, varData)
    if(pl:GetNumCoins()>=COINS_CONSUME) then
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

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    else
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
    end

    
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useDeliveryBox, ToyboxMod.COLLECTIBLE_DELIVERY_BOX)

---@param player EntityPlayer
local function renderUnder(_, player, slot, offset, a, scale)
    if(player:GetNumCoins()<COINS_CONSUME) then
        return {
            HideOutline = true,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, renderUnder, ToyboxMod.COLLECTIBLE_DELIVERY_BOX)