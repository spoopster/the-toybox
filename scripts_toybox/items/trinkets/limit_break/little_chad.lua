local mod = ToyboxMod
--* Spawns full red hearts instead of half red hearts

---@param pickup EntityPickup
local function CHADHeartInit(_, pickup)
    if(pickup.SubType~=HeartSubType.HEART_HALF) then return end
    local sp = pickup.SpawnerEntity
    if(sp and sp.Type==EntityType.ENTITY_FAMILIAR and sp.Variant==FamiliarVariant.LITTLE_CHAD) then
        if(not mod:playerHasLimitBreak(sp:ToFamiliar().Player)) then return end

        local newSubType = HeartSubType.HEART_FULL
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, newSubType)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, CHADHeartInit, PickupVariant.PICKUP_HEART)