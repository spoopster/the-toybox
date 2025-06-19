

local SPEED_UP = 0.2
local TEARS_UP = 0.4

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_COFFEE_CUP)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_COFFEE_CUP)
    if(flag==CacheFlag.CACHE_SPEED) then
        pl.MoveSpeed = pl.MoveSpeed+mult*SPEED_UP
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(pl, mult*TEARS_UP)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)