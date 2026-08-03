local SUB_TO_CARD = {
    [1] = ToyboxMod.CARD_MANTLE_ROCK,
    [2] = ToyboxMod.CARD_MANTLE_POOP,
    [3] = ToyboxMod.CARD_MANTLE_BONE,
    [4] = ToyboxMod.CARD_MANTLE_DARK,
    [5] = ToyboxMod.CARD_MANTLE_HOLY,
    [6] = ToyboxMod.CARD_MANTLE_SALT,
    [7] = ToyboxMod.CARD_MANTLE_GLASS,
    [8] = ToyboxMod.CARD_MANTLE_METAL,
    [9] = ToyboxMod.CARD_MANTLE_GOLD,

    [21] = ToyboxMod.CARD_PRISMSTONE,
    [22] = ToyboxMod.CARD_FOIL_CARD,
    [23] = ToyboxMod.CARD_GREEN_APPLE,

    [41] = ToyboxMod.CARD_ALIEN_MIND,
    [42] = ToyboxMod.CARD_POISON_RAIN,
    [43] = ToyboxMod.CARD_FOUR_STARRED_LADYBUG,
    [44] = ToyboxMod.CARD_DARK_EXPLOSION,
    [45] = ToyboxMod.CARD_ENDLESS_CHAOS,
    [46] = ToyboxMod.CARD_CHAIN_REACTION,

    --[[
    [61] = ToyboxMod.CARD_TALISMAN,
    [62] = ToyboxMod.CARD_GRIM,
    [63] = ToyboxMod.CARD_FAMILIAR,
    [64] = ToyboxMod.CARD_SIGIL,
    [65] = ToyboxMod.CARD_ECTOPLASM,
    [66] = ToyboxMod.CARD_TRANCE,
    [67] = ToyboxMod.CARD_DEJA_VU,
    --]]
    
    [61] = ToyboxMod.CARD_THE_WISE_MEN,
    [62] = ToyboxMod.CARD_THE_ANGEL,
    [63] = ToyboxMod.CARD_THE_GATE,
    [64] = ToyboxMod.CARD_APOCALYPSE,
    [65] = ToyboxMod.CARD_THE_CRYPT,
    [66] = ToyboxMod.CARD_THE_REAPER,
    [67] = ToyboxMod.CARD_THE_DRAGON,
    [68] = ToyboxMod.CARD_DUALITY,
    [69] = ToyboxMod.CARD_THE_BARON,
    [70] = ToyboxMod.CARD_THE_TRICKSTER,
    [71] = ToyboxMod.CARD_MEMORY,
    [72] = ToyboxMod.CARD_THE_CARAVAN,
    [73] = ToyboxMod.CARD_EXCALIBUR,
    [74] = ToyboxMod.CARD_FATE,
    [75] = ToyboxMod.CARD_THE_PHANTOM,
    [76] = ToyboxMod.CARD_MIRAGE,
    [77] = ToyboxMod.CARD_THE_IDOL,

    --[101] = science cards
}

---@param pickup EntityPickup
local function replaceWithCard(_, pickup)
    if(SUB_TO_CARD[pickup.SubType]) then
        pickup:Morph(5,300,SUB_TO_CARD[pickup.SubType])
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, replaceWithCard, ToyboxMod.PICKUP_CARD_SPAWNER)
