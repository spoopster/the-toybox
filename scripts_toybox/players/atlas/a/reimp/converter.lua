local mod = ToyboxMod
local sfx = SFXManager()

mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.IMPORTANT,
---@param rng RNG
---@param player EntityPlayer
function(_, _, rng, player, flags, slot)
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)

    if(data.MANTLES[1].TYPE~=mod.MANTLE_DATA.NONE.ID) then
        local oldType = data.MANTLES[1].TYPE
        local newType = mod:getRandomMantle(rng, true)
        while(newType==oldType) do newType=mod:getRandomMantle(rng, true) end

        mod:setMantleType(player, 1, 0, mod.MANTLE_DATA.NONE.ID)
        mod:setMantleType(player, data.HP_CAP, nil, newType)
        mod:spawnShardsForMantle(player, mod:getRightmostMantleIdx(player), 5)

        if(flags & UseFlag.USE_NOANIM == 0) then
            player:AnimateCollectible(CollectibleType.COLLECTIBLE_CONVERTER, "UseItem")
        end
    end

    return true
end,
CollectibleType.COLLECTIBLE_CONVERTER)