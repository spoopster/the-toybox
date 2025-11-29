local function greaterComp(a, b)
    return a>b
end

---@param player EntityPlayer
---@param id CollectibleType
---@param duration integer How long the item should be kept, in frames (30 frames = 1 second)
---@param count integer? How many items should be added
---@param innate boolean? Should the item show up in history (default=false)
function ToyboxMod:addTemporaryItem(player, id, duration, count, innate)
    count = count or 1
    local data = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS") or {}

    player:AddInnateCollectible(id, count)

    local strid = tostring(id)
    if(not data[strid]) then data[strid] = {} end

    for _=1, count do
        table.insert(data[strid], duration)
    end
    table.sort(data[strid], greaterComp)

    ToyboxMod:setEntityData(player, "TEMPORARY_ITEMS", data)
end
---@param player EntityPlayer
---@param id CollectibleType
---@param count integer?
function ToyboxMod:addItemForRoom(player, id, count)
    count = count or 1
    local data = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS_ROOM") or {}

    player:AddInnateCollectible(id, count)

    local strid = tostring(id)
    data[strid] = (data[strid] or 0)+count

    ToyboxMod:setEntityData(player, "TEMPORARY_ITEMS_ROOM", data)
end
---@param player EntityPlayer
---@param id CollectibleType
---@param count integer?
function ToyboxMod:addItemForLevel(player, id, count)
    count = count or 1
    local data = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS_LEVEL") or {}

    player:AddInnateCollectible(id, count)

    local strid = tostring(id)
    data[strid] = (data[strid] or 0)+count

    ToyboxMod:setEntityData(player, "TEMPORARY_ITEMS_LEVEL", data)
end

---@param player EntityPlayer
local function addTemporaryItemsOnInit(_, player)
    local basicItems = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS") or {}
    for id, data in pairs(basicItems) do
        player:AddInnateCollectible(tonumber(id), #data)
    end

    local levelItems = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS_LEVEL") or {}
    for id, count in pairs(levelItems) do
        player:AddInnateCollectible(tonumber(id), count)
    end

    local roomItems = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS_ROOM") or {}
    for id, _ in pairs(roomItems) do
        roomItems[id] = -1
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, addTemporaryItemsOnInit)

---@param player EntityPlayer
local function decrementTempItems(_, player)
    local conf = Isaac.GetItemConfig()

    local items = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS") or {}
    for id, data in pairs(items) do
        local itemsToRemove = 0
        for i, frames in pairs(data) do
            frames = frames-1
            if(frames==0) then
                itemsToRemove = itemsToRemove+1
                frames = nil
            end
            data[i] = frames
        end

       -- print(itemsToRemove, id, #data)

        if(itemsToRemove>0) then
            local nid = tostring(id)
            player:AddInnateCollectible(nid, -itemsToRemove)
            if(not player:HasCollectible(nid)) then
                player:RemoveCostume(conf:GetCollectible(nid))
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, decrementTempItems)

---@param player EntityPlayer
local function removeTempRoomItems(_, player)
    local conf = Isaac.GetItemConfig()

    local items = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS_ROOM") or {}
    for id, count in pairs(items) do
        local nid = tonumber(id)
        if(count~=-1) then
            player:AddInnateCollectible(nid, -count)
        end
        if(not player:HasCollectible(nid)) then
            player:RemoveCostume(conf:GetCollectible(nid))
        end
    end

    ToyboxMod:setEntityData(player, "TEMPORARY_ITEMS_ROOM", {})
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, CallbackPriority.IMPORTANT, removeTempRoomItems)

---@param player EntityPlayer
local function removeTempLevelItems(_, player)
    if(player.FrameCount==0) then return end
    local conf = Isaac.GetItemConfig()

    local items = ToyboxMod:getEntityData(player, "TEMPORARY_ITEMS_LEVEL") or {}
    for id, count in pairs(items) do
        local nid = tonumber(id)
        player:AddInnateCollectible(nid, -count)
        if(not player:HasCollectible(nid)) then
            player:RemoveCostume(conf:GetCollectible(nid))
        end
    end

    ToyboxMod:setEntityData(player, "TEMPORARY_ITEMS_LEVEL", {})
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, CallbackPriority.IMPORTANT, removeTempLevelItems)