local mod = ToyboxMod
--* Penny spawns have a chance to become double pennies or nickels

local SPECIAL_CHANCE = 15*0.01
local NICKEL_CHANCE = 10*0.01

---@param pickup EntityPickup
local function coinInit(_, pickup)
    if(pickup.SubType~=CoinSubType.COIN_PENNY) then return end
    if(not (pickup:GetSprite():GetAnimation()=="Appear" or pickup:GetSprite():GetAnimation()=="AppearFast")) then return end

    local numBoosts = 0
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(mod:playerHasLimitBreak(pl)) then numBoosts = numBoosts+pl:GetCollectibleNum(CollectibleType.COLLECTIBLE_PAGEANT_BOY) end
    end
    if(numBoosts<=0) then return end

    local rng = pickup:GetDropRNG()
    if(rng:RandomFloat()<numBoosts*SPECIAL_CHANCE) then
        if(rng:RandomFloat()<NICKEL_CHANCE) then pickup:Morph(5,20,2)
        else pickup:Morph(5,20,4) end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, coinInit, PickupVariant.PICKUP_COIN)