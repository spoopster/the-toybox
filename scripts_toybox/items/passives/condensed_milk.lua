
--// this is the worst code i have ever written
--// nvm
--* i reworked the item but this code is kinda evil tbh

local FIREDELAY_MULT = 1.2
local alreadyUpdating = false

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_CONDENSED_MILK)) then return end

    if(flag==CacheFlag.CACHE_FIREDELAY and alreadyUpdating~="TEARS") then
        local ogDamage = player.Damage

        if(not alreadyUpdating) then
            alreadyUpdating = "TEARS"
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
            alreadyUpdating = nil

            ogDamage = player.Damage
            player.Damage = 3.5
        end

        local mult = FIREDELAY_MULT^player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_CONDENSED_MILK)

        player.MaxFireDelay = player.MaxFireDelay/mult
        player.MaxFireDelay = player.MaxFireDelay*3.5/ogDamage
    elseif(flag==CacheFlag.CACHE_DAMAGE and alreadyUpdating~="DAMAGE") then
        if(not alreadyUpdating) then
            alreadyUpdating = "DAMAGE"
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
            alreadyUpdating = nil

            player.Damage = 3.5
        end
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, math.huge, evalCache)
