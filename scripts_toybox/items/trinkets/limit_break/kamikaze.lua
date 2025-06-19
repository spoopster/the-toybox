
--* Explosion inherits bomb effects

---@param player EntityPlayer
local function kamikazeUse(_, item, rng, player)
    if(not ToyboxMod:playerHasLimitBreak(player)) then return end
    
    local bomb = player:FireBomb(player.Position, Vector.Zero, player)
    bomb.Visible = false
    bomb:SetExplosionCountdown(0)
    bomb.ExplosionDamage = 0
    bomb:Update()
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, kamikazeUse, CollectibleType.COLLECTIBLE_KAMIKAZE)