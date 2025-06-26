---@class DescriptionModifier
---@field Type number?
---@field Condition function?
---@field ToModify table


local STORED = {
    ITEMS = {},
    TRINKETS = {},
    PILLS = {},
    CARDS = {},
    PLAYERS = {},

    GLOBAL_MODIFIERS = {},

    CONSTANTS = {},
    FUNCTIONS = {},
}

local functions = {
    AddItem = function(itemData)
        STORED.ITEMS[itemData.ID] = {}
        for key, val in pairs(itemData) do
            STORED.ITEMS[itemData.ID][key] = val
        end
    end,

    AddTrinket = function(itemData)
        STORED.TRINKETS[itemData.ID] = {}
        for key, val in pairs(itemData) do
            STORED.TRINKETS[itemData.ID][key] = val
        end
    end,

    AddPill = function(itemData)
        STORED.PILLS[itemData.ID] = {}
        for key, val in pairs(itemData) do
            STORED.PILLS[itemData.ID][key] = val
        end
    end,

    AddCard = function(itemData)
        STORED.CARDS[itemData.ID] = {}
        for key, val in pairs(itemData) do
            STORED.CARDS[itemData.ID][key] = val
        end
    end,

    AddPlayer = function(itemData)
        STORED.PLAYERS[itemData.ID] = {}
        for key, val in pairs(itemData) do
            STORED.PLAYERS[itemData.ID][key] = val
        end
    end,

    AddGlobalModifier = function(itemData)
        STORED.GLOBAL_MODIFIERS[itemData.ID] = {}
        for key, val in pairs(itemData) do
            STORED.GLOBAL_MODIFIERS[itemData.ID][key] = val
        end
    end,

    ---@param lines string[] | string
    ---@return string
    StringTableToDescription = function(lines)
        if(type(lines)=="string") then
            return lines
        end

        local desc = lines[1]
        for i=2, #lines do
            desc = desc.."#"..lines[i]
        end
        return desc
    end,

    ---@return boolean
    IsTrinketDoubled = function(descObj)
        local hasBox = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX)
        local isGold = (descObj.ObjSubType & TrinketType.TRINKET_GOLDEN_FLAG ~= 0)

        return ((not hasBox) ~= (not isGold))
    end,

    ---@return boolean
    IsTrinketTripled = function(descObj)
        local hasBox = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX)
        local isGold = (descObj.ObjSubType & TrinketType.TRINKET_GOLDEN_FLAG ~= 0)

        return (hasBox and isGold)
    end,

    ---@param itemId CollectibleType
    ---@return function
    GetItemStackFunction = function(itemId)
        ---@return boolean
        return function(descObj)
            if(not descObj.Entity) then return false end

            local hasItem = PlayerManager.AnyoneHasCollectible(itemId)
            local hasDiplo = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DIPLOPIA)

            return (hasItem or hasDiplo)
        end
    end,
}

STORED.FUNCTIONS = functions

---@param color number[]
---@return KColor
local function MakeColor(color)
    return KColor(color[1]/255,color[2]/255,color[3]/255,(color[4] or 100)/100)
end

