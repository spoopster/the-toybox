local mod = ToyboxMod

local REPLACE_CHANCE = 1/6

local replacingPickup = false
---@param pickup EntityPickup
local function tryReplacePickup(_, pickup)
    if(replacingPickup) then return end
    if(not PlayerManager.AnyoneHasTrinket(mod.TRINKET.DIVIDED_JUSTICE)) then return end

    replacingPickup = true

    local isPenny = (pickup.Variant==PickupVariant.PICKUP_COIN and pickup.SubType==CoinSubType.COIN_PENNY)
    local isBomb = (pickup.Variant==PickupVariant.PICKUP_BOMB and pickup.SubType==BombSubType.BOMB_NORMAL)
    local isKey = (pickup.Variant==PickupVariant.PICKUP_KEY and pickup.SubType==KeySubType.KEY_NORMAL)
    local isHeart = (pickup.Variant==PickupVariant.PICKUP_HEART and (pickup.SubType==HeartSubType.HEART_FULL or pickup.SubType==HeartSubType.HEART_HALF))

    if(isPenny or isBomb or isKey or isHeart) then
        local chance = PlayerManager.GetTotalTrinketMultiplier(mod.TRINKET.DIVIDED_JUSTICE)*REPLACE_CHANCE
        if(mod:generateRng(pickup.InitSeed):RandomFloat()<chance) then
            pickup:Morph(EntityType.ENTITY_PICKUP,mod.PICKUP_VARIANT.SMORGASBORD,0,true)
        end
    end

    replacingPickup = false
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, tryReplacePickup)