local mod = MilcomMOD

local ENUM_FIREDELAY_MULT = 0.8
local ENUM_SKEW_MNMX = {Min=0.45,Max=1.35}

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_GOAT_MILK)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_GOAT_MILK)

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay*(ENUM_FIREDELAY_MULT^mult)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param tear EntityTear
local function skewFireDelay(_, tear)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())) then return end

    local player = tear.SpawnerEntity:ToPlayer()
    if(not player:HasCollectible(mod.COLLECTIBLE_GOAT_MILK)) then return end

    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_GOAT_MILK)

    local fireDelayMult = rng:RandomFloat()*(ENUM_SKEW_MNMX.Max-ENUM_SKEW_MNMX.Min)+ENUM_SKEW_MNMX.Min
    player.FireDelay = math.max(0, player.FireDelay*fireDelayMult)
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, skewFireDelay)