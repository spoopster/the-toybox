local mod = MilcomMOD

mod.loadedData = false

--#region PLAYERS

mod.PLAYER_MILCOM_A = Isaac.GetPlayerTypeByName("Milcom", false)
mod.PLAYER_MILCOM_B = Isaac.GetPlayerTypeByName("Milcom", true)

mod.PLAYER_ATLAS_A = Isaac.GetPlayerTypeByName("Atlas", false)
mod.PLAYER_ATLAS_B = Isaac.GetPlayerTypeByName("Atlas", true)

--#endregion
--#region ACHIEVEMENTS

mod.ACH_MILCOM_B = Isaac.GetAchievementIdByName("Tainted Milcom")
mod.ACH_ATLAS_B = Isaac.GetAchievementIdByName("Tainted Atlas")

--#endregion
--#region ITEMS

-- mod.COLLECTIBLE_ = Isaac.GetItemIdByName("")
mod.COLLECTIBLE_SLICKWATER = Isaac.GetItemIdByName("Slickwater") --
mod.COLLECTIBLE_CONDENSED_MILK = Isaac.GetItemIdByName("Condensed Milk") --
mod.COLLECTIBLE_EYESTRAIN = Isaac.GetItemIdByName("Eyestrain")
mod.COLLECTIBLE_PILE_OF_SAND = Isaac.GetItemIdByName("Pile of Sand")
mod.COLLECTIBLE_OBSIDIAN_SHARD = Isaac.GetItemIdByName("Obsidian Shard")
mod.COLLECTIBLE_GOAT_MILK = Isaac.GetItemIdByName("Goat Milk") --
mod.COLLECTIBLE_BRONZE_BULL = Isaac.GetItemIdByName("Bronze Bull")
mod.COLLECTIBLE_BLOODY_NEEDLE = Isaac.GetItemIdByName("Bloody Needle") --
mod.COLLECTIBLE_NOSE_CANDY = Isaac.GetItemIdByName("Nose Candy") --
mod.COLLECTIBLE_LION_SKULL = Isaac.GetItemIdByName("Lion Skull") --
mod.COLLECTIBLE_CURSED_CHAINS = Isaac.GetItemIdByName("Cursed Chains")
mod.COLLECTIBLE_MAMMONS_OFFERING = Isaac.GetItemIdByName("Mammon's Offering")

--#region

--#endregion
--#region MILCOM_A

mod.MATERIAL_A_VARIANT = Isaac.GetEntityVariantByName("MATERIAL - Cardboard")
mod.MATERIAL_A_SUBTYPE = {
    CARDBOARD = 0,
    DUCT_TAPE = 1,
    NAILS = 2,
}

