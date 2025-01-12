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
mod.ACH_JONAS_B = Isaac.GetAchievementIdByName("Tainted Jonas")

mod.ACH_PRISMSTONE = Isaac.GetAchievementIdByName("Prismstone")
mod.ACH_GLASS_VESSEL = Isaac.GetAchievementIdByName("Glass Vessel")
mod.ACH_STEEL_SOUL = Isaac.GetAchievementIdByName("Steel Soul")
mod.ACH_HOSTILE_TAKEOVER = Isaac.GetAchievementIdByName("Hostile Takeover")
mod.ACH_ROCK_CANDY = Isaac.GetAchievementIdByName("Rock Candy")
mod.ACH_MISSING_PAGE_3 = Isaac.GetAchievementIdByName("Missing Page 3")
mod.ACH_GILDED_APPLE = Isaac.GetAchievementIdByName("Gilded Apple")
mod.ACH_SALTPETER = Isaac.GetAchievementIdByName("Saltpeter")
mod.ACH_MANTLES = Isaac.GetAchievementIdByName("Mantles")
mod.ACH_AMBER_FOSSIL = Isaac.GetAchievementIdByName("Amber Fossil")
mod.ACH_BONE_BOY = Isaac.GetAchievementIdByName("Bone Boy!")
mod.ACH_ASCENSION = Isaac.GetAchievementIdByName("Ascension")
mod.ACH_MIRACLE_MANTLE = Isaac.GetAchievementIdByName("Miracle Mantle")
mod.ACH_GIANT_CAPSULE = Isaac.GetAchievementIdByName("Giant Capsule")
mod.ACH_WONDER_DRUG = Isaac.GetAchievementIdByName("Wonder Drug")
mod.ACH_DADS_PRESCRIPTION = Isaac.GetAchievementIdByName("Dad's Prescription")
mod.ACH_CANDY_DISPENSER = Isaac.GetAchievementIdByName("Candy Dispenser")
mod.ACH_DR_BUM = Isaac.GetAchievementIdByName("Dr. Bum")
mod.ACH_JONAS_MASK = Isaac.GetAchievementIdByName("Jonas' Mask")
mod.ACH_ANTIBIOTICS = Isaac.GetAchievementIdByName("Antibiotics")
mod.ACH_FOIL_CARD = Isaac.GetAchievementIdByName("Foil Card")
mod.ACH_HORSE_TRANQUILIZER = Isaac.GetAchievementIdByName("Horse Tranquilizer")
mod.ACH_CLOWN_PHD = Isaac.GetAchievementIdByName("Clown PHD")
mod.ACH_JONAS_LOCK = Isaac.GetAchievementIdByName("Jonas' Lock")
mod.ACH_PILLS = Isaac.GetAchievementIdByName("Pill Diversity!")
mod.ACH_DRILL = Isaac.GetAchievementIdByName("Drill")

--#endregion
--#region --!ITEMS

