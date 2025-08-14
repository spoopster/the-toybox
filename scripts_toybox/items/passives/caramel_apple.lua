
local sfx = SFXManager()

local HEART_UPGRADE_CHANCE = 0.33

local HEART_UPGRADE_TABLE = {
    [HeartSubType.HEART_HALF] = HeartSubType.HEART_FULL,
    --[HeartSubType.HEART_FULL] = HeartSubType.HEART_DOUBLEPACK,
    [HeartSubType.HEART_HALF_SOUL] = HeartSubType.HEART_SOUL,
}

local UPGRADING_HEART = false
---@param pickup EntityPickup
local function heartInit(_, pickup)
    if(UPGRADING_HEART) then return end
    if(not HEART_UPGRADE_TABLE[pickup.SubType]) then return end

    if(pickup:GetSprite():GetAnimation()~="Appear") then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_CARAMEL_APPLE)) then return end
    
    --local chance = HEART_UPGRADE_CHANCE*PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_CARAMEL_APPLE)
    --if(pickup:GetDropRNG():RandomFloat()<chance) then
        UPGRADING_HEART = true

        pickup:Morph(pickup.Type,pickup.Variant,HEART_UPGRADE_TABLE[pickup.SubType],true,true)

        UPGRADING_HEART = false
    --end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, heartInit, PickupVariant.PICKUP_HEART)