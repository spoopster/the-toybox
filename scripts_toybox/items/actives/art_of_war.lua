
local sfx = SFXManager()

ToyboxMod.TEAR_REPLACEMENT_ITEMS = {
    {CollectibleType.COLLECTIBLE_TECH_X, 1},
    {CollectibleType.COLLECTIBLE_BRIMSTONE, 1},
    {CollectibleType.COLLECTIBLE_MOMS_KNIFE, 1},
    {CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE, 1},
    {CollectibleType.COLLECTIBLE_TECHNOLOGY, 1},
    {CollectibleType.COLLECTIBLE_SPIRIT_SWORD, 1},
    {CollectibleType.COLLECTIBLE_DR_FETUS, 1},
    {CollectibleType.COLLECTIBLE_EPIC_FETUS, 1},
    --{CollectibleType.COLLECTIBLE_TRISAGION, 1},
}
if(REVEL) then
    table.insert(ToyboxMod.TEAR_REPLACEMENT_ITEMS, {REVEL.ITEM.BURNBUSH.id, 1})
end

local REPLACEMENT_ITEM_PICKER = WeightedOutcomePicker()
for _, item in ipairs(ToyboxMod.TEAR_REPLACEMENT_ITEMS) do
    REPLACEMENT_ITEM_PICKER:AddOutcomeFloat(item[1], item[2], 100)
end

---@param rng RNG
---@param pl EntityPlayer
local function artOfWarUse(_, _, rng, pl, flags, slot, vdata)
    local pickedItem = REPLACEMENT_ITEM_PICKER:PickOutcome(rng)

    pl:AddInnateCollectible(pickedItem, 1)

    local data = ToyboxMod:getEntityDataTable(pl)
    data.ART_OF_WAR_ITEMS = data.ART_OF_WAR_ITEMS or {}
    data.ART_OF_WAR_ITEMS[pickedItem] = (data.ART_OF_WAR_ITEMS[pickedItem] or 0)+1

    pl:AnimateCollectible(pickedItem, "UseItem")
    sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A)

    return {
        Discharge = true,
        ShowAnim = false,
        Remove = false,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, artOfWarUse, ToyboxMod.COLLECTIBLE_ART_OF_WAR)

local function postPlayerNewRoom(_)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local data = ToyboxMod:getEntityDataTable(pl)

        if(data.ART_OF_WAR_ITEMS) then
            for item, num in pairs(data.ART_OF_WAR_ITEMS) do
                pl:AddInnateCollectible(item, -num)
                if(not pl:HasCollectible(item)) then
                    pl:RemoveCostume(Isaac.GetItemConfig():GetCollectible(item))
                end
            end

            data.ART_OF_WAR_ITEMS = nil
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postPlayerNewRoom)