--*COLLECTIBLES
-- mod.COLLECTIBLE_ = Isaac.GetItemIdByName("")
mod.COLLECTIBLE_COCONUT_OIL = Isaac.GetItemIdByName("Coconut Oil")                  --!DONE
mod.COLLECTIBLE_CONDENSED_MILK = Isaac.GetItemIdByName("Condensed Milk")            --!DONE
mod.COLLECTIBLE_EYESTRAIN = Isaac.GetItemIdByName("Eyestrain")                      --!DONE
mod.COLLECTIBLE_SNOWCONE = Isaac.GetItemIdByName("Snowcone")
mod.COLLECTIBLE_OBSIDIAN_SHARD = Isaac.GetItemIdByName("Obsidian Shard")
mod.COLLECTIBLE_GOAT_MILK = Isaac.GetItemIdByName("Goat Milk")                      --!DONE
mod.COLLECTIBLE_LOOSE_BOWELS = Isaac.GetItemIdByName("Loose Bowels")
mod.COLLECTIBLE_PLIERS = Isaac.GetItemIdByName("Pliers")                            --!DONE
mod.COLLECTIBLE_NOSE_CANDY = Isaac.GetItemIdByName("Nose Candy")                    --!DONE
mod.COLLECTIBLE_LION_SKULL = Isaac.GetItemIdByName("Lion Skull")                    --!DONE
mod.COLLECTIBLE_DADS_SLIPPER = Isaac.GetItemIdByName("Dad's Slipper")
mod.COLLECTIBLE_GOOD_JOB = Isaac.GetItemIdByName("Good Job")
mod.COLLECTIBLE_ODD_ONION = Isaac.GetItemIdByName("Odd Onion")
mod.COLLECTIBLE_CARAMEL_APPLE = Isaac.GetItemIdByName("Caramel Apple")              --!DONE
mod.COLLECTIBLE_BLOOD_RITUAL = Isaac.GetItemIdByName("Blood Ritual")                --!DONE
mod.COLLECTIBLE_TECH_IX = Isaac.GetItemIdByName("Tech IX")                          --!DONE
mod.COLLECTIBLE_DRIED_PLACENTA = Isaac.GetItemIdByName("Dried Placenta")
mod.COLLECTIBLE_PAINKILLERS = Isaac.GetItemIdByName("Painkillers")                  --!DONE
mod.COLLECTIBLE_SILK_BAG = Isaac.GetItemIdByName("Silk Bag")                        --!DONE
mod.COLLECTIBLE_BRAINFREEZE = Isaac.GetItemIdByName("Brainfreeze")
mod.COLLECTIBLE_FATAL_SIGNAL = Isaac.GetItemIdByName("Fatal Signal")
mod.COLLECTIBLE_METEOR_SHOWER = Isaac.GetItemIdByName("Meteor Shower")              --!DONE
mod.COLLECTIBLE_BLESSED_RING = Isaac.GetItemIdByName("Blessed Ring")                --!DONE
mod.COLLECTIBLE_SIGIL_OF_GREED = Isaac.GetItemIdByName("Sigil of Greed")
mod.COLLECTIBLE_PEPPER_X = Isaac.GetItemIdByName("Pepper X")
mod.COLLECTIBLE_GOLDEN_TWEEZERS = Isaac.GetItemIdByName("Golden Tweezers")          --!DONE
mod.COLLECTIBLE_GILDED_APPLE = Isaac.GetItemIdByName("Gilded Apple")                --!DONE
mod.COLLECTIBLE_OBSIDIAN_CHUNK = Isaac.GetItemIdByName("Obsidian Chunk")
mod.COLLECTIBLE_DADS_PRESCRIPTION = Isaac.GetItemIdByName("Dad's Prescription")     --!DONE
mod.COLLECTIBLE_HORSE_TRANQUILIZER = Isaac.GetItemIdByName("Horse Tranquilizer")    --!DONE
mod.COLLECTIBLE_BOBS_HEART = Isaac.GetItemIdByName("Bob's Heart")                   --!DONE
mod.COLLECTIBLE_GLASS_VESSEL = Isaac.GetItemIdByName("Glass Vessel")                --!DONE
mod.COLLECTIBLE_BONE_BOY = Isaac.GetItemIdByName("Bone Boy")                        --!DONE
mod.COLLECTIBLE_HOSTILE_TAKEOVER = Isaac.GetItemIdByName("Hostile Takeover")        --!DONE
mod.COLLECTIBLE_STEEL_SOUL = Isaac.GetItemIdByName("Steel Soul")                    --!DONE
mod.COLLECTIBLE_ROCK_CANDY = Isaac.GetItemIdByName("Rock Candy")                    --!DONE
mod.COLLECTIBLE_GIANT_CAPSULE = Isaac.GetItemIdByName("Giant Capsule")              --!DONE
mod.COLLECTIBLE_PEZ_DISPENSER = Isaac.GetItemIdByName("Candy Dispenser")            --!DONE
mod.COLLECTIBLE_MISSING_PAGE_3 = Isaac.GetItemIdByName("Missing Page 3")            --!DONE
mod.COLLECTIBLE_ASCENSION = Isaac.GetItemIdByName("Ascension")                      --!DONE
mod.COLLECTIBLE_4_4 = Isaac.GetItemIdByName("4 4")                                  --!DONE
mod.COLLECTIBLE_DR_BUM = Isaac.GetItemIdByName("Dr. Bum")                           --!DONE
mod.COLLECTIBLE_JONAS_MASK = Isaac.GetItemIdByName("Jonas' Mask")                   --!DONE
mod.COLLECTIBLE_CLOWN_PHD = Isaac.GetItemIdByName("Clown PHD")                      --!DONE
mod.COLLECTIBLE_DRILL = Isaac.GetItemIdByName("Drill")
mod.COLLECTIBLE_ALPHABET_BOX = Isaac.GetItemIdByName("Alphabet Box")                --!DONE
mod.COLLECTIBLE_LOVE_LETTER = Isaac.GetItemIdByName("Love Letter")                  --!DONE
mod.COLLECTIBLE_QUAKE_BOMBS = Isaac.GetItemIdByName("Quake Bombs")                  --!DONE
mod.COLLECTIBLE_ATHEISM = Isaac.GetItemIdByName("Atheism")                          --!DONE
mod.COLLECTIBLE_MAYONAISE = Isaac.GetItemIdByName("Mayonnaise")                     --!DONE
mod.COLLECTIBLE_AWESOME_FRUIT = Isaac.GetItemIdByName("Awesome Fruit")              --!DONE
mod.COLLECTIBLE_BLOODY_MAP = Isaac.GetItemIdByName("Bloody Map")
mod.COLLECTIBLE_SALTPETER = Isaac.GetItemIdByName("Saltpeter")                      --!DONE
mod.COLLECTIBLE_PREFERRED_OPTIONS = Isaac.GetItemIdByName("Preferred Options")      --!DONE
mod.COLLECTIBLE_PLASMA_GLOBE = Isaac.GetItemIdByName("Plasma Globe")                --!DONE
mod.COLLECTIBLE_CURSED_EULOGY = Isaac.GetItemIdByName("Cursed Eulogy")              --!DONE
mod.COLLECTIBLE_BLESSED_BOMBS = Isaac.GetItemIdByName("Blessed Bombs")              --!DONE


