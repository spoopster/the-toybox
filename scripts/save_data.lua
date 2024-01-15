local mod = MilcomMOD
local json = require("json")

---@param t table
local function convertTableToSaveData(t)
    local data = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            data[key] = {}
            for key1, val1 in pairs(convertTableToSaveData(val)) do
                data[key][key1] = val1
            end
        elseif(type(val)=="userdata" and type(val.LengthSquared)=="function") then
            data[key] = {}
            for key1, val1 in pairs(mod:vectorToVectorTable(val)) do
                data[key][key1] = val1
            end
        elseif(type(val)=="userdata" and type(val.SetColorize)=="function") then
            data[key] = {}
            for key1, val1 in pairs(mod:colorToColorTable(val)) do
                data[key][key1] = val1
            end
        else
            data[key]=val
        end
    end

    return data
end

---@param t table
local function convertSaveDataToTable(t)
    local data = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            data[key] = {}

            if(val.IsVectorTable) then
                data[key] = mod:vectorTableToVector(val)
            elseif(val.IsColorTable) then
                data[key] = mod:colorToColorTable(val)
            else
                for key1, val1 in pairs(convertSaveDataToTable(val)) do
                    data[key][key1] = val1
                end
            end
        else
            data[key] = val
        end
    end

    return data
end

local isDataLoaded = false

function mod:saveProgress()
    local save = {}
    save.milcomData = {}
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        if(player:GetPlayerType()==mod.PLAYER_MILCOM_A) then
            local seed = ""..player:GetCollectibleRNG(198):GetSeed() --* milcom uses box's rng just in case !

            save.milcomData[seed] = convertTableToSaveData(mod:getMilcomATable(player))
        end
    end
    save.pickupDataA = mod.MILCOM_A_PICKUPS or {CARDBOARD = 0, DUCT_TAPE = 0, NAILS = 0}

	mod:SaveData(json.encode(save))
end

function mod:saveNewFloor()
    if(isDataLoaded) then mod:saveProgress() end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveNewFloor)
function mod:saveGameExit(save)
    mod:saveProgress()
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveGameExit)

function mod:dataSaveInit(player)
    if(Game():GetFrameCount()==0) then
        if(player:GetPlayerType()==mod.PLAYER_MILCOM_A) then
            mod.MILCOM_A_DATA[player.InitSeed] = mod:cloneTable(mod.MILCOM_A_BASEDATA)
            mod.MILCOM_A_PICKUPS = {CARDBOARD = 0, DUCT_TAPE = 0, NAILS = 0}
        elseif(player:GetPlayerType()==mod.PLAYER_MILCOM_B) then end
    else
        if(mod:HasData()) then
            local save = json.decode(mod:LoadData())
            local iData = save.milcomData[""..player:GetCollectibleRNG(198):GetSeed()]
            if(iData) then
                if(player:GetPlayerType()==mod.PLAYER_MILCOM_A and iData["CHARACTER_SIDE"]=="A") then
                    mod.MILCOM_A_DATA[player.InitSeed] = convertSaveDataToTable(iData)
                elseif(player:GetPlayerType()==mod.PLAYER_MILCOM_B) then end
            else
                if(player:GetPlayerType()==mod.PLAYER_MILCOM_A) then
                    mod.MILCOM_A_DATA[player.InitSeed] = mod:cloneTable(mod.MILCOM_A_BASEDATA)
                elseif(player:GetPlayerType()==mod.PLAYER_MILCOM_B) then end
            end

            if(#Isaac.FindByType(1)==0) then
                if(save.pickupDataA) then mod.MILCOM_A_PICKUPS = save.pickupDataA
                else mod.MILCOM_A_PICKUPS = {CARDBOARD = 0, DUCT_TAPE = 0, NAILS = 0} end
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, mod.dataSaveInit)
local itemPool = Game():GetItemPool()
local itemConfig = Isaac.GetItemConfig()

--#region COLLECTIBLE_LOGIC
function mod:rerollLockedCollectiblePickup(pickup)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for mark, unlock in pairs(unlockTable) do
            if(mod.MARKS.CHARACTERS[character][mark]~=0) then goto unlocked end
            if(not (unlock.TYPE=="COLLECTIBLE" and unlock.ID>0 and pickup.SubType==unlock.ID)) then goto invalidItem end

            pickup:Morph(pickup.Type, pickup.Variant, 0, true, true)

            ::unlocked:: ::invalidItem::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.rerollLockedCollectiblePickup, PickupVariant.PICKUP_COLLECTIBLE)

local function getActiveSlotForItem(player, collectibleType)
    for _, activeSlot in pairs(ActiveSlot) do
        if player:GetActiveItem(activeSlot) == collectibleType then
            return activeSlot
        end
    end

    return nil
end

local maxTries = 100
local function getItemConfigOfSameType(collectibleType)
    local itemType = itemConfig:GetCollectible(collectibleType).Type

    local tries = 0
    while tries < maxTries do
        local chosenCollectible = itemPool:GetCollectible(ItemPoolType.POOL_TREASURE, false, Random(), CollectibleType.COLLECTIBLE_BREAKFAST)
        local collectibleConfig = itemConfig:GetCollectible(chosenCollectible)

        if collectibleConfig.Type == itemType then
            return collectibleConfig
        else
            tries = tries + 1
        end
    end

    return itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_BREAKFAST)
end

local function replaceCollectible(player, collectibleType)
    for _ = 1, player:GetCollectibleNum(collectibleType) do
        local activeSlot = getActiveSlotForItem(player, collectibleType)
        player:RemoveCollectible(collectibleType)

        local collectibleConfig = getItemConfigOfSameType(collectibleType)
        player:AddCollectible(collectibleConfig.ID, collectibleConfig.MaxCharges, true, activeSlot)
    end
end

function mod:replaceLockedCollectibles(player)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for mark, unlock in pairs(unlockTable) do
            if(mod.MARKS.CHARACTERS[character][mark]~=0) then goto unlocked end
            if(not (unlock.TYPE=="COLLECTIBLE" and unlock.ID>0 and player:HasCollectible(unlock.ID))) then goto invalidItem end

            if(player:HasCollectible(unlock.ID)) then
                replaceCollectible(player, unlock.ID)
            end

            ::unlocked:: ::invalidItem::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.replaceLockedCollectibles)
--#endregion

--#region TRINKET_LOGIC
function mod:rerollLockedTrinketPickup(pickup)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for mark, unlock in pairs(unlockTable) do
            if(mod.MARKS.CHARACTERS[character][mark]~=0) then goto unlocked end
            if(not (unlock.TYPE=="TRINKET" and unlock.ID>0 and pickup.SubType==unlock.ID)) then goto invalidItem end

            pickup:Morph(pickup.Type, pickup.Variant, 0, true, true)

            ::unlocked:: ::invalidItem::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.rerollLockedTrinketPickup, PickupVariant.PICKUP_TRINKET)

local function replaceTrinket(player, trinketType)
    if not player:TryRemoveTrinket(trinketType) then return end
    player:AddTrinket(itemPool:GetTrinket(false))
end

function mod:replaceLockedTrinkets(player)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for mark, unlock in pairs(unlockTable) do
            if(mod.MARKS.CHARACTERS[character][mark]~=0) then goto unlocked end
            if(not (unlock.TYPE=="TRINKET" and unlock.ID>0 and player:HasTrinket(unlock.ID))) then goto invalidItem end

            replaceTrinket(player, unlock.ID)

            ::unlocked:: ::invalidItem::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.replaceLockedTrinkets)
--#endregion
--#endregion