---@param colors number[][]
---@param maxAnimTime number
---@return function
local function MakeSwagColor(colors, maxAnimTime)
    for i=1, #colors do
        colors[i] = MakeColor(colors[i])
    end

    return function()
        maxAnimTime = maxAnimTime or 80
        local animTime = Game():GetFrameCount() % maxAnimTime
        local colorFractions = (maxAnimTime - 1) / #colors
        local subAnm = math.floor(animTime / (colorFractions + 1)) + 1
        local primaryColorIndex = subAnm % (#colors + 1)
        if primaryColorIndex == 0 then
            primaryColorIndex = 1
        end
        local secondaryColorIndex = (subAnm + 1) % (#colors + 1)
        if secondaryColorIndex == 0 then
            secondaryColorIndex = 1
        end
        return EID:interpolateColors(
            colors[primaryColorIndex],
            colors[secondaryColorIndex],
            (animTime % (colorFractions + 1)) / colorFractions
        )
    end
end

local iconSprite = Sprite("gfx_tb/eid/eid_icons.anm2", true)

--- PLAYERS
EID:addIcon("Player"..tostring(ToyboxMod.PLAYER_TYPE.ATLAS_A), "Players", 0, 16, 16, 0, 0, iconSprite)
EID:addIcon("Player"..tostring(ToyboxMod.PLAYER_TYPE.ATLAS_A_TAR), "Players", 1, 16, 16, 0, 0, iconSprite)
EID:addIcon("Player"..tostring(ToyboxMod.PLAYER_TYPE.JONAS_A), "Players", 2, 16, 16, 0, 0, iconSprite)
EID:addIcon("Player"..tostring(ToyboxMod.PLAYER_TYPE.MILCOM_A), "Players", 3, 16, 16, 0, 0, iconSprite)

--- TRANSFORMATIONS
EID:addIcon("ToyboxIconRockTransformation", "MantleTransformations", 0, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconPoopTransformation", "MantleTransformations", 1, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconBoneTransformation", "MantleTransformations", 2, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconDarkTransformation", "MantleTransformations", 3, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconHolyTransformation", "MantleTransformations", 4, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconSaltTransformation", "MantleTransformations", 5, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconGlassTransformation", "MantleTransformations", 6, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconMetalTransformation", "MantleTransformations", 7, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconGoldTransformation", "MantleTransformations", 8, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconEmptyTransformation", "MantleTransformations", 10, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconTarTransformation", "MantleTransformations", 9, 16, 16, 0, 0, iconSprite)

--- CARDS
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_ROCK), "Cards", 0, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_POOP), "Cards", 1, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_BONE), "Cards", 2, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_DARK), "Cards", 3, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_HOLY), "Cards", 4, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_SALT), "Cards", 5, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_GLASS), "Cards", 6, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_METAL), "Cards", 7, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.MANTLE_GOLD), "Cards", 8, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.LAUREL), "Cards", 9, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.YANNY), "Cards", 10, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.PRISMSTONE), "Cards", 11, 16, 16, 0, 0, iconSprite)
EID:addIcon("Card"..tostring(ToyboxMod.CONSUMABLE.FOIL_CARD), "Cards", 12, 16, 16, 0, 0, iconSprite)

