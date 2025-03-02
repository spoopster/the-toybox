local mod = MilcomMOD
local sfx = SFXManager()

mod.DATA_LOADED = false

---@type PlayerType[]
mod.PLAYER_TYPE = {
    MILCOM_A = Isaac.GetPlayerTypeByName("Milcom", false),
    ATLAS_A = Isaac.GetPlayerTypeByName("Atlas", false),
    ATLAS_A_TAR = Isaac.GetPlayerTypeByName("The Tar", false),
    JONAS_A = Isaac.GetPlayerTypeByName("Jonas", false),

    MILCOM_B = Isaac.GetPlayerTypeByName("Milcom", true),
    ATLAS_B = Isaac.GetPlayerTypeByName("Atlas", true),
    JONAS_B = Isaac.GetPlayerTypeByName("Jonas", true),
}

---@type Achievement[]
mod.ACHIEVEMENT = {
    MILCOM_B = Isaac.GetAchievementIdByName("Tainted Milcom"),
    ATLAS_B = Isaac.GetAchievementIdByName("Tainted Atlas"),
    JONAS_B = Isaac.GetAchievementIdByName("Tainted Jonas"),
    PRISMSTONE = Isaac.GetAchievementIdByName("Prismstone"),
    GLASS_VESSEL = Isaac.GetAchievementIdByName("Glass Vessel"),
    STEEL_SOUL = Isaac.GetAchievementIdByName("Steel Soul"),
    HOSTILE_TAKEOVER = Isaac.GetAchievementIdByName("Hostile Takeover"),
    ROCK_CANDY = Isaac.GetAchievementIdByName("Rock Candy"),
    MISSING_PAGE_3 = Isaac.GetAchievementIdByName("Missing Page 3"),
    GILDED_APPLE = Isaac.GetAchievementIdByName("Gilded Apple"),
    SALTPETER = Isaac.GetAchievementIdByName("Saltpeter"),
    MANTLES = Isaac.GetAchievementIdByName("Mantles"),
    AMBER_FOSSIL = Isaac.GetAchievementIdByName("Amber Fossil"),
    BONE_BOY = Isaac.GetAchievementIdByName("Bone Boy!"),
    ASCENSION = Isaac.GetAchievementIdByName("Ascension"),
    MIRACLE_MANTLE = Isaac.GetAchievementIdByName("Miracle Mantle"),
    GIANT_CAPSULE = Isaac.GetAchievementIdByName("Giant Capsule"),
    WONDER_DRUG = Isaac.GetAchievementIdByName("Wonder Drug"),
    DADS_PRESCRIPTION = Isaac.GetAchievementIdByName("Dad's Prescription"),
    CANDY_DISPENSER = Isaac.GetAchievementIdByName("Candy Dispenser"),
    DR_BUM = Isaac.GetAchievementIdByName("Dr. Bum"),
    JONAS_MASK = Isaac.GetAchievementIdByName("Jonas' Mask"),
    ANTIBIOTICS = Isaac.GetAchievementIdByName("Antibiotics"),
    FOIL_CARD = Isaac.GetAchievementIdByName("Foil Card"),
    HORSE_TRANQUILIZER = Isaac.GetAchievementIdByName("Horse Tranquilizer"),
    CLOWN_PHD = Isaac.GetAchievementIdByName("Clown PHD"),
    JONAS_LOCK = Isaac.GetAchievementIdByName("Jonas' Lock"),
    PILLS = Isaac.GetAchievementIdByName("Pill Diversity!"),
    DRILL = Isaac.GetAchievementIdByName("Drill"),
}

