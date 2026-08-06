local seenGroups = {}

local forRoomGroups = {}
local forLevelGroups = {}

ToyboxMod.ITEMGROUP_ROOM = "ToyboxRoom"
ToyboxMod.ITEMGROUP_LEVEL = "ToyboxLevel"

---@param key string
function ToyboxMod:registerInnateKey(key)
    if(not seenGroups[key]) then
        seenGroups[key] = true

        if(string.find(key, "ForRoom")) then
            table.insert(forRoomGroups, key)
        end
        if(string.find(key, "ForLevel")) then
            table.insert(forLevelGroups, key)
        end
    end
end

---@param pl EntityPlayer
---@param id CollectibleType
---@param count? number Default: 1
---@param group? string Default: none
---@param addCostume? boolean Default: true
---@param duration? number Default: -1
function ToyboxMod:addInnateCollectible(pl, id, count, group, addCostume, duration)
    if(group) then
        group = "Toybox"..group

        seenGroups[group] = true
    end

    pl:AddInnateCollectible(id, count, group, duration, addCostume)
end

---@param pl EntityPlayer
---@param id TrinketType
---@param count? number
---@param group? string
---@param addCostume? boolean
---@param duration? number
function ToyboxMod:addInnateTrinket(pl, id, count, group, addCostume, duration)
    if(group) then
        group = "Toybox"..group

        seenGroups[group] = true
    end

    pl:AddInnateTrinket(id, count, group, duration, addCostume)
end

---@param player EntityPlayer
local function removeTempRoomItems(_, player)
    for _, group in ipairs(forRoomGroups) do
        player:ClearInnateItemGroup(group)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, CallbackPriority.IMPORTANT, removeTempRoomItems)

---@param player EntityPlayer
local function removeTempLevelItems(_, player)
    if(player.FrameCount==0) then return end

    for _, group in ipairs(forLevelGroups) do
        player:ClearInnateItemGroup(group)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, CallbackPriority.IMPORTANT, removeTempLevelItems)