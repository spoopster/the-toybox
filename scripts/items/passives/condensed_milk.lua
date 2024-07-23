local mod = MilcomMOD
--// this is the worst code i have ever written
--// nvm
--* i reworked the item but this code is kinda evil tbh

local FIREDELAY_MULT = 1.2
local updatedTears = false

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then return end

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        local mult = FIREDELAY_MULT^player:GetCollectibleNum(mod.COLLECTIBLE_CONDENSED_MILK)
        player.MaxFireDelay = player.MaxFireDelay/mult
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        if(not updatedTears) then
            updatedTears = true
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
            updatedTears = false
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, math.huge, evalCache)

local function postPeffectUpdate(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then return end

    player.MaxFireDelay = mod:toFireDelay(mod:toTps(player.MaxFireDelay)*(player.Damage/3.5 or 1))
    player.Damage = 3.5
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)