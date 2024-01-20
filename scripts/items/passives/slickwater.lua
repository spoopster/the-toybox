local mod = MilcomMOD

local ENUM_TEARSTOADD = 0.5
local ENUM_FRICTION_BONUS = 0.085

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_SLICKWATER)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_SLICKWATER)

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed-0.25*mult
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = mod:addTps(player, ENUM_TEARSTOADD*mult)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function makePlayerSlippery(_, player)
    if(player:HasCollectible(mod.COLLECTIBLE_SLICKWATER)) then
        player.Friction = player.Friction + math.min(ENUM_FRICTION_BONUS/player.MoveSpeed, 0.1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, makePlayerSlippery)