local mod = ToyboxMod

local SHOTSPEED_UP = 0.15

---@param pl EntityPlayer
local function addAtheism(_, _, _, firstTime, _, _, pl)
    if(firstTime) then
        pl:AddEternalHearts(1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addAtheism, mod.COLLECTIBLE.MAYONAISE)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE.MAYONAISE)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE.MAYONAISE)

    if(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+SHOTSPEED_UP*mult
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)