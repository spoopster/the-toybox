local mod = ToyboxMod
local sfx = SFXManager()

mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.IMPORTANT,
---@param rng RNG
---@param player EntityPlayer
function(_, _, rng, player, flags, slot)
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)

    mod:addMantleHp(player, 2)

    if(flags & UseFlag.USE_NOANIM == 0) then
        player:AnimateCollectible(CollectibleType.COLLECTIBLE_YUM_HEART, "UseItem")
    end
    sfx:Play(SoundEffect.SOUND_VAMP_GULP)

    return true
end,
CollectibleType.COLLECTIBLE_YUM_HEART)