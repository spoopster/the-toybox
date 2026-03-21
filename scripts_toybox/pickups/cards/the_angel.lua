---@param pl EntityPlayer
local function useTheAngel(_, _, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    pl:UseActiveItem(CollectibleType.COLLECTIBLE_BIBLE, UseFlag.USE_NOHUD | UseFlag.USE_NOANIM, -1)
    ToyboxMod:addItemForRoom(pl, CollectibleType.COLLECTIBLE_DEAD_DOVE)
    if(flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) then
        local shouldRemoveCostume = true
        if(pl:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART)) then
            shouldRemoveCostume = false
        end
        ToyboxMod:addItemForRoom(pl, CollectibleType.COLLECTIBLE_SACRED_HEART)
        if(shouldRemoveCostume) then
            pl:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART))
        end
    end

    ItemOverlay.Show(ToyboxMod.GIANTBOOK_THE_ANGEL, 3, pl)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheAngel, ToyboxMod.CARD_THE_ANGEL)