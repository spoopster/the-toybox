local IFRAMES_MULT = 2

---@param player Entity
local function doubleIframes(_, player, _, _, _)
    player = player:ToPlayer()
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_SILK_BAG)) then return end

    player:SetMinDamageCooldown(player:GetDamageCooldown()*(1+(IFRAMES_MULT-1)*player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SILK_BAG)))

    player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, math.ceil(player:GetDamageCooldown()/2), true)
    player:ResetDamageCooldown()
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, CallbackPriority.LATE, doubleIframes, EntityType.ENTITY_PLAYER)