

local function postUpdate(_)
    if(not PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_MILCOM_A)) then return end

    local pl
    for i=0, ToyboxMod.GAME:GetNumPlayers()-1 do
        local tempPl = Isaac.GetPlayer(i)
        if(tempPl:GetPlayerType()==ToyboxMod.PLAYER_MILCOM_A) then
            pl = tempPl

            if(tempPl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                break
            end
        end
    end
    local hasBirthright = pl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)

    local data = ToyboxMod:getExtraDataTable()
    local curCoins = pl:GetNumCoins()
    local curBombs = pl:GetNumBombs()
    local curKeys = pl:GetNumKeys()

    local bombsToAdd = curBombs-(data.MILCOM_BOMBS or 0)
    local keysToAdd = curKeys-(data.MILCOM_KEYS or 0)

    local newCoins = curCoins
    newCoins = newCoins+bombsToAdd*(hasBirthright and ToyboxMod.MILCOM_BOMB_VALUE_BIRTHRIGHT or ToyboxMod.MILCOM_BOMB_VALUE or 5)
    newCoins = newCoins+keysToAdd*(hasBirthright and ToyboxMod.MILCOM_KEY_VALUE_BIRTHRIGHT or ToyboxMod.MILCOM_KEY_VALUE or 7)
    
    pl:AddCoins(newCoins-curCoins)
    pl:AddBombs(math.floor(newCoins/(hasBirthright and ToyboxMod.MILCOM_BOMB_VALUE_BIRTHRIGHT or ToyboxMod.MILCOM_BOMB_VALUE or 5))-curBombs)
    pl:AddKeys(math.floor(newCoins/(hasBirthright and ToyboxMod.MILCOM_KEY_VALUE_BIRTHRIGHT or ToyboxMod.MILCOM_KEY_VALUE or 7))-curKeys)

    data.MILCOM_COINS = pl:GetNumCoins()
    data.MILCOM_BOMBS = pl:GetNumBombs()
    data.MILCOM_KEYS = pl:GetNumKeys()

    Isaac.GetPlayer():AddCustomCacheTag({"maxcoins", "maxbombs", "maxkeys"}, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)



local function postEvaluateCustomCache(_, pl, flag, val)
    if(not PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_MILCOM_A)) then return end

    local birthrightEffect = PlayerManager.AnyPlayerTypeHasCollectible(ToyboxMod.PLAYER_MILCOM_A, CollectibleType.COLLECTIBLE_BIRTHRIGHT)

    local maxCoins = (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) and 999 or 99)
    if(flag=="maxcoins") then
        return maxCoins
    elseif(flag=="maxbombs") then
        return math.floor(maxCoins/(birthrightEffect and ToyboxMod.MILCOM_BOMB_VALUE_BIRTHRIGHT or ToyboxMod.MILCOM_BOMB_VALUE or 5))
    elseif(flag=="maxkeys") then
        return math.floor(maxCoins/(birthrightEffect and ToyboxMod.MILCOM_KEY_VALUE_BIRTHRIGHT or ToyboxMod.MILCOM_KEY_VALUE or 7))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CUSTOM_CACHE, postEvaluateCustomCache)