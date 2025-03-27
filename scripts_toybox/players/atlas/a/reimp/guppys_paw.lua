local mod = ToyboxMod
local sfx = SFXManager()

mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.IMPORTANT,
---@param rng RNG
---@param player EntityPlayer
function(_, _, rng, player, flags, slot)
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)

    if(data.MANTLES[1].TYPE~=mod.MANTLE_DATA.NONE.ID) then
        mod:setMantleType(player, 1, 0, mod.MANTLE_DATA.NONE.ID)
        mod:setMantleType(player, data.HP_CAP, 1, mod.MANTLE_DATA.METAL.ID)

        mod:spawnShardsForMantle(player, mod:getRightmostMantleIdx(player), 5)

        if(flags & UseFlag.USE_NOANIM == 0) then
            player:AnimateCollectible(CollectibleType.COLLECTIBLE_GUPPYS_PAW, "UseItem")
        end
        sfx:Play(SoundEffect.SOUND_VAMP_GULP)
    end

    return true
end,
CollectibleType.COLLECTIBLE_GUPPYS_PAW)