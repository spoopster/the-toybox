return {
    Properties = {
        DisplayName = "Magic: The Gathering Card",
        GFX = "gfx/items/cards/mtg_card.png",
        RenderModel = InventoryItemRenderType.Default,
        ItemTags = {"#tcainrework:card", "#tcainrework:pickup", "#tcainrework:mtg_card"},
        ClassicID = BagOfCraftingPickup.BOC_CARD,
        StackSize = 16,
        Rarity = InventoryItemRarity.COMMON,
        Enchanted = false
    },
    ObtainedFrom = {
        {
            EntityID = "5.300",
            Amount = 1,
            Condition = function(entity, player)
                if(entity.SubType==Isaac.GetCardIdByName("Prismstone")) then
                    return {[InventoryItemComponentData.CARD_TYPE] = entity.SubType}
                end
                return false
            end
        }
    }
}