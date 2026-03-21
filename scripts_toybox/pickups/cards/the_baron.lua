local QUALITY_TO_PICKUPS = {
    [0] = {
        {PickupVariant.PICKUP_POOP, -1}
    },
    [1] = {
        {PickupVariant.PICKUP_COIN, -1},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY},
        {PickupVariant.PICKUP_HEART, -1},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN},
    },
    [2] = {
        {PickupVariant.PICKUP_BOMB, -1},
        {PickupVariant.PICKUP_TAROTCARD, -1},
        {PickupVariant.PICKUP_TAROTCARD, Card.CARD_CRACKED_KEY},
        {PickupVariant.PICKUP_KEY, -1},
        {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MICRO},
        {PickupVariant.PICKUP_PILL, -1},
    },
    [3] = {
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_STICKYNICKEL},
    },
    [4] = {
        {PickupVariant.PICKUP_TAROTCARD, -2}, --rune
        {PickupVariant.PICKUP_TAROTCARD, Card.CARD_DICE_SHARD},
        {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL},
    },
    [5] = {
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL},
        {PickupVariant.PICKUP_HEART, HeartSubType.HEART_GOLDEN},
        {PickupVariant.PICKUP_KEY, KeySubType.KEY_CHARGED},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME},
    },
    [7] = {
        {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_GOLDEN},
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GOLDEN},
        {PickupVariant.PICKUP_KEY, KeySubType.KEY_GOLDEN},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_GOLDEN},
        {PickupVariant.PICKUP_PILL, PillColor.PILL_GOLD},
        {PickupVariant.PICKUP_PILL, PillColor.PILL_GOLD | PillColor.PILL_GIANT_FLAG},
    },
    [8] = {
        {PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_MEGA},
        {PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY},
    },
    [10] = {
        {PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA},
    }
}

local PICKUP_QUALITY = {}
for q, pickups in pairs(QUALITY_TO_PICKUPS) do
    for _, pdata in ipairs(pickups) do
        local st = tostring(pdata[1]).."."..tostring(pdata[2])
        PICKUP_QUALITY[st] = q
    end
end

---@param pickup EntityPickup
local function getPickupQuality(pickup)
    local str1 = tostring(pickup.Variant).."."..tostring(pickup.SubType)
    if(PICKUP_QUALITY[str1]) then
        return PICKUP_QUALITY[str1]
    end

    if(pickup.Variant==PickupVariant.PICKUP_TAROTCARD) then
        local conf = Isaac.GetItemConfig():GetCard(pickup.SubType)
        if(conf and conf:IsRune()) then
            return PICKUP_QUALITY[tostring(pickup.Variant)..".-2"]
        end
    end

    local str2 = tostring(pickup.Variant)..".-1"
    if(PICKUP_QUALITY[str2]) then
        return PICKUP_QUALITY[str2]
    end

    return -1
end

---@param pl EntityPlayer
local function useTheBaron(_, _, pl, flags)
    --if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    local room = Game():GetRoom()
    for _, ent in ipairs(Isaac.FindByType(5)) do
        local pickup = ent:ToPickup()

        local ogqual = getPickupQuality(pickup)
        if(ogqual~=-1 and ogqual<8) then
            local newqual = ogqual
            while(newqual<=ogqual) do
                pickup.FlipX = false
                pickup:Morph(5,0,NullPickupSubType.NO_COLLECTIBLE_TRINKET_CHEST)
                newqual = getPickupQuality(pickup)
            end
        end
    end

    --sfx:Play(ToyboxMod.SFX_BREATH, 1, 2, false, math.random()*0.1+0.95)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheBaron, ToyboxMod.CARD_THE_BARON)