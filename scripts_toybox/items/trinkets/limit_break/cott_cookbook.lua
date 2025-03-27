local mod = ToyboxMod
--* Troll bombs spawned by the item(s) do not damage the player that spawned them

---@param player EntityPlayer
---@param source EntityRef
local function cancelTrollBombDamage(_, player, dmg, flags, source)
    if(not mod:playerHasLimitBreak(player)) then return end
    local ent = source.Entity
    if(not (ent and ent.Type==EntityType.ENTITY_BOMB and ent.Variant==BombVariant.BOMB_TROLL)) then return end

    if(ent.SpawnerEntity and GetPtrHash(ent.SpawnerEntity)==GetPtrHash(player)) then return false end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, cancelTrollBombDamage)