---@type CollectibleType[]
mod.COLLECTIBLE = {
    COCONUT_OIL = Isaac.GetItemIdByName("Coconut Oil"),
    CONDENSED_MILK = Isaac.GetItemIdByName("Condensed Milk"),
    EYESTRAIN = Isaac.GetItemIdByName("Eyestrain"),
    SNOWCONE = Isaac.GetItemIdByName("Snowcone"),
    EVIL_ROCK = Isaac.GetItemIdByName("Evil Rock"),
    GOAT_MILK = Isaac.GetItemIdByName("Goat Milk"),
    LOOSE_BOWELS = Isaac.GetItemIdByName("Loose Bowels"),
    PLIERS = Isaac.GetItemIdByName("Pliers"),
    NOSE_CANDY = Isaac.GetItemIdByName("Nose Candy"),
    LION_SKULL = Isaac.GetItemIdByName("Lion Skull"),
    DADS_SLIPPER = Isaac.GetItemIdByName("Dad's Slipper"),
    GOOD_JOB = Isaac.GetItemIdByName("Good Job"),
    ODD_ONION = Isaac.GetItemIdByName("Odd Onion"),
    CARAMEL_APPLE = Isaac.GetItemIdByName("Caramel Apple"),
    BLOOD_RITUAL = Isaac.GetItemIdByName("Blood Ritual"),
    TECH_IX = Isaac.GetItemIdByName("Tech IX"),
    DRIED_PLACENTA = Isaac.GetItemIdByName("Dried Placenta"),
    PAINKILLERS = Isaac.GetItemIdByName("Painkillers"),
    SILK_BAG = Isaac.GetItemIdByName("Silk Bag"),
    BRAINFREEZE = Isaac.GetItemIdByName("Brainfreeze"),
    FATAL_SIGNAL = Isaac.GetItemIdByName("Fatal Signal"),
    METEOR_SHOWER = Isaac.GetItemIdByName("Meteor Shower"),
    BLESSED_RING = Isaac.GetItemIdByName("Blessed Ring"),
    SIGIL_OF_GREED = Isaac.GetItemIdByName("Sigil of Greed"),
    PEPPER_X = Isaac.GetItemIdByName("Pepper X"),
    SUNK_COSTS = Isaac.GetItemIdByName("Sunk Costs"),
    GILDED_APPLE = Isaac.GetItemIdByName("Gilded Apple"),
    ONYX = Isaac.GetItemIdByName("Onyx"),
    DADS_PRESCRIPTION = Isaac.GetItemIdByName("Dad's Prescription"),
    HORSE_TRANQUILIZER = Isaac.GetItemIdByName("Horse Tranquilizer"),
    BOBS_HEART = Isaac.GetItemIdByName("Bob's Heart"),
    GLASS_VESSEL = Isaac.GetItemIdByName("Glass Vessel"),
    BONE_BOY = Isaac.GetItemIdByName("Bone Boy"),
    HOSTILE_TAKEOVER = Isaac.GetItemIdByName("Hostile Takeover"),
    STEEL_SOUL = Isaac.GetItemIdByName("Steel Soul"),
    ROCK_CANDY = Isaac.GetItemIdByName("Rock Candy"),
    GIANT_CAPSULE = Isaac.GetItemIdByName("Giant Capsule"),
    PEZ_DISPENSER = Isaac.GetItemIdByName("Candy Dispenser"),
    MISSING_PAGE_3 = Isaac.GetItemIdByName("Missing Page 3"),
    ASCENSION = Isaac.GetItemIdByName("Ascension"),
    FOUR_FOUR = Isaac.GetItemIdByName("4 4"),
    DR_BUM = Isaac.GetItemIdByName("Dr. Bum"),
    JONAS_MASK = Isaac.GetItemIdByName("Jonas' Mask"),
    CLOWN_PHD = Isaac.GetItemIdByName("Clown PHD"),
    DRILL = Isaac.GetItemIdByName("Drill"),
    ALPHABET_BOX = Isaac.GetItemIdByName("Alphabet Box"),
    LOVE_LETTER = Isaac.GetItemIdByName("Love Letter"),
    QUAKE_BOMBS = Isaac.GetItemIdByName("Quake Bombs"),
    ATHEISM = Isaac.GetItemIdByName("Atheism"),
    MAYONAISE = Isaac.GetItemIdByName("A Spoonful of Mayonnaise"),
    AWESOME_FRUIT = Isaac.GetItemIdByName("Awesome Fruit"),
    BLOODY_MAP = Isaac.GetItemIdByName("Bloody Map"),
    SALTPETER = Isaac.GetItemIdByName("Saltpeter"),
    PREFERRED_OPTIONS = Isaac.GetItemIdByName("Preferred Options"),
    PLASMA_GLOBE = Isaac.GetItemIdByName("Plasma Globe"),
    CURSED_EULOGY = Isaac.GetItemIdByName("Cursed Eulogy"),
    BLESSED_BOMBS = Isaac.GetItemIdByName("Blessed Bombs"),
    BLOODY_WHISTLE = Isaac.GetItemIdByName("Bloody Whistle"),
    HEMORRHAGE = Isaac.GetItemIdByName("Haemorrhage"),
    FISH = Isaac.GetItemIdByName("Fish"),

    RETROFALL = Isaac.GetItemIdByName("RETROFALL"),
    CATHARSIS = Isaac.GetItemIdByName("Catharsis"),
    EQUALIZER = Isaac.GetItemIdByName("Equalizer"),
    D = Isaac.GetItemIdByName("D"),
    --BTRAIN = Isaac.GetItemIdByName("B-Train"),                      --*LOST MEDIA (its actually just the origin of Fast Forward from d!edith)

    PORTABLE_TELLER = Isaac.GetItemIdByName("Portable Teller"),

    --LASER_POINTER = Isaac.GetItemIdByName("Laser Pointer"),         --*UNUSED (i dont like the item)
    --TOY_GUN = Isaac.GetItemIdByName("Toy Gun"),                     --*UNUSED (same as above)
    --MALICIOUS_BRAIN = Isaac.GetItemIdByName("Malicious Brain"),     --*UNUSED (same)
}

