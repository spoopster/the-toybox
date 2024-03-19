local mod = MilcomMOD

local ENUM_TEARSTOADD = 0.5

---@param player EntityPlayer
local function useBloodyNeedle(_, _, rng, player, flags)
    player:ResetDamageCooldown()
    player:TakeDamage(1, DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_RED_HEARTS, EntityRef(nil), 30)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useBloodyNeedle, mod.COLLECTIBLE_BLOODY_NEEDLE)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:GetEffects():GetCollectibleEffect(mod.COLLECTIBLE_BLOODY_NEEDLE)) then return end

    local mult = player:GetEffects():GetCollectibleEffect(mod.COLLECTIBLE_BLOODY_NEEDLE).Count
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) then mult=mult*1.5 end

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = mod:addTps(player, ENUM_TEARSTOADD*mult)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)