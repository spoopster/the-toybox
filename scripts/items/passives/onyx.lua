local mod = MilcomMOD

local SPEED_UP = 0.2
local TEARS_UP = 0.5
local DAMAGE_UP = 1.2

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE.ONYX)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE.ONYX)

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+SPEED_UP*mult
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(player, TEARS_UP*mult)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(player, DAMAGE_UP*mult)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)