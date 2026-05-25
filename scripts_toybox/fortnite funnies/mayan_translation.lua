local translations = {
    [ToyboxMod.COLLECTIBLE_CHICCHAN_SERPENT] = {"Chicchan", "The Serpent"},
    [ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE] = {"Etznab", "The Knife"},
    [ToyboxMod.COLLECTIBLE_OC_DOG] = {"Oc", "The Dog"},
    [ToyboxMod.COLLECTIBLE_IMIX_CROCODILE] = {"Imix", "The Crocodile"},
    [ToyboxMod.COLLECTIBLE_CIB_VULTURE] = {"Cib", "The Vulture"},
    [ToyboxMod.COLLECTIBLE_MEN_EAGLE] = {"Men", "The Eagle"},
    [ToyboxMod.COLLECTIBLE_CABAN_EARTH] = {"Caban", "The Earth"},
    [ToyboxMod.COLLECTIBLE_LAMAT_RABBIT] = {"Lamat", "The Rabbit"},
    [ToyboxMod.COLLECTIBLE_MULAC_WATER] = {"Mulac", "The Water"},
    [ToyboxMod.COLLECTIBLE_IK_WIND] = {"Ik", "The Wind"},
    [ToyboxMod.COLLECTIBLE_EB_GRASS] = {"Eb", "The Grass"},
}

local function mynameisdrakeandilikepenis(_, slot)
    local conf = Isaac.GetItemConfig()
    for id, data in pairs(translations) do
        local iconf = conf:GetCollectible(id)
        if(iconf) then
            iconf.Name = (ToyboxMod.CONFIG.MAYAN_ITEM_TRANSLATIONS==1 and data[2] or data[1])
        end

        if(EID and EID.ItemNames[EID.DefaultLanguageCode]["5.100."..id]) then
            EID.ItemNames[EID.DefaultLanguageCode]["5.100."..id] = (ToyboxMod.CONFIG.MAYAN_ITEM_TRANSLATIONS==1 and (data[1].." ("..data[2]..")") or data[1])
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, mynameisdrakeandilikepenis)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mynameisdrakeandilikepenis)