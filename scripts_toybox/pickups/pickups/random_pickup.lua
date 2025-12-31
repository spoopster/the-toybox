---@param pickup EntityPickup
local function replaceWithRandom(_, pickup)
    local rng = pickup:GetDropRNG()
    if(pickup.SubType==ToyboxMod.PICKUP_RANDOM_MANTLE) then
        local mantle = ToyboxMod:getRandomMantle(rng, false, true)
        pickup:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,mantle,true)
    elseif(pickup.SubType==ToyboxMod.PICKUP_RANDOM_MANTLE_NOBIAS) then
        local mantle = ToyboxMod:getRandomMantle(rng, true, true)
        pickup:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,mantle,true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, replaceWithRandom, ToyboxMod.PICKUP_RANDOM_SELECTOR)