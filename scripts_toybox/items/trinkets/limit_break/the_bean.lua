
--* Spawns an additional poison gas cloud that lasts for 10 seconds

---@param player EntityPlayer
---@param rng RNG
local function useItem(_, item, rng, player, flags, slot, vdata)
    if(not ToyboxMod:playerHasLimitBreak(player)) then return end

    local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
    cloud:SetTimeout(30*10)
    cloud.SpriteScale = Vector(1,1)*2.5
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useItem, CollectibleType.COLLECTIBLE_BEAN)