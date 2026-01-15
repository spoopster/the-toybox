local MANTLE_IDS = {
    ToyboxMod.CARD_MANTLE_ROCK,
    ToyboxMod.CARD_MANTLE_POOP,
    ToyboxMod.CARD_MANTLE_DARK,
    ToyboxMod.CARD_MANTLE_HOLY,
    ToyboxMod.CARD_MANTLE_BONE,
    ToyboxMod.CARD_MANTLE_GLASS,
    ToyboxMod.CARD_MANTLE_METAL,
    ToyboxMod.CARD_MANTLE_GOLD,
    ToyboxMod.CARD_MANTLE_SALT,
}
local ALT_TAROT_IDS = {
    ToyboxMod.CARD_THE_WISE_MEN,
    ToyboxMod.CARD_THE_ANGEL,
    ToyboxMod.CARD_THE_GATE,
    ToyboxMod.CARD_APOCALYPSE,
    ToyboxMod.CARD_THE_CRYPT,
    ToyboxMod.CARD_THE_REAPER,
    ToyboxMod.CARD_THE_DRAGON,
    ToyboxMod.CARD_DUALITY,
    ToyboxMod.CARD_THE_BARON,
}

local function decreaseWeight(_)
    local conf = Isaac.GetItemConfig()
    for _, id in ipairs(MANTLE_IDS) do
        conf:GetCard(id).Weight = (ToyboxMod.CONFIG.MANTLE_WEIGHT or 1.5)
    end
    for _, id in ipairs(ALT_TAROT_IDS) do
        conf:GetCard(id).Weight = (ToyboxMod.CONFIG.ALT_TAROT_WEIGHT or 0.5)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)