mod.COLLECTIBLE_EQUALIZER = Isaac.GetItemIdByName("Equalizer")
mod.COLLECTIBLE_D = Isaac.GetItemIdByName("D")                                      --!DONE
--mod.COLLECTIBLE_BTRAIN = Isaac.GetItemIdByName("B-Train")

mod.COLLECTIBLE_PORTABLE_TELLER = Isaac.GetItemIdByName("Portable Teller")

--mod.COLLECTIBLE_LASER_POINTER = Isaac.GetItemIdByName("Laser Pointer")            --*UNUSED (i dont like the item)
--mod.COLLECTIBLE_TOY_GUN = Isaac.GetItemIdByName("Toy Gun")                        --*UNUSED (same as above)
--mod.COLLECTIBLE_MALICIOUS_BRAIN = Isaac.GetItemIdByName("Malicious Brain")        --*UNUSED

--*TRINKETS
mod.TRINKET_ANTIBIOTICS = Isaac.GetTrinketIdByName("Antibiotics")                   --!DONE
mod.TRINKET_WONDER_DRUG = Isaac.GetTrinketIdByName("Wonder Drug")                   --!DONE
mod.TRINKET_AMBER_FOSSIL = Isaac.GetTrinketIdByName("Amber Fossil")                 --!DONE
mod.TRINKET_JONAS_LOCK = Isaac.GetTrinketIdByName("Jonas' Lock")                    --!DONE
mod.TRINKET_SINE_WORM = Isaac.GetTrinketIdByName("Sine Worm")                       --!DONE
mod.TRINKET_BIG_BLIND = Isaac.GetTrinketIdByName("Big Blind")                       --!DONE
mod.TRINKET_BATH_WATER = Isaac.GetTrinketIdByName("Bath Water")                     --!DONE
mod.TRINKET_BLACK_RUNE_SHARD = Isaac.GetTrinketIdByName("Black Rune Shard")         --!DONE
mod.TRINKET_YELLOW_BELT = Isaac.GetTrinketIdByName("Yellow Belt")

