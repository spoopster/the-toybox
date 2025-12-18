

local ENUM_SPEEDTOADD = -0.25
local ENUM_TEARSTOADD = 0.5
local ENUM_FRICTION_BONUS = 0.085

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_COCONUT_OIL)) then return end

    local mult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_COCONUT_OIL)

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+ENUM_SPEEDTOADD*mult
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, ENUM_TEARSTOADD*mult)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function makePlayerSlippery(_, player)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_COCONUT_OIL)) then
        player.Friction = player.Friction + math.min(ENUM_FRICTION_BONUS/player.MoveSpeed, 0.1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, makePlayerSlippery)