
--* Penny spawns have a chance to become lucky pennies

local SPECIAL_CHANCE = 5*0.01

---@param pickup EntityPickup
local function coinInit(_, pickup)
    if(pickup.SubType~=CoinSubType.COIN_PENNY) then return end
    if(not (pickup:GetSprite():GetAnimation()=="Appear" or pickup:GetSprite():GetAnimation()=="AppearFast")) then return end

    local numBoosts = 0
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(ToyboxMod:playerHasLimitBreak(pl)) then numBoosts = numBoosts+pl:GetCollectibleNum(CollectibleType.COLLECTIBLE_QUARTER) end
    end
    if(numBoosts<=0) then return end

    local rng = pickup:GetDropRNG()
    if(rng:RandomFloat()<numBoosts*SPECIAL_CHANCE) then
        pickup:Morph(5,20,5)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, coinInit, PickupVariant.PICKUP_COIN)