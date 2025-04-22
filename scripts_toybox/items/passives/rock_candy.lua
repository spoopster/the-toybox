local mod = ToyboxMod

local DAMAGE_UP = 0.7
local SHOTSPEED_ADD = 0.16

---@param player EntityPlayer
local function postAddItem(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    local mId = mod:getRandomMantle(player:GetCollectibleRNG(mod.COLLECTIBLE.ROCK_CANDY), true)
    local consSt = mod.MANTLE_DATA[mod:getMantleKeyFromId(mId)].CONSUMABLE_SUBTYPE

    local mantle = Isaac.Spawn(5,300,consSt,Game():GetRoom():FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,player):ToPickup()
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem, mod.COLLECTIBLE.ROCK_CANDY)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE.ROCK_CANDY)) then return end
    local mult = player:GetCollectibleNum(mod.COLLECTIBLE.ROCK_CANDY)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(player, DAMAGE_UP*mult)
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+SHOTSPEED_ADD*mult
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)