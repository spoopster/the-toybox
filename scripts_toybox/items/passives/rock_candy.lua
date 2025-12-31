

local DAMAGE_UP = 0.7
local SHOTSPEED_ADD = 0.16

---@param player EntityPlayer
local function postAddItem(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position,40)
    local mantle = Isaac.Spawn(5,ToyboxMod.PICKUP_RANDOM_SELECTOR,ToyboxMod.PICKUP_RANDOM_MANTLE,pos,Vector.Zero,player):ToPickup()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem, ToyboxMod.COLLECTIBLE_ROCK_CANDY)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_ROCK_CANDY)) then return end
    local mult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_ROCK_CANDY)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(player, DAMAGE_UP*mult)
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+SHOTSPEED_ADD*mult
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)