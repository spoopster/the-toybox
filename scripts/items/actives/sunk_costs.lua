local mod = MilcomMOD
local sfx = SFXManager()

local TEARSTOADD = 0.3
local TEARS_PRICE = 5

---@param player EntityPlayer
local function preUseSunkCosts(_, _, rng, player, flags)
    if(player:GetNumCoins()<TEARS_PRICE) then return true end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, preUseSunkCosts, mod.COLLECTIBLE_SUNK_COSTS)

---@param player EntityPlayer
local function useSunkCosts(_, _, rng, player, flags)
    player:AddCoins(-TEARS_PRICE)
    sfx:Play(SoundEffect.SOUND_CASH_REGISTER)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useSunkCosts, mod.COLLECTIBLE_SUNK_COSTS)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:GetEffects():GetCollectibleEffect(mod.COLLECTIBLE_SUNK_COSTS)) then return end

    local mult = player:GetEffects():GetCollectibleEffect(mod.COLLECTIBLE_SUNK_COSTS).Count
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)) then mult=mult*1.5 end

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay/(1+mult*TEARSTOADD)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)