---@type TrinketType[]
mod.TRINKET = {
    ANTIBIOTICS = Isaac.GetTrinketIdByName("Antibiotics"),
    WONDER_DRUG = Isaac.GetTrinketIdByName("Wonder Drug"),
    AMBER_FOSSIL = Isaac.GetTrinketIdByName("Amber Fossil"),
    JONAS_LOCK = Isaac.GetTrinketIdByName("Jonas' Lock"),
    SINE_WORM = Isaac.GetTrinketIdByName("Sine Worm"),
    BIG_BLIND = Isaac.GetTrinketIdByName("Big Blind"),
    BATH_WATER = Isaac.GetTrinketIdByName("Bath Water"),
    BLACK_RUNE_SHARD = Isaac.GetTrinketIdByName("Black Rune Shard"),
    YELLOW_BELT = Isaac.GetTrinketIdByName("Yellow Belt"),
    SUPPOSITORY = Isaac.GetTrinketIdByName("Suppository"),

    --LIMIT_BREAK = Isaac.GetTrinketIdByName("LIMIT BREAK"),            --*UNUSED
    --FOAM_BULLET = Isaac.GetTrinketIdByName("Foam Bullet"),            --*UNUSED
}

---@type Card[]
mod.CONSUMABLE = {
    PRISMSTONE = Isaac.GetCardIdByName("Prismstone"),
    FOIL_CARD = Isaac.GetCardIdByName("Foil Card"),
    LAUREL = Isaac.GetCardIdByName("Laurel"),
    YANNY = Isaac.GetCardIdByName("Yanny"),
    
    MANTLE_ROCK = Isaac.GetCardIdByName("Rock Mantle"),
    MANTLE_POOP = Isaac.GetCardIdByName("Poop Mantle"),
    MANTLE_BONE = Isaac.GetCardIdByName("Bone Mantle"),
    MANTLE_DARK = Isaac.GetCardIdByName("Dark Mantle"),
    MANTLE_HOLY = Isaac.GetCardIdByName("Holy Mantle"),
    MANTLE_SALT = Isaac.GetCardIdByName("Salt Mantle"),
    MANTLE_GLASS = Isaac.GetCardIdByName("Glass Mantle"),
    MANTLE_METAL = Isaac.GetCardIdByName("Metal Mantle"),
    MANTLE_GOLD = Isaac.GetCardIdByName("Gold Mantle"),
}

