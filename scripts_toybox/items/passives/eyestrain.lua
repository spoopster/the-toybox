

local LUCKUP = 0.75
local DAMAGEUP = 1

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_EYESTRAIN)) then return end
    local mult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_EYESTRAIN)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(player, DAMAGEUP*mult)
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+LUCKUP*mult
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)