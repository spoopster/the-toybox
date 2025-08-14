

local LUCK_UP = 1
local TEARS_UP = 0.7

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_EYESTRAIN)) then return end
    local mult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_EYESTRAIN)

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, TEARS_UP*mult)
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+LUCK_UP*mult
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)