--mod.TRINKET_LIMIT_BREAK = Isaac.GetTrinketIdByName("LIMIT BREAK")                 --*UNUSED
--mod.TRINKET_FOAM_BULLET = Isaac.GetTrinketIdByName("Foam Bullet")                 --*UNUSED

--*CONSUMABLES
mod.CARD_PRISMSTONE = Isaac.GetCardIdByName("Prismstone")
mod.CARD_FOIL_CARD = Isaac.GetCardIdByName("Foil Card")

mod.CONSUMABLE_MANTLE_ROCK = Isaac.GetCardIdByName("Rock Mantle")
mod.CONSUMABLE_MANTLE_POOP = Isaac.GetCardIdByName("Poop Mantle")
mod.CONSUMABLE_MANTLE_BONE = Isaac.GetCardIdByName("Bone Mantle")
mod.CONSUMABLE_MANTLE_DARK = Isaac.GetCardIdByName("Dark Mantle")
mod.CONSUMABLE_MANTLE_HOLY = Isaac.GetCardIdByName("Holy Mantle")
mod.CONSUMABLE_MANTLE_SALT = Isaac.GetCardIdByName("Salt Mantle")
mod.CONSUMABLE_MANTLE_GLASS = Isaac.GetCardIdByName("Glass Mantle")
mod.CONSUMABLE_MANTLE_METAL = Isaac.GetCardIdByName("Metal Mantle")
mod.CONSUMABLE_MANTLE_GOLD = Isaac.GetCardIdByName("Gold Mantle")
mod.CONSUMABLE_LAUREL = Isaac.GetCardIdByName("Laurel")
mod.CONSUMABLE_YANNY = Isaac.GetCardIdByName("Yanny")

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

--#endregion
--#region --!ENTITIES

--*FAMILIARS
mod.FAMILIAR_HYPNOS = Isaac.GetEntityVariantByName("Malicious Brain")
mod.FAMILIAR_SILK_BAG = Isaac.GetEntityVariantByName("Silk Bag")
mod.FAMILIAR_BONE_BOY = Isaac.GetEntityVariantByName("Bone Boy")
mod.FAMILIAR_EVIL_SHADOW = Isaac.GetEntityVariantByName("Black Spirit")
mod.FAMILIAR_VIRUS = Isaac.GetEntityVariantByName("Virus (Red)")
mod.FAMILIAR_MASK_SHADOW = Isaac.GetEntityVariantByName("Shadow Fly")
mod.FAMILIAR_DR_BUM = Isaac.GetEntityVariantByName("Dr Bum")
mod.FAMILIAR_BATH_WATER = Isaac.GetEntityVariantByName("Bath Water")

--*EFFECTS
mod.EFFECT_BLOOD_RITUAL_PENTAGRAM = Isaac.GetEntityVariantByName("Blood Ritual Pentagram")
mod.EFFECT_METEOR_TEAR_EXPLOSION = Isaac.GetEntityVariantByName("Meteor Tear Explosion")
mod.EFFECT_GOLDMANTLE_BREAK = Isaac.GetEntityVariantByName("Gold Mantle Shatter")
mod.EFFECT_GREED_SIGIL_CHARGEBAR = Isaac.GetEntityVariantByName("Greed Sigil Chargebar")
mod.EFFECT_ASCENSION_PLAYER_DEATH = Isaac.GetEntityVariantByName("Ascension Dead Player")
mod.EFFECT_AURA = Isaac.GetEntityVariantByName("Enemy Fear Aura")
mod.EFFECT_VESSEL_BREAK = Isaac.GetEntityVariantByName("Glass Vessel Break")