---@type PillEffect[]
mod.PILL_EFFECT = {
    I_BELIEVE = Isaac.GetPillEffectByName("I Believe I Can Fly!"),
    DYSLEXIA = Isaac.GetPillEffectByName("Dyslexia"),
    DMG_UP = Isaac.GetPillEffectByName("Damage Up"),
    DMG_DOWN = Isaac.GetPillEffectByName("Damage Down"),
    DEMENTIA = Isaac.GetPillEffectByName("Dementia"),
    PARASITE = Isaac.GetPillEffectByName("Parasite!"),
    FENT = Isaac.GetPillEffectByName("Fent"),
    YOUR_SOUL_IS_MINE = Isaac.GetPillEffectByName("Your Soul is Mine"),
    ARTHRITIS = Isaac.GetPillEffectByName("Arthritis"),
    OSSIFICATION = Isaac.GetPillEffectByName("Ossification"),
    --BLEEEGH = Isaac.GetPillEffectByName("Bleeegh!"),
    VITAMINS = Isaac.GetPillEffectByName("Vitamins!"),
    COAGULANT = Isaac.GetPillEffectByName("Coagulant"),
    FOOD_POISONING = Isaac.GetPillEffectByName("Food Poisoning"),
    HEARTBURN = Isaac.GetPillEffectByName("Heartburn"),
    MUSCLE_ATROPHY = Isaac.GetPillEffectByName("Muscle Atrophy"),
    CAPSULE = Isaac.GetPillEffectByName("Capsule"),
}

---@type FamiliarVariant[]
mod.FAMILIAR_VARIANT = {
    HYPNOS = Isaac.GetEntityVariantByName("Malicious Brain"),
    SILK_BAG = Isaac.GetEntityVariantByName("Silk Bag"),
    BONE_BOY = Isaac.GetEntityVariantByName("Bone Boy"),
    EVIL_SHADOW = Isaac.GetEntityVariantByName("Black Spirit"),
    VIRUS = Isaac.GetEntityVariantByName("Virus (Red)"),
    MASK_SHADOW = Isaac.GetEntityVariantByName("Shadow Fly"),
    DR_BUM = Isaac.GetEntityVariantByName("Dr Bum"),
    BATH_WATER = Isaac.GetEntityVariantByName("Bath Water"),
}

---@type EffectVariant[]
mod.EFFECT_VARIANT = {
    BLOOD_RITUAL_PENTAGRAM = Isaac.GetEntityVariantByName("Blood Ritual Pentagram"),
    METEOR_TEAR_EXPLOSION = Isaac.GetEntityVariantByName("Meteor Tear Explosion"),
    GOLDMANTLE_BREAK = Isaac.GetEntityVariantByName("Gold Mantle Shatter"),
    GREED_SIGIL_CHARGEBAR = Isaac.GetEntityVariantByName("Greed Sigil Chargebar"),
    ASCENSION_PLAYER_DEATH = Isaac.GetEntityVariantByName("Ascension Dead Player"),
    AURA = Isaac.GetEntityVariantByName("Enemy Fear Aura"),
    VESSEL_BREAK = Isaac.GetEntityVariantByName("Glass Vessel Break"),
}

---@type PickupVariant[]
mod.PICKUP_VARIANT = {
    MAMMONS_OFFERING_PENNY = Isaac.GetEntityVariantByName("Mammon's Offering Penny"),
    BLACK_SOUL = Isaac.GetEntityVariantByName("Black Soul"),
    BLOOD_SOUL = Isaac.GetEntityVariantByName("Blood Soul"),
    INK_1 = Isaac.GetEntitySubTypeByName("Ink (1)"),
    INK_2 = Isaac.GetEntitySubTypeByName("Ink (2)"),
    INK_5 = Isaac.GetEntitySubTypeByName("Ink (5)"),
}

---@type TearVariant[]
mod.TEAR_VARIANT = {
    METEOR = Isaac.GetEntityVariantByName("Meteor Tear"),
    BULLET = Isaac.GetEntityVariantByName("Foam Bullet Tear"),
    SOUNDWAVE = Isaac.GetEntityVariantByName("Soundwave Tear"),
    PAPER = Isaac.GetEntityVariantByName("Tome Paper Tear"),
}

