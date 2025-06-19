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

local AtlasTransformationSprites = Sprite("gfx/eid/tb_eid_mantleicons.anm2", true)
    EID:addIcon("AtlasATransformationRock", "RockMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationPoop", "PoopMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationBone", "BoneMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationDark", "DarkMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationHoly", "HolyMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationSalt", "SaltMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationGlass", "GlassMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationMetal", "MetalMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationGold", "GoldMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationEmpty", "Empty", 0, 16, 16, 5, 6, AtlasTransformationSprites)
    EID:addIcon("AtlasATransformationTar", "TarMantle", 0, 16, 16, 5, 6, AtlasTransformationSprites)

local PlayerIconSprites = Sprite("gfx/eid/tb_eid_playericons.anm2", true)
    EID:addIcon("Player"..tostring(ToyboxMod.PLAYER_TYPE.ATLAS_A), "AtlasA", 0, 16, 16, 5, 6, PlayerIconSprites)
    EID:addIcon("Player"..tostring(ToyboxMod.PLAYER_TYPE.ATLAS_A_TAR), "AtlasATar", 0, 16, 16, 5, 6, PlayerIconSprites)
    EID:addIcon("Player"..tostring(ToyboxMod.PLAYER_TYPE.JONAS_A), "JonasA", 0, 16, 16, 5, 6, PlayerIconSprites)
    EID:addIcon("Player"..tostring(ToyboxMod.PLAYER_TYPE.MILCOM_A), "MilcomA", 0, 16, 16, 5, 6, PlayerIconSprites)

local MiscIconSprites = Sprite("gfx/eid/tb_eid_miscicons.anm2", true)
    EID:addIcon("ToyboxElectrifiedStatus", "Icons", 0, 16, 16, 5, 6, MiscIconSprites)
    EID:addIcon("ToyboxOverflowingStatus", "Icons", 1, 16, 16, 5, 6, MiscIconSprites)
    EID:addIcon("ToyboxGoldenPill", "Icons", 2, 16, 16, 5, 6, MiscIconSprites)
    EID:addIcon("ToyboxHorsePill", "Icons", 3, 16, 16, 5, 6, MiscIconSprites)
    EID:addIcon("ToyboxGoldenHorsePill", "Icons", 4, 16, 16, 5, 6, MiscIconSprites)

EID:addColor("ColorToyboxLimitBreak", nil, MakeSwagColor({{162,164,222},{255,234,160}}, 40))
EID:addColor("ColorToyboxHorsePill", nil, MakeSwagColor({{184,169,163},{111,134,192}}, 80))
EID:addColor("ColorJonas", MakeColor({173,189,228}))
EID:addColor("ColorItemStack", MakeColor({196,167,196}))

STORED.CONSTANTS = {
    --- ICONS ---
    Icon_AtlasRock = "AtlasATransformationRock",
    Icon_AtlasPoop = "AtlasATransformationPoop",
    Icon_AtlasBone = "AtlasATransformationBone",
    Icon_AtlasDark = "AtlasATransformationDark",
    Icon_AtlasHoly = "AtlasATransformationHoly",
    Icon_AtlasSalt = "AtlasATransformationSalt",
    Icon_AtlasGlass = "AtlasATransformationGlass",
    Icon_AtlasMetal = "AtlasATransformationMetal",
    Icon_AtlasGold = "AtlasATransformationGold",
    Icon_AtlasEmpty = "AtlasATransformationEmpty",
    Icon_AtlasTar = "AtlasATransformationTar",

    Icon_PlayerAtlas = "Player"..tostring(ToyboxMod.PLAYER_TYPE.ATLAS_A),
    Icon_PlayerAtlasTar = "Player"..tostring(ToyboxMod.PLAYER_TYPE.ATLAS_A_TAR),
    Icon_PlayerJonas = "Player"..tostring(ToyboxMod.PLAYER_TYPE.JONAS_A),
    Icon_PlayerMilcom = "Player"..tostring(ToyboxMod.PLAYER_TYPE.MILCOM_A),

    Icon_StatusElectrified = "ToyboxElectrifiedStatus",
    Icon_StatusOverflowing = "ToyboxOverflowingStatus",

    Icon_HorsePill = "ToyboxHorsePill",
    Icon_GoldenPill = "ToyboxGoldenPill",
    Icon_GoldenHorsePill = "ToyboxGoldenHorsePill",

    --- COLORS ---
    Color_LimitBreak = "ColorToyboxLimitBreak",
    Color_HorsePill = "ColorToyboxHorsePill",
    Color_Jonas = "ColorJonas",
    Color_ItemStack = "ColorItemStack",

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
        StackModifiers = {"ItemStack", "{{Collectible347}}", "{{ColorItemStack}}"},
        BFFSModifiers = {"BFFS", "{{Collectible247}}", "{{BlinkPink}}"},
        CarBatteryModifiers = {"CarBattery", "{{Collectible356}}", "{{BlinkYellowGreen}}"},
        DoubleModifiers = {"TrinketDouble", nil, "{{ColorGold}}"},
        TripleModifiers = {"TrinketTriple", nil, "{{ColorRainbow}}"},
        HorseModifiers = {"PillHorse", nil, nil},
        TarotClothModifiers = {"CardTarotCloth", nil, nil},
    }
}

return STORED