--*PICKUPS
mod.PICKUP_MAMMONS_OFFERING_PENNY = Isaac.GetEntityVariantByName("Mammon's Offering Penny")
mod.PICKUP_BLACK_SOUL = Isaac.GetEntityVariantByName("Black Soul")
mod.PICKUP_BLOOD_SOUL = Isaac.GetEntityVariantByName("Blood Soul")
mod.PICKUP_INK_1 = Isaac.GetEntitySubTypeByName("Ink (1)")
mod.PICKUP_INK_2 = Isaac.GetEntitySubTypeByName("Ink (2)")
mod.PICKUP_INK_5 = Isaac.GetEntitySubTypeByName("Ink (5)")

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
mod.BOSS_RED_MEGALODON = Isaac.GetEntityVariantByName("Red Megalodon")

--#endregion
--#region --!SFX

mod.SFX_4_4_SCREAM = Isaac.GetSoundIdByName("Toybox_4_4_Scream"); sfx:Preload(mod.SFX_4_4_SCREAM)
mod.SFX_SILK_BAG_SHIELD = Isaac.GetSoundIdByName("Toybox_SilkBag_Shield"); sfx:Preload(mod.SFX_SILK_BAG_SHIELD)
mod.SFX_TOY_GUN_RELOAD = Isaac.GetSoundIdByName("Toybox_ToyGun_Reload"); sfx:Preload(mod.SFX_TOY_GUN_RELOAD)
mod.SFX_BULLET_FIRE = Isaac.GetSoundIdByName("Toybox_Bullet_Shoot"); sfx:Preload(mod.SFX_BULLET_FIRE)
mod.SFX_BULLET_HIT = Isaac.GetSoundIdByName("Toybox_Bullet_Hit"); sfx:Preload(mod.SFX_BULLET_HIT)
mod.SFX_POWERUP = Isaac.GetSoundIdByName("Toybox_PowerUp"); sfx:Preload(mod.SFX_POWERUP)
mod.SFX_POWERDOWN = Isaac.GetSoundIdByName("Toybox_PowerDown"); sfx:Preload(mod.SFX_POWERDOWN)
mod.SFX_VIRUS_SPAWN = Isaac.GetSoundIdByName("Toybox_Virus_Spawn"); sfx:Preload(mod.SFX_VIRUS_SPAWN)
mod.SFX_VIRUS_SHOOT = Isaac.GetSoundIdByName("Toybox_Virus_Shoot"); sfx:Preload(mod.SFX_VIRUS_SHOOT)
mod.SFX_VIRUS_DIE = Isaac.GetSoundIdByName("Toybox_Virus_Die"); sfx:Preload(mod.SFX_VIRUS_DIE)
mod.SFX_SHADOW_SCREAM = Isaac.GetSoundIdByName("Toybox_Shadow_Scream"); sfx:Preload(mod.SFX_SHADOW_SCREAM)

mod.SFX_ATLASA_ROCKCRACK = Isaac.GetSoundIdByName("Toybox_AtlasA_RockCrack"); sfx:Preload(mod.SFX_ATLASA_ROCKCRACK)
mod.SFX_ATLASA_ROCKBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_RockBreak"); sfx:Preload(mod.SFX_ATLASA_ROCKBREAK)
mod.SFX_ATLASA_METALBLOCK = Isaac.GetSoundIdByName("Toybox_AtlasA_MetalBlock"); sfx:Preload(mod.SFX_ATLASA_METALBLOCK)
mod.SFX_ATLASA_METALBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_MetalBreak"); sfx:Preload(mod.SFX_ATLASA_METALBREAK)
mod.SFX_ATLASA_GLASSBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_GlassBreak"); sfx:Preload(mod.SFX_ATLASA_GLASSBREAK)

