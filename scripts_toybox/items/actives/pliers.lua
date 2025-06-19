

local TEARSTOADD = 0.7
local TEARSTOADD_BATTERY = 1

---@param player EntityPlayer
local function usePliers(_, _, rng, player, flags)
    player:ResetDamageCooldown()
    player:TakeDamage(1, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(nil), 30)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, usePliers, ToyboxMod.COLLECTIBLE_PLIERS)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:GetEffects():GetCollectibleEffect(ToyboxMod.COLLECTIBLE_PLIERS)) then return end

    local mult = player:GetEffects():GetCollectibleEffect(ToyboxMod.COLLECTIBLE_PLIERS).Count

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, mult*(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and TEARSTOADD_BATTERY or TEARSTOADD))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)