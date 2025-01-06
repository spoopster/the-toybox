local mod = MilcomMOD

local function postUpdate(_)
    if(not PlayerManager.AnyoneIsPlayerType(mod.PLAYER_MILCOM_A)) then return end

    local pl
    for i=0, Game():GetNumPlayers()-1 do
        local tempPl = Isaac.GetPlayer(i)
        if(tempPl:GetPlayerType()==mod.PLAYER_MILCOM_A) then
            pl = tempPl

            if(tempPl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                break
            end
        end
    end
    local hasBirthright = pl:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)

    local data = mod:getExtraDataTable()
    local curCoins = pl:GetNumCoins()
    local curBombs = pl:GetNumBombs()
    local curKeys = pl:GetNumKeys()

    local bombsToAdd = curBombs-(data.MILCOM_BOMBS or 0)
    local keysToAdd = curKeys-(data.MILCOM_KEYS or 0)

    local newCoins = curCoins
    newCoins = newCoins+bombsToAdd*(hasBirthright and mod.MILCOM_BOMB_VALUE_BIRTHRIGHT or mod.MILCOM_BOMB_VALUE or 5)
    newCoins = newCoins+keysToAdd*(hasBirthright and mod.MILCOM_KEY_VALUE_BIRTHRIGHT or mod.MILCOM_KEY_VALUE or 7)
    
    pl:AddCoins(newCoins-curCoins)
    pl:AddBombs(math.floor(newCoins/(hasBirthright and mod.MILCOM_BOMB_VALUE_BIRTHRIGHT or mod.MILCOM_BOMB_VALUE or 5))-curBombs)
    pl:AddKeys(math.floor(newCoins/(hasBirthright and mod.MILCOM_KEY_VALUE_BIRTHRIGHT or mod.MILCOM_KEY_VALUE or 7))-curKeys)

    data.MILCOM_COINS = pl:GetNumCoins()
    data.MILCOM_BOMBS = pl:GetNumBombs()
    data.MILCOM_KEYS = pl:GetNumKeys()

    Isaac.GetPlayer():AddCustomCacheTag({"maxcoins", "maxbombs", "maxkeys"}, true)
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)



local function postEvaluateCustomCache(_, pl, flag, val)
    if(not PlayerManager.AnyoneIsPlayerType(mod.PLAYER_MILCOM_A)) then return end

    local birthrightEffect = false
    for _, milc in ipairs(Isaac.FindByType(1,0,mod.PLAYER_MILCOM_A)) do
        if(milc:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            birthrightEffect = true
            break
        end
    end

    local maxCoins = (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) and 9999 or 999)
    if(flag=="maxcoins") then
        return maxCoins
    elseif(flag=="maxbombs") then
        return math.floor(maxCoins/(birthrightEffect and mod.MILCOM_BOMB_VALUE_BIRTHRIGHT or mod.MILCOM_BOMB_VALUE or 5))
    elseif(flag=="maxkeys") then
        return math.floor(maxCoins/(birthrightEffect and mod.MILCOM_KEY_VALUE_BIRTHRIGHT or mod.MILCOM_KEY_VALUE or 7))
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CUSTOM_CACHE, postEvaluateCustomCache)