---@type SoundEffect
mod.SOUND_EFFECT = {
    FOUR_FOUR_SCREAM = Isaac.GetSoundIdByName("Toybox_4_4_Scream"),
    SILK_BAG_SHIELD = Isaac.GetSoundIdByName("Toybox_SilkBag_Shield"),
    TOY_GUN_RELOAD = Isaac.GetSoundIdByName("Toybox_ToyGun_Reload"),
    BULLET_FIRE = Isaac.GetSoundIdByName("Toybox_Bullet_Shoot"),
    BULLET_HIT = Isaac.GetSoundIdByName("Toybox_Bullet_Hit"),
    POWERUP = Isaac.GetSoundIdByName("Toybox_PowerUp"),
    POWERDOWN = Isaac.GetSoundIdByName("Toybox_PowerDown"),
    VIRUS_SPAWN = Isaac.GetSoundIdByName("Toybox_Virus_Spawn"),
    VIRUS_SHOOT = Isaac.GetSoundIdByName("Toybox_Virus_Shoot"),
    VIRUS_DIE = Isaac.GetSoundIdByName("Toybox_Virus_Die"),
    SHADOW_SCREAM = Isaac.GetSoundIdByName("Toybox_Shadow_Scream"),
    BLOODY_WHISTLE = Isaac.GetSoundIdByName("Toybox_Bloody_Whistle"),
    ATLASA_ROCKCRACK = Isaac.GetSoundIdByName("Toybox_AtlasA_RockCrack"),
    ATLASA_ROCKBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_RockBreak"),
    ATLASA_METALBLOCK = Isaac.GetSoundIdByName("Toybox_AtlasA_MetalBlock"),
    ATLASA_METALBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_MetalBreak"),
    ATLASA_GLASSBREAK = Isaac.GetSoundIdByName("Toybox_AtlasA_GlassBreak"),
}
for _, soundEffect in ipairs(mod.SOUND_EFFECT) do
    sfx:Preload(soundEffect)
end

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

mod.NPC_BOSS = Isaac.GetEntityTypeByName("Shy Gal")
mod.BOSS_SHYGAL = Isaac.GetEntityVariantByName("Shy Gal")
mod.NPC_SHYGAL_CLONE = Isaac.GetEntityVariantByName("Shy Gal Clone")
mod.NPC_SHYGAL_MASK = Isaac.GetEntityVariantByName("Shy Gal Mask")

mod.BOSS_RED_MEGALODON = Isaac.GetEntityVariantByName("Red Megalodon")
mod.NPC_STONE_CREEP_VAR = Isaac.GetEntityVariantByName("Stone Creep")

mod.NPC_MAIN = Isaac.GetEntityTypeByName("Stumpy")
mod.VAR_STUMPY = Isaac.GetEntityVariantByName("Stumpy")

---@type ShaderType
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

---@type CallbackID[]
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
    POST_POOP_DESTROY = "TOYBOX_POST_POOP_DESTROY",
    POOP_SPAWN_DROP = "TOYBOX_POOP_SPAWN_DROP",
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
        Achievement = mod.ACHIEVEMENT.ROCK_CANDY,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.BOSS_RUSH)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.SALTPETER,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.HUSH)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.ASCENSION,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.ISAAC)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.GLASS_VESSEL,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.BLUE_BABY)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.MISSING_PAGE_3,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.SATAN)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.BONE_BOY,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.LAMB)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.GILDED_APPLE,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.ULTRA_GREED)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.PRISMSTONE,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.ULTRA_GREED)>=2
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.AMBER_FOSSIL,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.MOTHER)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.STEEL_SOUL,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.BEAST)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.HOSTILE_TAKEOVER,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.DELIRIUM)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.MANTLES,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.ATLAS_A, CompletionType.MEGA_SATAN)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.MIRACLE_MANTLE,
        Condition = function()
            return Isaac.AllMarksFilled(mod.PLAYER_TYPE.ATLAS_A)>=2
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.JONAS_LOCK,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.BOSS_RUSH)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.WONDER_DRUG,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.HUSH)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.DADS_PRESCRIPTION,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.ISAAC)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.CANDY_DISPENSER,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.BLUE_BABY)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.DR_BUM,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.SATAN)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.JONAS_MASK,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.LAMB)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.ANTIBIOTICS,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.ULTRA_GREED)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.FOIL_CARD,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.ULTRA_GREED)>=2
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.HORSE_TRANQUILIZER,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.MOTHER)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.CLOWN_PHD,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.BEAST)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.GIANT_CAPSULE,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.DELIRIUM)>0
        end,
    },
    {
        Achievement = mod.ACHIEVEMENT.PILLS,
        Condition = function()
            return Isaac.GetCompletionMark(mod.PLAYER_TYPE.JONAS_A, CompletionType.MEGA_SATAN)>0
        end,
    },
}

