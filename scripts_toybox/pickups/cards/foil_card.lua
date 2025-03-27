local mod = ToyboxMod
local sfx = SFXManager()

local POSSIBLE_SPAWNS = {
    {Type=EntityType.ENTITY_PICKUP, Variant=PickupVariant.PICKUP_HEART, SubType=HeartSubType.HEART_GOLDEN},
    {Type=EntityType.ENTITY_PICKUP, Variant=PickupVariant.PICKUP_COIN, SubType=CoinSubType.COIN_GOLDEN},
    {Type=EntityType.ENTITY_PICKUP, Variant=PickupVariant.PICKUP_BOMB, SubType=BombSubType.BOMB_GOLDEN},
    {Type=EntityType.ENTITY_PICKUP, Variant=PickupVariant.PICKUP_KEY, SubType=KeySubType.KEY_GOLDEN},
}
local PICKER = WeightedOutcomePicker()
PICKER:AddOutcomeFloat(1, 1, 100)
PICKER:AddOutcomeFloat(2, 1, 100)
PICKER:AddOutcomeFloat(3, 1, 100)
PICKER:AddOutcomeFloat(4, 1, 100)

---@param pickup EntityPickup
local function foilCardInit(_, pickup)
    if(pickup.SubType~=mod.CONSUMABLE.FOIL_CARD) then return end

    local sp = pickup:GetSprite()
    --sp:SetRenderFlags(AnimRenderFlags.GOLDEN)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, foilCardInit, PickupVariant.PICKUP_TAROTCARD)

---@param pl EntityPlayer
local function useFoilCard(_, _, pl, _)
    local outcome = PICKER:PickOutcome(pl:GetCardRNG(mod.CONSUMABLE.FOIL_CARD))

    local spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(pl.Position, 40)
    local pickupData = POSSIBLE_SPAWNS[outcome]
    local pickup = Isaac.Spawn(pickupData.Type,pickupData.Variant,pickupData.SubType,spawnPos,Vector.Zero,pl):ToPickup()

    sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useFoilCard, mod.CONSUMABLE.FOIL_CARD)