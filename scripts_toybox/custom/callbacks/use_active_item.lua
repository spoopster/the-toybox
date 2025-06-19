

---@param player EntityPlayer
local function useItemRegister(_, item, rng, player, flags, slot, vardata)
    local ITEMS_JUST_USED = ToyboxMod:getEntityData(player, "ACTIVES_USED") or {}

    table.insert(ITEMS_JUST_USED,
    {
        ID=item,
        SLOT=slot
    })
    ToyboxMod:setEntityData(player, "ACTIVES_USED", ITEMS_JUST_USED)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useItemRegister)

local function useItemUpdate(_, player)
    local ITEMS_JUST_USED = ToyboxMod:getEntityData(player, "ACTIVES_USED") or {}
    local PREV_ITEM_STATE = ToyboxMod:getEntityData(player, "PREV_ITEMSTATE")

    local justLostItemState = (PREV_ITEM_STATE~=0 and player:GetItemState()==0)

    for _, data in ipairs(ITEMS_JUST_USED) do
        if(PREV_ITEM_STATE~=0 and data.ID==PREV_ITEM_STATE) then justLostItemState = false end

        if(not (data.ID==player:GetItemState() or data.ID==PREV_ITEM_STATE)) then
            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.USE_ACTIVE_ITEM, data.ID, player, data.ID, data.SLOT)
        end
    end

    if(justLostItemState) then
        Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.USE_ACTIVE_ITEM, PREV_ITEM_STATE, player, PREV_ITEM_STATE, -2)
    end

    ToyboxMod:setEntityData(player, "PREV_ITEMSTATE", player:GetItemState())
    ToyboxMod:setEntityData(player, "ACTIVES_USED", {})
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, useItemUpdate)