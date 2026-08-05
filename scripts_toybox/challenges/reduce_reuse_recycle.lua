local MAX_COINS = 15
local MAX_COINS_DEEPPOCKETS = 150
local MAX_BOMB_KEY = 3
local MAX_HP = 12
local MAX_HP_KEEPER = 4

---@param pl EntityPlayer
---@param flag string
---@param val number
local function postEvaluateCustomCache(_, pl, flag, val)
    if(ToyboxMod.GAME.Challenge~=ToyboxMod.CHALLENGE_REDUCE_REUSE_RECYCLE) then return end

    if(flag=="maxcoins") then
        return (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) and MAX_COINS_DEEPPOCKETS or MAX_COINS)
    elseif(flag=="maxbombs") then
        return MAX_BOMB_KEY
    elseif(flag=="maxkeys") then
        return MAX_BOMB_KEY
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CUSTOM_CACHE, postEvaluateCustomCache)

---@param pl EntityPlayer
---@param limit integer
---@param iskeeper boolean
local function evaluateHpLimit(_, pl, limit, iskeeper)
    if(ToyboxMod.GAME.Challenge~=ToyboxMod.CHALLENGE_REDUCE_REUSE_RECYCLE) then return end

    return ((iskeeper or pl:GetHealthType()==HealthType.KEEPER) and MAX_HP_KEEPER or MAX_HP)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, evaluateHpLimit)