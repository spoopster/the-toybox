local EXTRA_USE_CHANCE = 0.5

---@param ent Entity
local function applyPenalty(_, ent, _, flags, source)
    local player = ent:ToPlayer() ---@type EntityPlayer
    if(not (player and player:HasTrinket(ToyboxMod.TRINKET_SWALLOWED_D10))) then return end

    for _=1, player:GetTrinketMultiplier(ToyboxMod.TRINKET_SWALLOWED_D10) do
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D10, UseFlag.USE_NOANIM)
    end
    ToyboxMod.GAME:ShakeScreen(10)
    --ToyboxMod.SFX:Play
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, applyPenalty, EntityType.ENTITY_PLAYER)