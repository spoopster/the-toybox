local CHEST_CHANCE = 0.5

---@param npc EntityNPC
local function shopkeeperInit(_, npc)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_LOOTBOX)) then return end

    local rng = npc:GetDropRNG()
    if(rng:RandomFloat()<CHEST_CHANCE*PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_LOOTBOX)) then
        local chestvar = ToyboxMod.CHEST_PICKER:PickOutcome(rng)
        local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP,chestvar,0,npc.Position,Vector.Zero,nil):ToPickup()
        chest:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

        npc:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, shopkeeperInit, EntityType.ENTITY_SHOPKEEPER)