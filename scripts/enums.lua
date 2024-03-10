local mod = MilcomMOD
local sfx = SFXManager()

mod.loadedData = false

--#region --!PLAYERS

mod.PLAYER_MILCOM_A = Isaac.GetPlayerTypeByName("Milcom", false)
mod.PLAYER_MILCOM_B = Isaac.GetPlayerTypeByName("Milcom", true)

mod.PLAYER_ATLAS_A = Isaac.GetPlayerTypeByName("Atlas", false)
mod.PLAYER_ATLAS_B = Isaac.GetPlayerTypeByName("Atlas", true)

--#endregion
--#region --!ACHIEVEMENTS

mod.ACH_MILCOM_B = Isaac.GetAchievementIdByName("Tainted Milcom")
mod.ACH_ATLAS_B = Isaac.GetAchievementIdByName("Tainted Atlas")

--#endregion
--#region --!ITEMS

--*COLLECTIBLES
-- mod.COLLECTIBLE_ = Isaac.GetItemIdByName("")
mod.COLLECTIBLE_COCONUT_OIL = Isaac.GetItemIdByName("Coconut Oil")                  --!DONE
mod.COLLECTIBLE_CONDENSED_MILK = Isaac.GetItemIdByName("Condensed Milk")            --!DONE
mod.COLLECTIBLE_EYESTRAIN = Isaac.GetItemIdByName("Eyestrain")
mod.COLLECTIBLE_PILE_OF_SAND = Isaac.GetItemIdByName("Pile of Sand")
mod.COLLECTIBLE_OBSIDIAN_SHARD = Isaac.GetItemIdByName("Obsidian Shard")
mod.COLLECTIBLE_GOAT_MILK = Isaac.GetItemIdByName("Goat Milk")                      --!DONE
mod.COLLECTIBLE_BRONZE_BULL = Isaac.GetItemIdByName("Bronze Bull")
mod.COLLECTIBLE_BLOODY_NEEDLE = Isaac.GetItemIdByName("Bloody Needle")              --!DONE
mod.COLLECTIBLE_NOSE_CANDY = Isaac.GetItemIdByName("Nose Candy")                    --!DONE
mod.COLLECTIBLE_LION_SKULL = Isaac.GetItemIdByName("Lion Skull")                    --!DONE
mod.COLLECTIBLE_CURSED_CHAINS = Isaac.GetItemIdByName("Cursed Chains")
mod.COLLECTIBLE_MAMMONS_OFFERING = Isaac.GetItemIdByName("Mammon's Offering")       --!DONE
mod.COLLECTIBLE_WOODEN_DOLL = Isaac.GetItemIdByName("Wooden Doll")
mod.COLLECTIBLE_CARAMEL_APPLE = Isaac.GetItemIdByName("Caramel Apple")              --!DONE
mod.COLLECTIBLE_BLOOD_RITUAL = Isaac.GetItemIdByName("Blood Ritual")                --!DONE
mod.COLLECTIBLE_TECH_IX = Isaac.GetItemIdByName("Tech IX")                          --!DONE
mod.COLLECTIBLE_CRICKETS_JAW = Isaac.GetItemIdByName("Cricket's Jaw")
mod.COLLECTIBLE_PAINKILLERS = Isaac.GetItemIdByName("Painkillers")                  --!DONE
mod.COLLECTIBLE_SILK_BAG = Isaac.GetItemIdByName("Silk Bag")                        --!DONE
mod.COLLECTIBLE_PAINT_BUCKET = Isaac.GetItemIdByName("Paint Bucket")
mod.COLLECTIBLE_FATAL_SIGNAL = Isaac.GetItemIdByName("Fatal Signal")                --!DONE
mod.COLLECTIBLE_METEOR_SHOWER = Isaac.GetItemIdByName("Meteor Shower")              --!DONE
mod.COLLECTIBLE_BLESSED_RING = Isaac.GetItemIdByName("Blessed Ring")
mod.COLLECTIBLE_SIGIL_OF_GREED = Isaac.GetItemIdByName("Sigil of Greed")
mod.COLLECTIBLE_PEPPER_X = Isaac.GetItemIdByName("Pepper X")                        --!DONE
mod.COLLECTIBLE_SCATTERED_TOME = Isaac.GetItemIdByName("Scattered Tome")

--mod.COLLECTIBLE_LASER_POINTER = Isaac.GetItemIdByName("Laser Pointer")            --*UNUSED (i dont like the item)

--*TRINKETS
mod.TRINKET_PLASMA_GLOBE = Isaac.GetTrinketIdByName("Plasma Globe")