--#endregion
--#region --!MISC
mod.FAMILIAR_VIRUS_SUBTYPE = {
    RED = Isaac.GetEntitySubTypeByName("Virus (Red)"),
    FEVER = Isaac.GetEntitySubTypeByName("Virus (Red)"),
    YELLOW = Isaac.GetEntitySubTypeByName("Virus (Yellow)"),
    YELLOW_1 = Isaac.GetEntitySubTypeByName("Virus (Yellow)"),
    WEIRD = Isaac.GetEntitySubTypeByName("Virus (Yellow)"),
    BLUE = Isaac.GetEntitySubTypeByName("Virus (Blue)"),
    CHILL = Isaac.GetEntitySubTypeByName("Virus (Blue)"),
    MAGENTA = Isaac.GetEntitySubTypeByName("Virus (Magenta)"),
    CONFUSED = Isaac.GetEntitySubTypeByName("Virus (Magenta)"),
    YELLOW_2 = Isaac.GetEntitySubTypeByName("Virus (Yellow 2)"),
    DROWSY = Isaac.GetEntitySubTypeByName("Virus (Yellow 2)"),
    CYAN = Isaac.GetEntitySubTypeByName("Virus (Cyan)"),
    DIZZY = Isaac.GetEntitySubTypeByName("Virus (Cyan)"),
    GREEN = Isaac.GetEntitySubTypeByName("Virus (Green)"),
    LIGHT_BLUE = Isaac.GetEntitySubTypeByName("Virus (Light Blue)"),
    PINK = Isaac.GetEntitySubTypeByName("Virus (Pink)"),
    PURPLE = Isaac.GetEntitySubTypeByName("Virus (Purple)"),
}

mod.FAMILIAR_MASK_SHADOW_SUBTYPE = {
    FLY = Isaac.GetEntitySubTypeByName("Shadow Fly"),
    URCHIN = Isaac.GetEntitySubTypeByName("Shadow Urchin"),
    CRAWLER = Isaac.GetEntitySubTypeByName("Shadow Crawler"),
    BALL = Isaac.GetEntitySubTypeByName("Shadow Fly"),
    ORBITAL = Isaac.GetEntitySubTypeByName("Shadow Urchin"),
    CHASER = Isaac.GetEntitySubTypeByName("Shadow Crawler"),
}

mod.EFFECT_AURA_SUBTYPE = {
    ENEMY_FEAR = 0,
    BOMB_BLESSED = 1,
    DARK_MANTLE = 2,
    HOLY_MANTLE = 3,
}
--#endregion
--#region --!CUSTOM_ENUMS

