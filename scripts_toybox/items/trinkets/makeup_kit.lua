---@param slot EntitySlot
local function donationMachineInit(_, slot)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_MAKEUP_KIT)) then return end

    local newSlot = Isaac.Spawn(EntityType.ENTITY_SLOT, SlotVariant.MOMS_DRESSING_TABLE, 0, slot.Position, slot.Velocity, slot.SpawnerEntity)
    slot:Remove()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, donationMachineInit, SlotVariant.DONATION_MACHINE)