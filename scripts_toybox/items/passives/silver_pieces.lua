local DEAL_CHANCE_INCREASE = 0.15

local DEVIL_PRICES = {
    [PickupPrice.PRICE_ONE_HEART] = 1,
    [PickupPrice.PRICE_TWO_HEARTS] = 2,
    [PickupPrice.PRICE_THREE_SOULHEARTS] = 2,
    [PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS] = 2,
    [PickupPrice.PRICE_SPIKES] = 0,
    [PickupPrice.PRICE_SOUL] = 1,
    [PickupPrice.PRICE_ONE_SOUL_HEART] = 1,
    [PickupPrice.PRICE_TWO_SOUL_HEARTS] = 2,
    [PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART] = 2,
}

---@param pickup EntityPickup
---@param player EntityPlayer
---@param spent integer
local function pickupPurchase(_, pickup, player, spent)
    if(DEVIL_PRICES[spent] and DEVIL_PRICES[spent]~=0 and player:HasCollectible(ToyboxMod.COLLECTIBLE_SILVER_PIECES)) then
        local room = ToyboxMod.GAME:GetRoom()
        for i=1, DEVIL_PRICES[spent]+(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SILVER_PIECES)-1) do
            player:AddCollectibleEffect(ToyboxMod.COLLECTIBLE_SILVER_PIECES)
            
            local pos = room:FindFreePickupSpawnPosition(player.Position, 80)
            local nickel = Isaac.Spawn(5,PickupVariant.PICKUP_COIN,CoinSubType.COIN_NICKEL,pos,Vector.Zero,nil):ToPickup()
            nickel:SetDropDelay((i-1)*4)
        end

        ToyboxMod.SFX:Play(SoundEffect.SOUND_BLACK_POOF)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, pickupPurchase)

---@param pl EntityPlayer
local function addItem(_, _, _, firstTime, _, _, pl)
    if(firstTime) then
        ToyboxMod.GAME:AddDevilRoomDeal()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addItem, ToyboxMod.COLLECTIBLE_SILVER_PIECES)

local function getDevilDealChance(_, chance)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_SILVER_PIECES)) then return end

    return chance+(DEAL_CHANCE_INCREASE*PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_SILVER_PIECES)-0.0001)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, getDevilDealChance)