mod.SHADERS = {
    EMPTY = "ToyboxEmptyShader",
    BLOOM = "ToyboxBloomShader",
    ASCENSION = "ToyboxAscensionShader",
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
    POST_ATLAS_ADD_MANTLE = "TOYBOX_POST_ATLAS_ADD_MANTLE",
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
    POST_CUSTOM_CHAMPION_DEATH = "TOYBOX_POST_CUSTOM_CHAMPION_DEATH",
    POST_CUSTOM_CHAMPION_INIT = "TOYBOX_POST_CUSTOM_CHAMPION_INIT",
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

mod.ACHIEVEMENTS = {
    {
        Achievement = mod.ACH_ROCK_CANDY,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.BOSS_RUSH)>0
        end,
    },
    {
        Achievement = mod.ACH_SALTPETER,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.HUSH)>0
        end,
    },
    {
        Achievement = mod.ACH_ASCENSION,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.ISAAC)>0
        end,
    },
    {
        Achievement = mod.ACH_GLASS_VESSEL,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.BLUE_BABY)>0
        end,
    },
    {
        Achievement = mod.ACH_MISSING_PAGE_3,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.SATAN)>0
        end,
    },
    {
        Achievement = mod.ACH_BONE_BOY,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.LAMB)>0
        end,
    },
    {
        Achievement = mod.ACH_GILDED_APPLE,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.ULTRA_GREED)>0
        end,
    },
    {
        Achievement = mod.ACH_PRISMSTONE,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.ULTRA_GREED)>=2
        end,
    },
    {
        Achievement = mod.ACH_AMBER_FOSSIL,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.MOTHER)>0
        end,
    },
    {
        Achievement = mod.ACH_STEEL_SOUL,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.BEAST)>0
        end,
    },
    {
        Achievement = mod.ACH_HOSTILE_TAKEOVER,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.DELIRIUM)>0
        end,
    },
    {
        Achievement = mod.ACH_MANTLES,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, CompletionType.MEGA_SATAN)>0
        end,
    },
    {
        Achievement = mod.ACH_MIRACLE_MANTLE,
        Condition = function()
            return Isaac.AllMarksFilled(mod.PLAYER_ATLAS_A)>=2
        end,
    },
    {
        Achievement = mod.ACH_JONAS_LOCK,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.BOSS_RUSH)>0
        end,
    },
    {
        Achievement = mod.ACH_WONDER_DRUG,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.HUSH)>0
        end,
    },
    {
        Achievement = mod.ACH_DADS_PRESCRIPTION,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.ISAAC)>0
        end,
    },
    {
        Achievement = mod.ACH_CANDY_DISPENSER,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.BLUE_BABY)>0
        end,
    },
    {
        Achievement = mod.ACH_DR_BUM,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.SATAN)>0
        end,
    },
    {
        Achievement = mod.ACH_JONAS_MASK,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.LAMB)>0
        end,
    },
    {
        Achievement = mod.ACH_ANTIBIOTICS,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.ULTRA_GREED)>0
        end,
    },
    {
        Achievement = mod.ACH_FOIL_CARD,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.ULTRA_GREED)>=2
        end,
    },
    {
        Achievement = mod.ACH_HORSE_TRANQUILIZER,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.MOTHER)>0
        end,
    },
    {
        Achievement = mod.ACH_CLOWN_PHD,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.BEAST)>0
        end,
    },
    {
        Achievement = mod.ACH_GIANT_CAPSULE,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.DELIRIUM)>0
        end,
    },
    {
        Achievement = mod.ACH_PILLS,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, CompletionType.MEGA_SATAN)>0
        end,
    },
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
        HURT_SFX = 0,
        BREAK_SFX = 0,
        
        ATLAS_DESC = "",
        REG_DESC = "",
    },
    DEFAULT = {
        ID = 1,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_ROCK,
        SHARD_COLOR = Color(153/255,139/255,136/255,1),
        ANIM = "RockMantle",
        HURT_SFX = mod.SFX_ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SFX_ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Useless",
        REG_DESC = "Rock and roll",
    },
    POOP = {
        ID = 2,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_POOP,
        SHARD_COLOR = Color(124/255,86/255,52/255,1),
        ANIM = "PoopMantle",
        HURT_SFX = mod.SFX_ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SFX_ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "More poops, better poops",
        REG_DESC = "On-command diarrhea",
    },
    BONE = {
        ID = 3,
        HP = 3,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_BONE,
        SHARD_COLOR = Color(95/255,112/255,121/255,1),
        ANIM = "BoneMantle",
        HURT_SFX = mod.SFX_ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SFX_ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Bones on kill, panic = sorrow",
        REG_DESC = "Bone buddy + bones on kill",
    },
    DARK = {
        ID = 4,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_DARK,
        SHARD_COLOR = Color(59/255,59/255,59/255,1),
        ANIM = "DarkMantle",
        HURT_SFX = mod.SFX_ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SFX_ATLASA_ROCKBREAK,

        ATLAS_DESC = "DMG up + mass room damage, dark aura",
        REG_DESC = "Mass floor damage",
    },
    HOLY = {
        ID = 5,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_HOLY,
        FLIGHT_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/tb_costume_atlas_wings.anm2"),
        SHARD_COLOR = Color(190/255,190/255,190/255,1),
        ANIM = "HolyMantle",
        HURT_SFX = mod.SFX_ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SFX_ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Range up + sacred tears, flight + holy aura",
        REG_DESC = "Eternity + \"god\" tears",
    },
    SALT = {
        ID = 6,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_SALT,
        CHARIOT_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/tb_costume_atlas_salt.anm2"),
        SHARD_COLOR = Color(1,1,1,1),
        ANIM = "SaltMantle",
        HURT_SFX = mod.SFX_ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SFX_ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Tears up, on-command salt chariot",
        REG_DESC = "Temporary sorrow",
    },
    GLASS = {
        ID = 7,
        HP = 1,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_GLASS,
        SHARD_COLOR = Color(1,1,1,1),
        ANIM = "GlassMantle",
        HURT_SFX = 0,
        BREAK_SFX = mod.SFX_ATLASA_GLASSBREAK,
                
        ATLAS_DESC = "DMG + shotspeed up + brittle protection",
        REG_DESC = "DMG up + fragility up",
    },
    METAL = {
        ID = 8,
        HP = 3,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_METAL,
        SHARD_COLOR = Color(147/255,147/255,147/255,1),
        ANIM = "MetalMantle",
        HURT_SFX = mod.SFX_ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SFX_ATLASA_METALBREAK,
                
        ATLAS_DESC = "Speed down + defense up",
        REG_DESC = "Tough skin",
    },
    GOLD = {
        ID = 9,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_GOLD,
        SHARD_COLOR = Color(205/255,181/255,60/255,1),
        ANIM = "GoldMantle",
        HURT_SFX = mod.SFX_ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SFX_ATLASA_METALBREAK,
                
        ATLAS_DESC = "Luck up + gold panic, penny tears",
        REG_DESC = "Microtransactions",
    },

    TAR = {
        ID = 1024,
        HP = 0,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,1),
        ANIM = "TarMantle",
        HURT_SFX = 0,
        BREAK_SFX = 0,
    },
    UNKNOWN = {
        ID = 1000,
        HP = 0,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE_MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,0),
        ANIM = "Unknown",
        HURT_SFX = 0,
        BREAK_SFX = 0,
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
--#region !MILCOM_A