--#endregion
--#region --!ATLAS_A

mod.MANTLE_DATA = {
    NONE = {
        ID = 0,
        HP = 0,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,0),
        ANIM = "Empty",
        HURT_SFX = 0,
        BREAK_SFX = 0,
    },
    DEFAULT = {
        ID = 1,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_ROCK,
        SHARD_COLOR = Color(153/255,139/255,136/255,1),
        ANIM = "RockMantle",
        HURT_SFX = mod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Useless",
        REG_DESC = "Rock and roll",
    },
    POOP = {
        ID = 2,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_POOP,
        SHARD_COLOR = Color(124/255,86/255,52/255,1),
        ANIM = "PoopMantle",
        HURT_SFX = mod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "More poops / Better poops",
        REG_DESC = "On-command diarrhea",
    },
    BONE = {
        ID = 3,
        HP = 3,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_BONE,
        SHARD_COLOR = Color(95/255,112/255,121/255,1),
        ANIM = "BoneMantle",
        HURT_SFX = mod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Bones on kill, panic = sorrow",
        REG_DESC = "Bone buddy + bones on kill",
    },
    DARK = {
        ID = 4,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_DARK,
        SHARD_COLOR = Color(59/255,59/255,59/255,1),
        ANIM = "DarkMantle",
        HURT_SFX = mod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_ROCKBREAK,

        ATLAS_DESC = "DMG up + mass room damage / Dark aura",
        REG_DESC = "Mass floor damage",
    },
    HOLY = {
        ID = 5,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_HOLY,
        FLIGHT_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/tb_costume_atlas_wings.anm2"),
        SHARD_COLOR = Color(190/255,190/255,190/255,1),
        ANIM = "HolyMantle",
        HURT_SFX = mod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Range up + sacred tears, flight + holy aura",
        REG_DESC = "Eternity + \"god\" tears",
    },
    SALT = {
        ID = 6,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_SALT,
        CHARIOT_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/tb_costume_atlas_salt.anm2"),
        SHARD_COLOR = Color(1,1,1,1),
        ANIM = "SaltMantle",
        HURT_SFX = mod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Tears up / On-command salt chariot",
        REG_DESC = "Temporary sorrow",
    },
    GLASS = {
        ID = 7,
        HP = 1,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_GLASS,
        SHARD_COLOR = Color(1,1,1,1),
        ANIM = "GlassMantle",
        HURT_SFX = 0,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_GLASSBREAK,
                
        ATLAS_DESC = "DMG + shotspeed up + brittle protection",
        REG_DESC = "DMG up + fragility up",
    },
    METAL = {
        ID = 8,
        HP = 3,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_METAL,
        SHARD_COLOR = Color(147/255,147/255,147/255,1),
        ANIM = "MetalMantle",
        HURT_SFX = mod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_METALBREAK,
                
        ATLAS_DESC = "Speed down + defense up",
        REG_DESC = "Tough skin",
    },
    GOLD = {
        ID = 9,
        HP = 2,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_GOLD,
        SHARD_COLOR = Color(205/255,181/255,60/255,1),
        ANIM = "GoldMantle",
        HURT_SFX = mod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = mod.SOUND_EFFECT.ATLASA_METALBREAK,
                
        ATLAS_DESC = "Luck up + gold panic, penny tears",
        REG_DESC = "Microtransactions",
    },

    TAR = {
        ID = 1024,
        HP = 0,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,1),
        ANIM = "TarMantle",
        HURT_SFX = 0,
        BREAK_SFX = 0,
    },
    UNKNOWN = {
        ID = 1000,
        HP = 0,
        CONSUMABLE_SUBTYPE = mod.CONSUMABLE.MANTLE_ROCK,
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