--*CONSUMABLES
mod.CONSUMABLE_MANTLE_ROCK = Isaac.GetCardIdByName("Rock Mantle")
mod.CONSUMABLE_MANTLE_POOP = Isaac.GetCardIdByName("Poop Mantle")
mod.CONSUMABLE_MANTLE_BONE = Isaac.GetCardIdByName("Bone Mantle")
mod.CONSUMABLE_MANTLE_DARK = Isaac.GetCardIdByName("Dark Mantle")
mod.CONSUMABLE_MANTLE_HOLY = Isaac.GetCardIdByName("Holy Mantle")
mod.CONSUMABLE_MANTLE_SALT = Isaac.GetCardIdByName("Salt Mantle")
mod.CONSUMABLE_MANTLE_GLASS = Isaac.GetCardIdByName("Glass Mantle")
mod.CONSUMABLE_MANTLE_METAL = Isaac.GetCardIdByName("Metal Mantle")
mod.CONSUMABLE_MANTLE_GOLD = Isaac.GetCardIdByName("Gold Mantle")

--#endregion
--#region --!ENTITIES

--*EFFECTS
mod.EFFECT_BLOOD_RITUAL_PENTAGRAM = Isaac.GetEntityVariantByName("Blood Ritual Pentagram")
mod.EFFECT_METEOR_TEAR_EXPLOSION = Isaac.GetEntityVariantByName("Meteor Tear Explosion")

mod.EFFECT_ATLAS_BOOKOFSHADOWS_BUBBLE = Isaac.GetEntityVariantByName("ATLAS BOOK OF SHADOWS BUBBLE")
mod.EFFECT_GOLDMANTLE_BREAK = Isaac.GetEntityVariantByName("Gold Mantle Shatter")

--*PICKUPS
mod.PICKUP_MAMMONS_OFFERING_PENNY = Isaac.GetEntityVariantByName("Mammon's Offering Penny")

--*TEARS
mod.TEAR_METEOR = Isaac.GetEntityVariantByName("Meteor Tear")

--#endregion
--#region --!SFX

mod.SFX_SILK_BAG_SHIELD = Isaac.GetSoundIdByName("Toybox_SilkBag_Shield"); sfx:Preload(mod.SFX_SILK_BAG_SHIELD)

mod.SFX_ATLASA_ROCKHURT = Isaac.GetSoundIdByName("Toybox_AtlasA_RockHurt"); sfx:Preload(mod.SFX_ATLASA_ROCKHURT)
mod.SFX_ATLASA_ROCKBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_RockBreak"); sfx:Preload(mod.SFX_ATLASA_ROCKBREAK)
mod.SFX_ATLASA_METALBLOCK = Isaac.GetSoundIdByName("Toybox_AtlasA_MetalBlock"); sfx:Preload(mod.SFX_ATLASA_METALBLOCK)
mod.SFX_ATLASA_METALBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_MetalBreak"); sfx:Preload(mod.SFX_ATLASA_METALBREAK)
mod.SFX_ATLASA_GLASSBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_GlassBreak"); sfx:Preload(mod.SFX_ATLASA_GLASSBREAK)

--#endregion
--#region --!CUSTOM_ENUMS

mod.SHADERS = {
    EMPTY = "ToyboxEmptyShader",
    BLOOM = "ToyboxBloomShader",
    FIND_MY_PAGES = "ToyboxStaticShader",
}

mod.CUSTOM_CALLBACKS = {
    PRE_ATLAS_LOSE_MANTLE = "TOYBOX_PRE_ATLAS_LOSE_MANTLE",
    POST_ATLAS_LOSE_MANTLE = "TOYBOX_POST_ATLAS_LOSE_MANTLE",
    POST_PLAYER_BOMB_DETONATE = "TOYBOX_POST_PLAYER_BOMB_DETONATE",
    POST_PLAYER_KILL_NPC = "TOYBOX_POST_PLAYER_KILL_NPC",
    POST_MILCOM_CRAFT_CRAFTABLE = "TOYBOX_POST_MILCOM_CRAFT_CRAFTABLE",
    POST_PLAYER_ATTACK = "TOYBOX_POST_PLAYER_ATTACK",
}

mod.CUSTOM_BOMBFLAGS = {
    FLAG_MAKESHIFT_BOMB1 = 1<<0,
    FLAG_MAKESHIFT_BOMB2 = 1<<1,
}

--#endregion
--#region --!MILCOM_A

mod.MATERIAL_A_VARIANT = Isaac.GetEntityVariantByName("MATERIAL - Cardboard")
mod.MATERIAL_A_SUBTYPE = {
    CARDBOARD = 0,
    DUCT_TAPE = 1,
    NAILS = 2,
}

