

ToyboxMod.ABOX_ITEMS_ALPHABETICAL = {}
ToyboxMod.ABOX_ITEMS_INDEX = {}

local function alphabeticalSort(sortA, sortB)
    return string.lower(sortA[1])<string.lower(sortB[1])
end
local function gameLoaded(_, isCont)
    ToyboxMod.ABOX_ITEMS_ALPHABETICAL = {}
    ToyboxMod.ABOX_ITEMS_INDEX = {}

    local conf = Isaac.GetItemConfig()
    for i=1, conf:GetCollectibles().Size-1 do
        local item = conf:GetCollectible(i)
        if(item and item:IsAvailable() and not item.Hidden) then
            local name = item.Name
            local locName = Isaac.GetString("Items", item.Name)
            if(locName~="StringTable::InvalidKey") then name=locName end

            table.insert(ToyboxMod.ABOX_ITEMS_ALPHABETICAL, {name, item.ID})
        end
    end

    table.sort(ToyboxMod.ABOX_ITEMS_ALPHABETICAL, alphabeticalSort)
    for idx, itemDat in ipairs(ToyboxMod.ABOX_ITEMS_ALPHABETICAL) do
        ToyboxMod.ABOX_ITEMS_INDEX[itemDat[2]] = idx
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, gameLoaded)

function ToyboxMod:getNextAlphabetItem(val, reverseOrder)
    if(#ToyboxMod.ABOX_ITEMS_ALPHABETICAL==0) then gameLoaded() end

    local idx = ToyboxMod.ABOX_ITEMS_INDEX[val]
    if(not idx) then return -1 end

    local itemConfig = Isaac.GetItemConfig()

    local isOk = false
    while(not isOk) do
        isOk = true
        idx = idx+(reverseOrder and -1 or 1)

        if(ToyboxMod.ABOX_ITEMS_ALPHABETICAL[idx]) then
            local conf = itemConfig:GetCollectible(ToyboxMod.ABOX_ITEMS_ALPHABETICAL[idx][2])
            if(not conf) then isOk = false
            elseif(Game().Challenge~=Challenge.CHALLENGE_NULL and conf:HasTags(ItemConfig.TAG_NO_CHALLENGE)) then isOk = false end
        else
            return -1
        end
    end

    return idx
end

---@param player EntityPlayer
local function useAlphabetBox(_, _, rng, player, flags)
    local itemConfig = Isaac.GetItemConfig()

    for _, item in ipairs(Isaac.FindByType(5,100)) do
        item = item:ToPickup()
        if(item.SubType~=0) then
            local idx = ToyboxMod:getNextAlphabetItem(item.SubType)
            local shouldRemoveItem = true

            if(idx~=-1) then
                item:Morph(5,100,(ToyboxMod.ABOX_ITEMS_ALPHABETICAL[idx][2] or 0), true)
                local poof = Isaac.Spawn(1000,15,2,item.Position,Vector.Zero,item)

                shouldRemoveItem = false
            end

            if(shouldRemoveItem) then
                item:TryRemoveCollectible()
            end
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useAlphabetBox, ToyboxMod.COLLECTIBLE_ALPHABET_BOX)