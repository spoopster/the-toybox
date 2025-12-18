local DMG_UP = 0.7

local REPLACE_CHANCE = 0.333
local REPLACABLE_ITEMS = {
    [CollectibleType.COLLECTIBLE_SAD_ONION] = true,
    [CollectibleType.COLLECTIBLE_DEAD_ONION] = true,
    --[ToyboxMod.COLLECTIBLE_CURIOUS_CARROT] = true,
}

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_ODD_ONION)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_ODD_ONION)
    if(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(pl, DMG_UP*mult)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
local function addTempTearsUp(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_ODD_ONION)) then return end

    local num = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_ODD_ONION)

    local room = Game():GetRoom()
    local rng = ToyboxMod:generateRng(room:GetSpawnSeed())
    local conf = Isaac.GetItemConfig()
    local numCollectibles = conf:GetCollectibles().Size-1

    for _=1, num do
        local isOk, finalItem
        repeat
            finalItem = rng:RandomInt(1, numCollectibles)
            local itemConf = conf:GetCollectible(finalItem)

            isOk = (itemConf and itemConf:IsAvailable() and itemConf:HasTags(ItemConfig.TAG_SUMMONABLE) and itemConf:HasTags(ItemConfig.TAG_TEARS_UP))
        until(isOk)

        ToyboxMod:addItemForRoom(pl, finalItem, 1)

        --ToyboxMod.HiddenItemManager:AddForRoom(pl, finalItem, nil, 1, "TOYBOX")
        --pl:AnimateCollectible(finalItem, "UseItem")
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, addTempTearsUp)

local function tryReplaceItem(_, selItem, _, decrease, seed)
    if(not REPLACABLE_ITEMS[selItem]) then return end

    local pool = Game():GetItemPool()
    if(pool:HasCollectible(ToyboxMod.COLLECTIBLE_ODD_ONION)) then
        if(ToyboxMod:generateRng(seed):RandomFloat()<REPLACE_CHANCE) then
            pool:RemoveCollectible(ToyboxMod.COLLECTIBLE_ODD_ONION)
            return ToyboxMod.COLLECTIBLE_ODD_ONION
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, tryReplaceItem)