mod.CRAFTABLES_A = {
    MAKESHIFT_BOMB = {
        CATEGORY="MAKESHIFT_BOMB",
        LEVEL=1,
        NAME="MAKESHIFT BOMB",
        DESCRIPTION={
            "LETS YOU BLOW SHIT UP",
        },

        FRAME=0,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    NAIL_BOMB = {
        CATEGORY="MAKESHIFT_BOMB",
        LEVEL=2,
        NAME="NAIL BOMB",
        DESCRIPTION={
            "TEST",
        },

        FRAME=4,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    BOMB3 = {
        CATEGORY="MAKESHIFT_BOMB",
        LEVEL=3,
        NAME="BOMB UPGRADE 3",
        DESCRIPTION={
            "TEST",
        },

        FRAME=8,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    BOMB4 = {
        CATEGORY="MAKESHIFT_BOMB",
        LEVEL=4,
        NAME="BOMB UPGRADE 4",
        DESCRIPTION={
            "TEST",
        },

        FRAME=12,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },

    MAKESHIFT_KEY = {
        CATEGORY="MAKESHIFT_KEY",
        LEVEL=1,
        NAME="MAKESHIFT KEY",
        DESCRIPTION={
            "TEST",
        },

        FRAME=1,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    KEY2 = {
        CATEGORY="MAKESHIFT_KEY",
        LEVEL=2,
        NAME="KEY UPGRADE 2",
        DESCRIPTION={
            "TEST",
        },

        FRAME=5,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    KEY3 = {
        CATEGORY="MAKESHIFT_KEY",
        LEVEL=3,
        NAME="KEY UPGRADE 3",
        DESCRIPTION={
            "TEST",
        },

        FRAME=9,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    KEY4 = {
        CATEGORY="MAKESHIFT_KEY",
        LEVEL=4,
        NAME="KEY UPGRADE 4",
        DESCRIPTION={
            "TEST",
        },

        FRAME=13,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    NAILGUN = {
        CATEGORY="NAILGUN",
        LEVEL=1,
        NAME="NAILGUN",
        DESCRIPTION={
            "TEST",
        },

        FRAME=2,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    GUN2 = {
        CATEGORY="NAILGUN",
        LEVEL=2,
        NAME="GUN UPGRADE 2",
        DESCRIPTION={
            "TEST",
        },

        FRAME=6,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    GUN3 = {
        CATEGORY="NAILGUN",
        LEVEL=3,
        NAME="GUN UPGRADE 3",
        DESCRIPTION={
            "TEST",
        },

        FRAME=10,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    GUN4 = {
        CATEGORY="NAILGUN",
        LEVEL=4,
        NAME="GUN UPGRADE 4",
        DESCRIPTION={
            "TEST",
        },

        FRAME=14,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    MAGIC_STAFF = {
        CATEGORY="MAGIC_STAFF",
        LEVEL=1,
        NAME="MAGIC STAFF",
        DESCRIPTION={
            "TEST",
        },

        FRAME=3,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    STAFF2 = {
        CATEGORY="MAGIC_STAFF",
        LEVEL=2,
        NAME="STAFF UPGRADE 2",
        DESCRIPTION={
            "TEST",
        },

        FRAME=7,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    STAFF3 = {
        CATEGORY="MAGIC_STAFF",
        LEVEL=3,
        NAME="STAFF UPGRADE 3",
        DESCRIPTION={
            "TEST",
        },

        FRAME=11,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    STAFF4 = {
        CATEGORY="MAGIC_STAFF",
        LEVEL=4,
        NAME="STAFF UPGRADE 4",
        DESCRIPTION={
            "TEST",
        },

        FRAME=15,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    CREDIT_CARDBOARD = {
        CATEGORY="CREDIT_CARDBOARD",
        LEVEL=1,
        NAME="CREDIT CARDBOARD",
        DESCRIPTION={
            "LETS YOU SPEND YOUR MONEY WISELY",
        },
        FRAME=0,
        COST={CARDBOARD=4, TAPE=0, NAILS=0},
    }
}
mod.CRAFTABLE_A_CATEGORIES = {
    --[[MAKESHIFT BOMB]]{ "MAKESHIFT_BOMB", "NAIL_BOMB", "BOMB3", "BOMB4", },
    --[[MAKESHIFT KEY]]{ "MAKESHIFT_KEY", "KEY2", "KEY3", "KEY4", },
    --[[NAILGUN]]{ "NAILGUN", "GUN2", "GUN3", "GUN4", },
    --[[MAGIC STAFF]]{ "MAGIC_STAFF", "STAFF2", "STAFF3", "STAFF4", },
    --[[CREDIT CARDBOARD]]{ "CREDIT_CARDBOARD", },
}

--#endregion
--#region ATLAS_A
mod.CONSUMABLE_MANTLE_ROCK = Isaac.GetCardIdByName("Rock Mantle")
mod.CONSUMABLE_MANTLE_POOP = Isaac.GetCardIdByName("Poop Mantle")
mod.CONSUMABLE_MANTLE_BONE = Isaac.GetCardIdByName("Bone Mantle")
mod.CONSUMABLE_MANTLE_DARK = Isaac.GetCardIdByName("Dark Mantle")
mod.CONSUMABLE_MANTLE_HOLY = Isaac.GetCardIdByName("Holy Mantle")
mod.CONSUMABLE_MANTLE_SALT = Isaac.GetCardIdByName("Salt Mantle")
mod.CONSUMABLE_MANTLE_GLASS = Isaac.GetCardIdByName("Glass Mantle")
mod.CONSUMABLE_MANTLE_METAL = Isaac.GetCardIdByName("Metal Mantle")
mod.CONSUMABLE_MANTLE_GOLD = Isaac.GetCardIdByName("Gold Mantle")

mod.EFFECT_GOLDMANTLE_BREAK = Isaac.GetEntityVariantByName("Gold Mantle Shatter")

mod.SFX_ATLASA_ROCKHURT = Isaac.GetSoundIdByName("AtlasA_RockHurt")
mod.SFX_ATLASA_ROCKBREAK = Isaac.GetSoundIdByName("AtlasA_RockBreak")
mod.SFX_ATLASA_METALBLOCK = Isaac.GetSoundIdByName("AtlasA_MetalBlock")
mod.SFX_ATLASA_METALBREAK = Isaac.GetSoundIdByName("AtlasA_MetalBreak")
mod.SFX_ATLASA_GLASSBREAK = Isaac.GetSoundIdByName("AtlasA_GlassBreak")

mod.MANTLES = {
    NONE = 0,
    DEFAULT = 1,
    POOP = 2,
    BONE = 3,
    DARK = 4,
    HOLY = 5,
    SALT = 6,
    GLASS = 7,
    METAL = 8,
    GOLD = 9,

    TAR = 1024,
}
mod.MANTLES_HP = {
    NONE = 0,
    DEFAULT = 2,
    POOP = 2,
    BONE = 3,
    DARK = 2,
    HOLY = 2,
    SALT = 2,
    GLASS = 1,
    METAL = 3,
    GOLD = 2,

    TAR = 0,
}
mod.MANTLE_TO_SUBTYPE = {
    [mod.MANTLES.DEFAULT] = mod.CONSUMABLE_MANTLE_ROCK,
    [mod.MANTLES.POOP] = mod.CONSUMABLE_MANTLE_POOP,
    [mod.MANTLES.BONE] = mod.CONSUMABLE_MANTLE_BONE,
    [mod.MANTLES.DARK] = mod.CONSUMABLE_MANTLE_DARK,
    [mod.MANTLES.HOLY] = mod.CONSUMABLE_MANTLE_HOLY,
    [mod.MANTLES.SALT] = mod.CONSUMABLE_MANTLE_SALT,
    [mod.MANTLES.GLASS] = mod.CONSUMABLE_MANTLE_GLASS,
    [mod.MANTLES.METAL] = mod.CONSUMABLE_MANTLE_METAL,
    [mod.MANTLES.GOLD] = mod.CONSUMABLE_MANTLE_GOLD,
}
mod.SUBTYPE_TO_MANTLE = {
    [mod.CONSUMABLE_MANTLE_ROCK] = mod.MANTLES.DEFAULT,
    [mod.CONSUMABLE_MANTLE_POOP] = mod.MANTLES.POOP,
    [mod.CONSUMABLE_MANTLE_BONE] = mod.MANTLES.BONE,
    [mod.CONSUMABLE_MANTLE_DARK] = mod.MANTLES.DARK,
    [mod.CONSUMABLE_MANTLE_HOLY] = mod.MANTLES.HOLY,
    [mod.CONSUMABLE_MANTLE_SALT] = mod.MANTLES.SALT,
    [mod.CONSUMABLE_MANTLE_GLASS] = mod.MANTLES.GLASS,
    [mod.CONSUMABLE_MANTLE_METAL] = mod.MANTLES.METAL,
    [mod.CONSUMABLE_MANTLE_GOLD] = mod.MANTLES.GOLD,
}
mod.TRANSFORMATION_TO_COSTUME = {
    [mod.MANTLES.DEFAULT] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_rock.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_rock_wings.anm2")},
    [mod.MANTLES.POOP] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_poop.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_poop_wings.anm2")},
    [mod.MANTLES.BONE] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_bone.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_bone_wings.anm2")},
    [mod.MANTLES.DARK] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_dark.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_dark_wings.anm2")},
    [mod.MANTLES.HOLY] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_holy.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_holy_wings.anm2")},
    [mod.MANTLES.SALT] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_salt.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_salt_wings.anm2")},
    [mod.MANTLES.GLASS] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_glass.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_glass_wings.anm2")},
    [mod.MANTLES.METAL] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_metal.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_metal_wings.anm2")},
    [mod.MANTLES.GOLD] = {Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_gold.anm2"), Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_gold_wings.anm2")},
}
mod.TAR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_tar.anm2")

-- PICKING MANTLES ENUMS
mod.SAME_MANTLE_BIAS = {
    [0]=1,
    [1]=7.5,
    [2]=25,
    [3]=1,
}
mod.MANTLE_PICKER = {
    {OUTCOME=mod.MANTLES.DEFAULT, WEIGHT=1},
    {OUTCOME=mod.MANTLES.POOP, WEIGHT=1},
    {OUTCOME=mod.MANTLES.BONE, WEIGHT=1},
    {OUTCOME=mod.MANTLES.DARK, WEIGHT=1},
    {OUTCOME=mod.MANTLES.HOLY, WEIGHT=1},
    {OUTCOME=mod.MANTLES.SALT, WEIGHT=1},
    {OUTCOME=mod.MANTLES.GLASS, WEIGHT=1},
    {OUTCOME=mod.MANTLES.METAL, WEIGHT=1},
    {OUTCOME=mod.MANTLES.GOLD, WEIGHT=1},
}

-- MANTLE HP RENDER ENUMS
mod.MANTLE_SHARD_GRAVITY = 7
mod.MANTLE_TYPE_TO_SHARD_COLOR = {
    [mod.MANTLES.DEFAULT] = Color(153/255,139/255,136/255,1),
    [mod.MANTLES.POOP] = Color(124/255,86/255,52/255,1),
    [mod.MANTLES.BONE] = Color(95/255,112/255,121/255,1),
    [mod.MANTLES.DARK] = Color(59/255,59/255,59/255,1),
    [mod.MANTLES.HOLY] = Color(190/255,190/255,190/255,1),
    [mod.MANTLES.SALT] = Color(1,1,1,1),
    [mod.MANTLES.GLASS] = Color(1,1,1,1),
    [mod.MANTLES.METAL] = Color(147/255,147/255,147/255,1),
    [mod.MANTLES.GOLD] = Color(205/255,181/255,60/255,1),
    [mod.MANTLES.NONE] = Color(0,0,0,0),
    [mod.MANTLES.TAR] = Color(0,0,0,1),
}

mod.MANTLE_TYPE_TO_ANM = {
    [mod.MANTLES.DEFAULT] = "RockMantle",
    [mod.MANTLES.POOP] = "PoopMantle",
    [mod.MANTLES.BONE] = "BoneMantle",
    [mod.MANTLES.DARK] = "DarkMantle",
    [mod.MANTLES.HOLY] = "HolyMantle",
    [mod.MANTLES.SALT] = "SaltMantle",
    [mod.MANTLES.GLASS] = "GlassMantle",
    [mod.MANTLES.METAL] = "MetalMantle",
    [mod.MANTLES.GOLD] = "GoldMantle",
    [mod.MANTLES.NONE] = "Empty",
    [mod.MANTLES.TAR] = "TarMantle",
    [1000] = "Unknown",
}

--#endregion