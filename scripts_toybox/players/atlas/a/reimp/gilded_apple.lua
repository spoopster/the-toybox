local mod = ToyboxMod
local sfx = SFXManager()

mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.IMPORTANT,
---@param rng RNG
---@param player EntityPlayer
function(_, _, rng, player, flags, slot)
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)

    if(data.MANTLES[data.HP_CAP].TYPE~=mod.MANTLE_DATA.NONE.ID) then
        mod:setMantleType(player, 1, 0, mod.MANTLE_DATA.NONE.ID)
    end
    mod:setMantleType(player, data.HP_CAP, nil, mod.MANTLE_DATA.GOLD.ID)

    mod:spawnShardsForMantle(player, mod:getRightmostMantleIdx(player), 5)

    if(flags & UseFlag.USE_NOANIM == 0) then
        player:AnimateCollectible(mod.COLLECTIBLE.GILDED_APPLE, "UseItem")
    end
    sfx:Play(SoundEffect.SOUND_CASH_REGISTER)

    return true
end,
mod.COLLECTIBLE.GILDED_APPLE)