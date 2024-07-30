local mod = MilcomMOD
local sfx = SFXManager()

mod.loadedData = false

--#region --!PLAYERS

mod.PLAYER_MILCOM_A = Isaac.GetPlayerTypeByName("Milcom", false)
mod.PLAYER_MILCOM_B = Isaac.GetPlayerTypeByName("Milcom", true)

mod.PLAYER_ATLAS_A = Isaac.GetPlayerTypeByName("Atlas", false)
mod.PLAYER_ATLAS_A_TAR = Isaac.GetPlayerTypeByName("The Tar", false)
mod.PLAYER_ATLAS_B = Isaac.GetPlayerTypeByName("Atlas", true)

mod.PLAYER_JONAS_A = Isaac.GetPlayerTypeByName("Jonas", false)
mod.PLAYER_JONAS_B = Isaac.GetPlayerTypeByName("Jonas", true)

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
mod.COLLECTIBLE_EYESTRAIN = Isaac.GetItemIdByName("Eyestrain")                      --!DONE
mod.COLLECTIBLE_PILE_OF_SAND = Isaac.GetItemIdByName("Pile of Sand")
mod.COLLECTIBLE_OBSIDIAN_SHARD = Isaac.GetItemIdByName("Obsidian Shard")
mod.COLLECTIBLE_OBSIDIAN_CHUNK = Isaac.GetItemIdByName("Obsidian Chunk")
mod.COLLECTIBLE_GOAT_MILK = Isaac.GetItemIdByName("Goat Milk")                      --!DONE
mod.COLLECTIBLE_BRONZE_BULL = Isaac.GetItemIdByName("Bronze Bull")
mod.COLLECTIBLE_PLIERS = Isaac.GetItemIdByName("Pliers")              --!DONE
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
mod.COLLECTIBLE_BLESSED_RING = Isaac.GetItemIdByName("Blessed Ring")                --!DONE
mod.COLLECTIBLE_SIGIL_OF_GREED = Isaac.GetItemIdByName("Sigil of Greed")
mod.COLLECTIBLE_PEPPER_X = Isaac.GetItemIdByName("Pepper X")                        --!DONE
mod.COLLECTIBLE_SCATTERED_TOME = Isaac.GetItemIdByName("Scattered Tome")            --!DONE
mod.COLLECTIBLE_TOY_GUN = Isaac.GetItemIdByName("Toy Gun")                          --!DONE
mod.COLLECTIBLE_GOLDEN_TWEEZERS = Isaac.GetItemIdByName("Golden Tweezers")                    --!DONE
mod.COLLECTIBLE_MALICIOUS_BRAIN = Isaac.GetItemIdByName("Malicious Brain")

mod.COLLECTIBLE_4_4 = Isaac.GetItemIdByName("4 4")                                  --!DONE
--mod.COLLECTIBLE_LASER_POINTER = Isaac.GetItemIdByName("Laser Pointer")            --*UNUSED (i dont like the item)

--*TRINKETS
mod.TRINKET_LIMIT_BREAK = Isaac.GetTrinketIdByName("LIMIT BREAK")
mod.TRINKET_PLASMA_GLOBE = Isaac.GetTrinketIdByName("Plasma Globe")                 --!DONE
mod.TRINKET_FOAM_BULLET = Isaac.GetTrinketIdByName("Foam Bullet")                   --!DONE

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

mod.PILL_I_BELIEVE = Isaac.GetPillEffectByName("I Believe I Can Fly!")
mod.PILL_DYSLEXIA = Isaac.GetPillEffectByName("Dyslexia")
mod.PILL_DMG_UP = Isaac.GetPillEffectByName("Damage Up")
mod.PILL_DMG_DOWN = Isaac.GetPillEffectByName("Damage Down")
mod.PILL_DEMENTIA = Isaac.GetPillEffectByName("Dementia")
mod.PILL_PARASITE = Isaac.GetPillEffectByName("Parasite!")
mod.PILL_FENT = Isaac.GetPillEffectByName("Fent")
mod.PILL_YOUR_SOUL_IS_MINE = Isaac.GetPillEffectByName("Your Soul is Mine")
mod.PILL_ARTHRITIS = Isaac.GetPillEffectByName("Arthritis")
mod.PILL_OSSIFICATION = Isaac.GetPillEffectByName("Ossification")
--mod.PILL_BLEEEGH = Isaac.GetPillEffectByName("Bleeegh!")
mod.PILL_VITAMINS = Isaac.GetPillEffectByName("Vitamins!")
mod.PILL_COAGULANT = Isaac.GetPillEffectByName("Coagulant")
mod.PILL_FOOD_POISONING = Isaac.GetPillEffectByName("Food Poisoning")
mod.PILL_HEARTBURN = Isaac.GetPillEffectByName("Heartburn")
mod.PILL_MUSCLE_ATROPHY = Isaac.GetPillEffectByName("Muscle Atrophy")
mod.PILL_CAPSULE = Isaac.GetPillEffectByName("Capsule")

