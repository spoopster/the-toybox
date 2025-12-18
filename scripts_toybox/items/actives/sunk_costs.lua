
local sfx = SFXManager()

local TEARSTOADD = 0.7
local TEARSTOADD_BATTERY = 1
local TEARS_PRICE = 5

---@param player EntityPlayer
local function preUseSunkCosts(_, _, rng, player, flags)
    if(player:GetNumCoins()<TEARS_PRICE) then return true end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, preUseSunkCosts, ToyboxMod.COLLECTIBLE_SUNK_COSTS)

---@param player EntityPlayer
local function useSunkCosts(_, _, rng, player, flags)
    player:AddCoins(-TEARS_PRICE)
    sfx:Play(SoundEffect.SOUND_CASH_REGISTER)

    local mult = 0
    if(player:GetEffects():GetCollectibleEffect(ToyboxMod.COLLECTIBLE_SUNK_COSTS)) then
        mult = player:GetEffects():GetCollectibleEffect(ToyboxMod.COLLECTIBLE_SUNK_COSTS).Count
    end
    mult = mult+1

    local col = player.Color
    col:SetColorize(1,1,0,math.min(1, mult*0.2))
    player.Color = col

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useSunkCosts, ToyboxMod.COLLECTIBLE_SUNK_COSTS)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:GetEffects():GetCollectibleEffect(ToyboxMod.COLLECTIBLE_SUNK_COSTS)) then return end

    local mult = player:GetEffects():GetCollectibleEffect(ToyboxMod.COLLECTIBLE_SUNK_COSTS).Count

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, mult*(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and TEARSTOADD_BATTERY or TEARSTOADD))
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local col = player.Color
    col:SetColorize(1,1,1,0)
    player.Color = col
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)