mod.CUSTOM_CHAMPIONS = {
    FEAR = {
        Idx = 1,
        Color = Color(0.8,0.8,0.8,1,0.1,0,0.1,1,0,1,1),
        HPMult = 1.5,
    },
    ETERNAL = {
        Idx = 2,
        Color = Color(0.8,0.8,0.8,1,0.1,0,0.1,1,0,1,1),
        HPMult = 1,
    },
    DROWNED = {
        Idx = 3,
        Color = Color(0.5,0.9,1,1,0,0,0,0,1,1,1),
        HPMult = 2,
    },
    SPIDERS = {
        Idx = 4,
        Color = Color(0.8,0.8,0.8,1,0.1,0,0.1,1,0,1,1),
        HPMult = 1,
    },
    GOLDEN = {
        Idx = 5,
        Color = Color(0.8,0.8,0.8,1,0.1,0,0.1,1,0,1,1),
        HPMult = 1,
    },
    JELLY = {
        Idx = 6,
        Color = Color(1,1.3,1,1,0,0,0,0.3,1,0,1),
        HPMult = 2,
    },
}
mod.CUSTOM_CHAMPION_IDX_TO_NAME = {
    "FEAR",
    "ETERNAL",
    "DROWNED",
    "SPIDERS",
    "GOLDEN",
    "JELLY",
}

mod.CUSTOM_CHAMPION_PICKER = WeightedOutcomePicker()
mod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(1, 100, 1000)
mod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(2, 1, 1000)
mod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(3, 100, 1000)
mod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(4, 1, 1000)
mod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(5, 1, 1000)
mod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(6, 100, 1000)

--#endregion