mod.CRAFTABLES_A = {
    { --* MAKESHIFT BOMB
        LEVEL=1,
        NAME="MAKESHIFT BOMB",
        DESCRIPTION={
            "LETS YOU BLOW SHIT UP",
        },

        FRAME=0,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* NAIL BOMB
        PREV_CRAFTABLE = "MAKESHIFT BOMB",

        LEVEL=2,
        NAME="NAIL BOMB",
        DESCRIPTION={
            "TEST",
        },

        FRAME=4,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* BOMB 3
        PREV_CRAFTABLE = "NAIL BOMB",

        LEVEL=3,
        NAME="BOMB UPGRADE 3",
        DESCRIPTION={
            "TEST",
        },

        FRAME=8,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* BOMB 4
        PREV_CRAFTABLE = "BOMB UPGRADE 3",

        LEVEL=4,
        NAME="BOMB UPGRADE 4",
        DESCRIPTION={
            "TEST",
        },

        FRAME=12,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },

    { --* MAKESHIFT KEY
        LEVEL=1,
        NAME="MAKESHIFT KEY",
        DESCRIPTION={
            "TEST",
        },

        FRAME=1,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* KEY 2
        PREV_CRAFTABLE = "MAKESHIFT KEY",

        LEVEL=2,
        NAME="KEY UPGRADE 2",
        DESCRIPTION={
            "TEST",
        },

        FRAME=5,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* KEY 3
        PREV_CRAFTABLE = "KEY UPGRADE 2",

        LEVEL=3,
        NAME="KEY UPGRADE 3",
        DESCRIPTION={
            "TEST",
        },

        FRAME=9,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* KEY 4
        PREV_CRAFTABLE = "KEY UPGRADE 3",

        LEVEL=4,
        NAME="KEY UPGRADE 4",
        DESCRIPTION={
            "TEST",
        },

        FRAME=13,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },

    { --* NAILGUN
        LEVEL=1,
        NAME="NAILGUN",
        DESCRIPTION={
            "AUTOFIRE NAILS AT NEARBY ENEMIES",
        },

        FRAME=2,
        COST={CARDBOARD=1, TAPE=1, NAILS=2},
    },
    { --* NAILRIFLE
        PREV_CRAFTABLE = "NAILGUN",

        LEVEL=2,
        NAME="NAILRIFLE",
        DESCRIPTION={
            "SPEED SCALES, MORE RANGE & DAMAGE",
        },

        FRAME=6,
        COST={CARDBOARD=1, TAPE=0, NAILS=1},
    },
    { --* NAILGUN 3
        PREV_CRAFTABLE = "NAILRIFLE",

        LEVEL=3,
        NAME="GUN UPGRADE 3",
        DESCRIPTION={
            "TEST",
        },

        FRAME=10,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* NAILGUN 4
        PREV_CRAFTABLE = "GUN UPGRADE 3",

        LEVEL=4,
        NAME="GUN UPGRADE 4",
        DESCRIPTION={
            "TEST",
        },

        FRAME=14,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },

    { --* MAGIC STAFF
        LEVEL=1,
        NAME="MAGIC STAFF",
        DESCRIPTION={
            "TEST",
        },

        FRAME=3,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* MAGIC STAFF 2
        PREV_CRAFTABLE = "MAGIC STAFF",

        LEVEL=2,
        NAME="STAFF UPGRADE 2",
        DESCRIPTION={
            "TEST",
        },

        FRAME=7,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* MAGIC STAFF 3
        PREV_CRAFTABLE = "STAFF UPGRADE 2",

        LEVEL=3,
        NAME="STAFF UPGRADE 3",
        DESCRIPTION={
            "TEST",
        },

        FRAME=11,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },
    { --* MAGIC STAFF 4
        PREV_CRAFTABLE = "STAFF UPGRADE 3",

        LEVEL=4,
        NAME="STAFF UPGRADE 4",
        DESCRIPTION={
            "TEST",
        },

        FRAME=15,
        COST={CARDBOARD=1, TAPE=1, NAILS=0},
    },

    { --* CREDIT CARDBOARD
        LEVEL=1,
        NAME="CREDIT CARDBOARD",
        DESCRIPTION={
            "LETS YOU SPEND YOUR MONEY WISELY",
        },
        FRAME=0,
        COST={CARDBOARD=4, TAPE=0, NAILS=0},
    },
}
mod.CRAFTABLE_A_CATEGORIES = {
    --[[MAKESHIFT BOMB]]{ "MAKESHIFT_BOMB", "NAIL_BOMB", "BOMB3", "BOMB4", },
    --[[MAKESHIFT KEY]]{ "MAKESHIFT_KEY", "KEY2", "KEY3", "KEY4", },
    --[[NAILGUN]]{ "NAILGUN", "NAILRIFLE", "GUN3", "GUN4", },
    --[[MAGIC STAFF]]{ "MAGIC_STAFF", "STAFF2", "STAFF3", "STAFF4", },
    --[[CREDIT CARDBOARD]]{ "CREDIT_CARDBOARD", },
}

--#endregion
--#region --!ATLAS_A
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