--*NULL
mod.NULL_DYSLEXIA_NORMAL = Isaac.GetNullItemIdByName("dyslexia normal")
mod.NULL_DYSLEXIA_HORSE = Isaac.GetNullItemIdByName("dyslexia horse")

--#endregion
--#region --!ENTITIES

--*FAMILIARS
mod.FAMILIAR_TOME = Isaac.GetEntityVariantByName("Scattered Tome")
mod.FAMILIAR_HYPNOS = Isaac.GetEntityVariantByName("Malicious Brain")

--*EFFECTS
mod.EFFECT_BLOOD_RITUAL_PENTAGRAM = Isaac.GetEntityVariantByName("Blood Ritual Pentagram")
mod.EFFECT_METEOR_TEAR_EXPLOSION = Isaac.GetEntityVariantByName("Meteor Tear Explosion")
mod.EFFECT_GOLDMANTLE_BREAK = Isaac.GetEntityVariantByName("Gold Mantle Shatter")
mod.EFFECT_GREED_SIGIL_CHARGEBAR = Isaac.GetEntityVariantByName("Greed Sigil Chargebar")

--*PICKUPS
mod.PICKUP_MAMMONS_OFFERING_PENNY = Isaac.GetEntityVariantByName("Mammon's Offering Penny")

--*TEARS
mod.TEAR_METEOR = Isaac.GetEntityVariantByName("Meteor Tear")
mod.TEAR_BULLET = Isaac.GetEntityVariantByName("Foam Bullet Tear")
mod.TEAR_SOUNDWAVE = Isaac.GetEntityVariantByName("Soundwave Tear")
mod.TEAR_PAPER = Isaac.GetEntityVariantByName("Tome Paper Tear")

--*NPCS
mod.NPC_MAIN = Isaac.GetEntityTypeByName("Shy Gal")
mod.BOSS_SHYGAL = Isaac.GetEntityVariantByName("Shy Gal")
mod.NPC_SHYGAL_CLONE = Isaac.GetEntityVariantByName("Shy Gal Clone")
mod.NPC_SHYGAL_MASK = Isaac.GetEntityVariantByName("Shy Gal Mask")

--#endregion
--#region --!SFX

mod.SFX_4_4_SCREAM = Isaac.GetSoundIdByName("Toybox_4_4_Scream"); sfx:Preload(mod.SFX_4_4_SCREAM)
mod.SFX_SILK_BAG_SHIELD = Isaac.GetSoundIdByName("Toybox_SilkBag_Shield"); sfx:Preload(mod.SFX_SILK_BAG_SHIELD)
mod.SFX_TOY_GUN_RELOAD = Isaac.GetSoundIdByName("Toybox_ToyGun_Reload"); sfx:Preload(mod.SFX_TOY_GUN_RELOAD)
mod.SFX_BULLET_FIRE = Isaac.GetSoundIdByName("Toybox_Bullet_Shoot"); sfx:Preload(mod.SFX_BULLET_FIRE)
mod.SFX_BULLET_HIT = Isaac.GetSoundIdByName("Toybox_Bullet_Hit"); sfx:Preload(mod.SFX_BULLET_HIT)

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
}

mod.COPYING_FAMILIARS = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.SPRINKLER] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
    --[FamiliarVariant.FATES_REWARD] = true,
}

mod.CUSTOM_CALLBACKS = {
    PRE_ATLAS_LOSE_MANTLE = "TOYBOX_PRE_ATLAS_LOSE_MANTLE",
    POST_ATLAS_LOSE_MANTLE = "TOYBOX_POST_ATLAS_LOSE_MANTLE",
    POST_PLAYER_BOMB_DETONATE = "TOYBOX_POST_PLAYER_BOMB_DETONATE",
    POST_PLAYER_ATTACK = "TOYBOX_POST_PLAYER_ATTACK",
    USE_THROWABLE_ACTIVE = "TOYBOX_USE_THROWABLE_ACTIVE",
    POST_PLAYER_DOUBLE_TAP = "TOYBOX_POST_PLAYER_DOUBLE_TAP",
    USE_ACTIVE_ITEM = "TOYBOX_USE_ACTIVE_ITEM",
    POST_FIRE_TEAR = "TOYBOX_POST_FIRE_TEAR",
    RESET_LUDOVICO_DATA = "TOYBOX_RESET_LUDOVICO_DATA",
    POST_FIRE_BOMB = "TOYBOX_POST_FIRE_BOMB",
    COPY_SCATTER_BOMB_DATA = "TOYBOX_COPY_SCATTER_BOMB_DATA",
    POST_PLAYER_EXTRA_DMG = "TOYBOX_POST_PLAYER_EXTRA_DMG",
    POST_FIRE_AQUARIUS = "TOYBOX_POST_FIRE_AQUARIUS",
    POST_FIRE_ROCKET = "TOYBOX_POST_FIRE_ROCKET",
    ROCKET_COPY_TARGET_DATA = "TOYBOX_ROCKET_COPY_TARGET_DATA",
    POST_ROCKET_EXPLODE = "TOYBOX_POST_ROCKET_EXPLODE",
    POST_NEW_ROOM = "TOYBOX_POST_NEW_ROOM",
    POST_ROOM_CLEAR = "TOYBOX_POST_ROOM_CLEAR",
}

