-- this is so the mod's custom card sets can spawn in a manner that doesnt make them rare as hell
local RANDOM_SELECTOR = WeightedOutcomePicker()
RANDOM_SELECTOR:AddOutcomeFloat(ToyboxMod.PICKUP_RANDOM_MANTLE, 0.25, 100)
RANDOM_SELECTOR:AddOutcomeFloat(ToyboxMod.PICKUP_RANDOM_ALT_TAROT, 1, 100)
RANDOM_SELECTOR:AddOutcomeFloat(ToyboxMod.PICKUP_RANDOM_YU_GI_OH, 0.15, 100)

---@param rng RNG
---@param onlyRunes boolean
local function tryGetNewCard(_, rng, oldId, hasPlaying, hasRunes, onlyRunes)
    if(onlyRunes) then return end

    if(rng:RandomFloat()<ToyboxMod.CONFIG.CUSTOM_CARD_POOL_CHANCE) then
        local selSub = RANDOM_SELECTOR:PickOutcome(rng)
        local selOutcome = ToyboxMod:getRandomPickup(rng, selSub)

        if(selOutcome and selOutcome[2]==PickupVariant.PICKUP_TAROTCARD) then
            return selOutcome[3]
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_GET_CARD, tryGetNewCard)