--- MISC
EID:addIcon("ToyboxIconElectrifiedStatus", "Misc", 0, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconOverflowingStatus", "Misc", 1, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconGoldenPill", "Misc", 2, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconHorsePill", "Misc", 3, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconGoldenHorsePill", "Misc", 4, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconInk", "Misc", 5, 16, 16, 0, 0, iconSprite)
EID:addIcon("ToyboxIconTintedRoom", "Misc", 6, 16, 16, 0, 0, iconSprite)



--- COLORS
EID:addColor("ToyboxColorLimitBreak", nil, MakeSwagColor({{162,164,222},{255,234,160}}, 40))
EID:addColor("ToyboxColorHorsePill", nil, MakeSwagColor({{184,169,163},{111,134,192}}, 80))
EID:addColor("ToyboxColorJonas", MakeColor({173,189,228}))
EID:addColor("ToyboxColorItemStack", MakeColor({196,167,196}))

STORED.CONSTANTS = {
    --- ICONS ---
    Icon_AtlasRock = "{{ToyboxIconRockTransformation}}",
    Icon_AtlasPoop = "{{ToyboxIconPoopTransformation}}",
    Icon_AtlasBone = "{{ToyboxIconBoneTransformation}}",
    Icon_AtlasDark = "{{ToyboxIconDarkTransformation}}",
    Icon_AtlasHoly = "{{ToyboxIconHolyTransformation}}",
    Icon_AtlasSalt = "{{ToyboxIconSaltTransformation}}",
    Icon_AtlasGlass = "{{ToyboxIconGlassTransformation}}",
    Icon_AtlasMetal = "{{ToyboxIconMetalTransformation}}",
    Icon_AtlasGold = "{{ToyboxIconGoldTransformation}}",
    Icon_AtlasEmpty = "{{ToyboxIconEmptyTransformation}}",
    Icon_AtlasTar = "{{ToyboxIconTarTransformation}}",

    Icon_PlayerAtlas = "{{Player" .. tostring(ToyboxMod.PLAYER_TYPE.ATLAS_A) .. "}}",
    Icon_PlayerAtlasTar = "{{Player" .. tostring(ToyboxMod.PLAYER_TYPE.ATLAS_A_TAR) .. "}}",
    Icon_PlayerJonas = "{{Player" .. tostring(ToyboxMod.PLAYER_TYPE.JONAS_A) .. "}}",
    Icon_PlayerMilcom = "{{Player" .. tostring(ToyboxMod.PLAYER_TYPE.MILCOM_A) .. "}}",

    Icon_CardMantleRock = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_ROCK) .. "}}",
    Icon_CardMantlePoop = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_POOP) .. "}}",
    Icon_CardMantleBone = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_BONE) .. "}}",
    Icon_CardMantleDark = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_DARK) .. "}}",
    Icon_CardMantleHoly = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_HOLY) .. "}}",
    Icon_CardMantleSalt = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_SALT) .. "}}",
    Icon_CardMantleGlass = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_GLASS) .. "}}",
    Icon_CardMantleMetal = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_METAL) .. "}}",
    Icon_CardMantleGold = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.MANTLE_GOLD) .. "}}",
    Icon_CardLaurel = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.LAUREL) .. "}}",
    Icon_CardYanny = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.YANNY) .. "}}",
    Icon_CardPrismstone = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.PRISMSTONE) .. "}}",
    Icon_CardFoilCard = "{{Card" .. tostring(ToyboxMod.CONSUMABLE.FOIL_CARD) .. "}}",

    Icon_StatusElectrified = "{{ToyboxIconElectrifiedStatus}}",
    Icon_StatusOverflowing = "{{ToyboxIconOverflowingStatus}}",
    Icon_HorsePill = "{{ToyboxIconHorsePill}}",
    Icon_GoldenPill = "{{ToyboxIconGoldenPill}}",
    Icon_GoldenHorsePill = "{{ToyboxIconGoldenHorsePill}}",
    Icon_Ink = "{{ToyboxIconInk}}",
    Icon_TintedRoom = "{{ToyboxIconTintedRoom}}",

    --- COLORS ---
    Color_LimitBreak = "{{ToyboxColorLimitBreak}}",
    Color_HorsePill = "{{CToyboxColorHorsePill}}",
    Color_Jonas = "{{ToyboxColorJonas}}",
    Color_ItemStack = "{{ToyboxColorItemStack}}",

    --- ENUMS ---
    DescriptionModifier = {
        APPEND = 0,
        APPEND_BOTTOM = 0,
        APPEND_TOP = 1,
        REPLACE = 2,
    },
    ModifierCondition = {
        ItemStack = function(descObj)
            if(not descObj.Entity) then return false end

            local hasItem = PlayerManager.AnyoneHasCollectible(descObj.ObjSubType)
            local hasDiplo = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DIPLOPIA)

            return (hasItem or hasDiplo)
        end,
        BFFS = function(descObj)
            return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BFFS)
        end,
        CarBattery = function(descObj)
            return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
        end,

        TrinketDouble = STORED.FUNCTIONS.IsTrinketDoubled,
        TrinketTriple = STORED.FUNCTIONS.IsTrinketTripled,

        PillHorse = function(descObj)
            return (descObj.ObjSubType & PillColor.PILL_GIANT_FLAG ~= 0)
        end,

        CardTarotCloth = function(descObj)
            return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH)
        end,
    },
    ModifierFunctionKey = {
        StackModifiers = {"ItemStack", "{{Collectible347}}", "{{ToyboxColorItemStack}}"},
        BFFSModifiers = {"BFFS", "{{Collectible247}}", "{{BlinkPink}}"},
        CarBatteryModifiers = {"CarBattery", "{{Collectible356}}", "{{BlinkYellowGreen}}"},
        DoubleModifiers = {"TrinketDouble", nil, "{{ColorGold}}"},
        TripleModifiers = {"TrinketTriple", nil, "{{ColorRainbow}}"},
        HorseModifiers = {"PillHorse", nil, nil},
        TarotClothModifiers = {"CardTarotCloth", nil, nil},
    }
}



return STORED