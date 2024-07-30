local mod = MilcomMOD
local sfx = SFXManager()

--! guppys paw
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

--! converter
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

mod:AddCallback(ModCallbacks.MC_USE_PILL,
---@param player EntityPlayer
function(_, effect, player, flags, color)
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    local right = mod:getRightmostMantleIdx(player)
    if(isHorse) then
        for i=1, right do
            mod:setMantleType(player, i, 1, mod.MANTLE_DATA.BONE.ID)
        end
    else
        mod:setMantleType(player, right, 1, mod.MANTLE_DATA.BONE.ID)
    end
end,
mod.PILL_OSSIFICATION)
