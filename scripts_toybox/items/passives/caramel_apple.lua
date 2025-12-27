local HEART_UPGRADE_TABLE = {
    [HeartSubType.HEART_HALF] = HeartSubType.HEART_FULL,
    --[HeartSubType.HEART_FULL] = HeartSubType.HEART_DOUBLEPACK,
    [HeartSubType.HEART_HALF_SOUL] = HeartSubType.HEART_SOUL,
}

---@param pickup EntityPickup
local function upgradeHalfHearts(_, pickup, var, sub, rvar, rsub, rng)
    if(not (var==10 and HEART_UPGRADE_TABLE[sub])) then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_CARAMEL_APPLE)) then return end

    return {var, HEART_UPGRADE_TABLE[sub], true}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, upgradeHalfHearts)