mod.CUSTOM_BOMBFLAGS = {
    FLAG_MAKESHIFT_BOMB1 = 1<<0,
    FLAG_MAKESHIFT_BOMB2 = 1<<1,
}

mod.DAMAGE_TYPE = {
    KNIFE = 1<<0,
    LASER = 1<<1,
    DARK_ARTS = 1<<2,
    ABYSS_LOCUST = 1<<3,
    BOMB = 1<<4,
    AQUARIUS = 1<<5,
    ROCKET = 1<<6,
    TEAR = 1<<7,
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

mod.MANTLE_DATA = {
    NONE = {
        ID = 0,
        HP = 0,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,0),
        ANIM = "Empty",
    },
    DEFAULT = {
        ID = 1,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_ROCK,
        SHARD_COLOR = Color(153/255,139/255,136/255,1),
        ANIM = "RockMantle",
    },
    POOP = {
        ID = 2,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_POOP,
        SHARD_COLOR = Color(124/255,86/255,52/255,1),
        ANIM = "PoopMantle",
    },
    BONE = {
        ID = 3,
        HP = 3,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_BONE,
        SHARD_COLOR = Color(95/255,112/255,121/255,1),
        ANIM = "BoneMantle",
    },
    DARK = {
        ID = 4,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_DARK,
        SHARD_COLOR = Color(59/255,59/255,59/255,1),
        ANIM = "DarkMantle",
    },
    HOLY = {
        ID = 5,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_HOLY,
        FLIGHT_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/costume_atlasa_holy_wings.anm2"),
        SHARD_COLOR = Color(190/255,190/255,190/255,1),
        ANIM = "HolyMantle",
    },
    SALT = {
        ID = 6,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_SALT,
        SHARD_COLOR = Color(1,1,1,1),
        ANIM = "SaltMantle",
    },
    GLASS = {
        ID = 7,
        HP = 1,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_GLASS,
        SHARD_COLOR = Color(1,1,1,1),
        ANIM = "GlassMantle",
    },
    METAL = {
        ID = 8,
        HP = 3,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_METAL,
        SHARD_COLOR = Color(147/255,147/255,147/255,1),
        ANIM = "MetalMantle",
    },
    GOLD = {
        ID = 9,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_GOLD,
        SHARD_COLOR = Color(205/255,181/255,60/255,1),
        ANIM = "GoldMantle",
    },

    TAR = {
        ID = 1024,
        HP = 0,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,1),
        ANIM = "TarMantle",
    },

    UNKNOWN = {
        ID = 1000,
        HP = 0,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,0),
        ANIM = "Unknown",
    }
}

mod.MANTLE_ID_TO_NAME = {
    [mod.MANTLE_DATA.NONE.ID] = "NONE",
    [mod.MANTLE_DATA.DEFAULT.ID] = "DEFAULT",
    [mod.MANTLE_DATA.POOP.ID] = "POOP",
    [mod.MANTLE_DATA.BONE.ID] = "BONE",
    [mod.MANTLE_DATA.DARK.ID] = "DARK",
    [mod.MANTLE_DATA.HOLY.ID] = "HOLY",
    [mod.MANTLE_DATA.SALT.ID] = "SALT",
    [mod.MANTLE_DATA.GLASS.ID] = "GLASS",
    [mod.MANTLE_DATA.METAL.ID] = "METAL",
    [mod.MANTLE_DATA.GOLD.ID] = "GOLD",
    [mod.MANTLE_DATA.TAR.ID] = "TAR",
}

-- PICKING MANTLES ENUMS
mod.SAME_MANTLE_BIAS = {
    [0]=1,
    [1]=7.5,
    [2]=25,
    [3]=1,
}
mod.MANTLE_PICKER = {
    {OUTCOME=mod.MANTLE_DATA.DEFAULT.ID, WEIGHT=1},
    {OUTCOME=mod.MANTLE_DATA.POOP.ID, WEIGHT=1},
    {OUTCOME=mod.MANTLE_DATA.BONE.ID, WEIGHT=1},
    {OUTCOME=mod.MANTLE_DATA.DARK.ID, WEIGHT=1},
    {OUTCOME=mod.MANTLE_DATA.HOLY.ID, WEIGHT=1},
    {OUTCOME=mod.MANTLE_DATA.SALT.ID, WEIGHT=1},
    {OUTCOME=mod.MANTLE_DATA.GLASS.ID, WEIGHT=1},
    {OUTCOME=mod.MANTLE_DATA.METAL.ID, WEIGHT=1},
    {OUTCOME=mod.MANTLE_DATA.GOLD.ID, WEIGHT=1},
}

-- MANTLE HP RENDER ENUMS
mod.MANTLE_SHARD_GRAVITY = 7

--#endregion