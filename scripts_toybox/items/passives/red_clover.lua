local LUCK_UP = 1
local DMG_PER_LUCK = 0.4
local DMG_MULT_STACK = 1.25

local alreadyUpdating = false

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_RED_CLOVER)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_RED_CLOVER)

    if(flag==CacheFlag.CACHE_LUCK) then
        pl.Luck = pl.Luck+LUCK_UP*mult

        if(not alreadyUpdating) then
            alreadyUpdating = true
            pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            pl:EvaluateItems()
            alreadyUpdating = false
        end
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(pl, pl.Luck*DMG_PER_LUCK)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, evalCache)