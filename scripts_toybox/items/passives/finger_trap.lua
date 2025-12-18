

local DAMAGE_UP = 0.7
local SHOTSPEED_DOWN = 0.16

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_FINGER_TRAP)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_FINGER_TRAP)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(pl, mult*DAMAGE_UP)
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        pl.ShotSpeed = pl.ShotSpeed-mult*SHOTSPEED_DOWN
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)