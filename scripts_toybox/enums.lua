
local sfx = SFXManager()

ToyboxMod.DATA_LOADED = false

ToyboxMod.ENUMS = {
    ITEM_SHADER_INACTIVE = 0,
    ITEM_SHADER_RETRO = 1,
    ITEM_SHADER_GOLD = 2,
}

---@type PlayerType[]
ToyboxMod.PLAYER_TYPE = {
    MILCOM_A = Isaac.GetPlayerTypeByName("Milcom", false),
    ATLAS_A = Isaac.GetPlayerTypeByName("Atlas", false),
    ATLAS_A_TAR = Isaac.GetPlayerTypeByName("The Tar", false),
    JONAS_A = Isaac.GetPlayerTypeByName("Jonas", false),

    MILCOM_B = Isaac.GetPlayerTypeByName("Milcom", true),
    ATLAS_B = Isaac.GetPlayerTypeByName("Atlas", true),
    JONAS_B = Isaac.GetPlayerTypeByName("Jonas", true),
}

---@type Achievement[]
ToyboxMod.ACHIEVEMENT = {
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

ToyboxMod.COLLECTIBLE_COCONUT_OIL = Isaac.GetItemIdByName("Coconut Oil")
ToyboxMod.COLLECTIBLE_CONDENSED_MILK = Isaac.GetItemIdByName("Condensed Milk")
ToyboxMod.COLLECTIBLE_EYESTRAIN = Isaac.GetItemIdByName("Eyestrain")
ToyboxMod.COLLECTIBLE_SNOWCONE = Isaac.GetItemIdByName("Snowcone")
ToyboxMod.COLLECTIBLE_EVIL_ROCK = Isaac.GetItemIdByName("Evil Rock")
ToyboxMod.COLLECTIBLE_GOAT_MILK = Isaac.GetItemIdByName("Goat Milk")
ToyboxMod.COLLECTIBLE_LOOSE_BOWELS = Isaac.GetItemIdByName("Loose Bowels")
ToyboxMod.COLLECTIBLE_PLIERS = Isaac.GetItemIdByName("Pliers")
ToyboxMod.COLLECTIBLE_NOSE_CANDY = Isaac.GetItemIdByName("Nose Candy")
ToyboxMod.COLLECTIBLE_LION_SKULL = Isaac.GetItemIdByName("Lion Skull")
ToyboxMod.COLLECTIBLE_DADS_SLIPPER = Isaac.GetItemIdByName("Dad's Slipper")
ToyboxMod.COLLECTIBLE_GOOD_JOB = Isaac.GetItemIdByName("Good Job")
ToyboxMod.COLLECTIBLE_ODD_ONION = Isaac.GetItemIdByName("Odd Onion")
ToyboxMod.COLLECTIBLE_CARAMEL_APPLE = Isaac.GetItemIdByName("Caramel Apple")
ToyboxMod.COLLECTIBLE_BLOOD_RITUAL = Isaac.GetItemIdByName("Blood Ritual")
ToyboxMod.COLLECTIBLE_TECH_IX = Isaac.GetItemIdByName("Tech IX")
ToyboxMod.COLLECTIBLE_DRIED_PLACENTA = Isaac.GetItemIdByName("Dried Placenta")
ToyboxMod.COLLECTIBLE_PAINKILLERS = Isaac.GetItemIdByName("Painkillers")
ToyboxMod.COLLECTIBLE_SILK_BAG = Isaac.GetItemIdByName("Silk Bag")
ToyboxMod.COLLECTIBLE_BRAINFREEZE = Isaac.GetItemIdByName("Brainfreeze")
ToyboxMod.COLLECTIBLE_FATAL_SIGNAL = Isaac.GetItemIdByName("Fatal Signal")
ToyboxMod.COLLECTIBLE_METEOR_SHOWER = Isaac.GetItemIdByName("Meteor Shower")
ToyboxMod.COLLECTIBLE_BLESSED_RING = Isaac.GetItemIdByName("Blessed Ring")
ToyboxMod.COLLECTIBLE_SIGIL_OF_GREED = Isaac.GetItemIdByName("Sigil of Greed")
ToyboxMod.COLLECTIBLE_PEPPER_X = Isaac.GetItemIdByName("Pepper X")
ToyboxMod.COLLECTIBLE_SUNK_COSTS = Isaac.GetItemIdByName("Sunk Costs")
ToyboxMod.COLLECTIBLE_GILDED_APPLE = Isaac.GetItemIdByName("Gilded Apple")
ToyboxMod.COLLECTIBLE_ONYX = Isaac.GetItemIdByName("Onyx")
ToyboxMod.COLLECTIBLE_DADS_PRESCRIPTION = Isaac.GetItemIdByName("Dad's Prescription")
ToyboxMod.COLLECTIBLE_HORSE_TRANQUILIZER = Isaac.GetItemIdByName("Horse Tranquilizer")
ToyboxMod.COLLECTIBLE_BOBS_HEART = Isaac.GetItemIdByName("Bob's Heart")
ToyboxMod.COLLECTIBLE_GLASS_VESSEL = Isaac.GetItemIdByName("Glass Vessel")
ToyboxMod.COLLECTIBLE_BONE_BOY = Isaac.GetItemIdByName("Bone Boy")
ToyboxMod.COLLECTIBLE_HOSTILE_TAKEOVER = Isaac.GetItemIdByName("Hostile Takeover")
ToyboxMod.COLLECTIBLE_STEEL_SOUL = Isaac.GetItemIdByName("Steel Soul")
ToyboxMod.COLLECTIBLE_ROCK_CANDY = Isaac.GetItemIdByName("Rock Candy")
ToyboxMod.COLLECTIBLE_GIANT_CAPSULE = Isaac.GetItemIdByName("Giant Capsule")
ToyboxMod.COLLECTIBLE_PEZ_DISPENSER = Isaac.GetItemIdByName("Candy Dispenser")
ToyboxMod.COLLECTIBLE_MISSING_PAGE_3 = Isaac.GetItemIdByName("Missing Page 3")
ToyboxMod.COLLECTIBLE_ASCENSION = Isaac.GetItemIdByName("Ascension")
ToyboxMod.COLLECTIBLE_4_4 = Isaac.GetItemIdByName("4 4")
ToyboxMod.COLLECTIBLE_DR_BUM = Isaac.GetItemIdByName("Dr. Bum")
ToyboxMod.COLLECTIBLE_JONAS_MASK = Isaac.GetItemIdByName("Jonas' Mask")
ToyboxMod.COLLECTIBLE_CLOWN_PHD = Isaac.GetItemIdByName("Clown PHD")
ToyboxMod.COLLECTIBLE_DRILL = Isaac.GetItemIdByName("Drill")
ToyboxMod.COLLECTIBLE_ALPHABET_BOX = Isaac.GetItemIdByName("Alphabet Box")
ToyboxMod.COLLECTIBLE_LOVE_LETTER = Isaac.GetItemIdByName("Love Letter")
ToyboxMod.COLLECTIBLE_QUAKE_BOMBS = Isaac.GetItemIdByName("Quake Bombs")
ToyboxMod.COLLECTIBLE_ATHEISM = Isaac.GetItemIdByName("Atheism")
ToyboxMod.COLLECTIBLE_MAYONAISE = Isaac.GetItemIdByName("A Spoonful of Mayonnaise")
ToyboxMod.COLLECTIBLE_AWESOME_FRUIT = Isaac.GetItemIdByName("Awesome Fruit")
ToyboxMod.COLLECTIBLE_BLOODY_MAP = Isaac.GetItemIdByName("Bloody Map")
ToyboxMod.COLLECTIBLE_SALTPETER = Isaac.GetItemIdByName("Saltpeter")
ToyboxMod.COLLECTIBLE_PREFERRED_OPTIONS = Isaac.GetItemIdByName("Preferred Options")
ToyboxMod.COLLECTIBLE_PLASMA_GLOBE = Isaac.GetItemIdByName("Plasma Globe")
ToyboxMod.COLLECTIBLE_CURSED_EULOGY = Isaac.GetItemIdByName("Cursed Eulogy")
ToyboxMod.COLLECTIBLE_BLESSED_BOMBS = Isaac.GetItemIdByName("Blessed Bombs")
ToyboxMod.COLLECTIBLE_BLOODY_WHISTLE = Isaac.GetItemIdByName("Bloody Whistle")
ToyboxMod.COLLECTIBLE_HEMORRHAGE = Isaac.GetItemIdByName("Haemorrhage")
ToyboxMod.COLLECTIBLE_FISH = Isaac.GetItemIdByName("Fish")
ToyboxMod.COLLECTIBLE_BOBS_THESIS = Isaac.GetItemIdByName("Bob's Thesis")
ToyboxMod.COLLECTIBLE_PLACEHOLDER = Isaac.GetItemIdByName("Placeholder")
ToyboxMod.COLLECTIBLE_ART_OF_WAR = Isaac.GetItemIdByName("Art of War")
ToyboxMod.COLLECTIBLE_ASTEROID_BELT = Isaac.GetItemIdByName("Asteroid Belt")
ToyboxMod.COLLECTIBLE_BARBED_WIRE = Isaac.GetItemIdByName("Barbed Wire")
ToyboxMod.COLLECTIBLE_BIG_BANG = Isaac.GetItemIdByName("Big Bang")
ToyboxMod.COLLECTIBLE_COFFEE_CUP = Isaac.GetItemIdByName("Coffee Cup")
ToyboxMod.COLLECTIBLE_LAST_BEER = Isaac.GetItemIdByName("Last Beer")
ToyboxMod.COLLECTIBLE_CHOCOLATE_BAR = Isaac.GetItemIdByName("Chocolate Bar")
ToyboxMod.COLLECTIBLE_EXORCISM_KIT = Isaac.GetItemIdByName("Exorcism Kit")
ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS = Isaac.GetItemIdByName("Conjunctivitis")
ToyboxMod.COLLECTIBLE_FOOD_STAMPS = Isaac.GetItemIdByName("Food Stamps")
ToyboxMod.COLLECTIBLE_GOLDEN_CALF = Isaac.GetItemIdByName("Golden Calf")
ToyboxMod.COLLECTIBLE_RETROFALL = Isaac.GetItemIdByName("RETROFALL")
ToyboxMod.COLLECTIBLE_D = Isaac.GetItemIdByName("D0")
ToyboxMod.COLLECTIBLE_BRUNCH = Isaac.GetItemIdByName("Brunch")
ToyboxMod.COLLECTIBLE_TOAST = Isaac.GetItemIdByName("Toast")
ToyboxMod.COLLECTIBLE_DELIVERY_BOX = Isaac.GetItemIdByName("Delivery Box")
ToyboxMod.COLLECTIBLE_LUCKY_PEBBLES = Isaac.GetItemIdByName("Lucky Pebbles")
ToyboxMod.COLLECTIBLE_MOMS_PHOTOBOOK = Isaac.GetItemIdByName("Mom's Photobook")
ToyboxMod.COLLECTIBLE_FINGER_TRAP = Isaac.GetItemIdByName("Finger Trap")
ToyboxMod.COLLECTIBLE_HEMOLYMPH = Isaac.GetItemIdByName("Hemolymph")
ToyboxMod.COLLECTIBLE_SOLAR_PANEL = Isaac.GetItemIdByName("Solar Panel")
ToyboxMod.COLLECTIBLE_SURPRISE_EGG = Isaac.GetItemIdByName("Surprise Egg")
ToyboxMod.COLLECTIBLE_COLOSSAL_ORB = Isaac.GetItemIdByName("Colossal Orb")
ToyboxMod.COLLECTIBLE_SACK_OF_CHESTS = Isaac.GetItemIdByName("Sack of Chests")
ToyboxMod.COLLECTIBLE_BABY_SHOES = Isaac.GetItemIdByName("Baby Shoes")
ToyboxMod.COLLECTIBLE_EFFIGY = Isaac.GetItemIdByName("Effigy")
ToyboxMod.COLLECTIBLE_GAMBLING_ADDICTION = Isaac.GetItemIdByName("Gambling Addiction")
ToyboxMod.COLLECTIBLE_PYRAMID_SCHEME = Isaac.GetItemIdByName("Pyramid Scheme")
ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP = Isaac.GetItemIdByName("Pythagoras' Cup")
ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE = Isaac.GetItemIdByName("Pythagoras' Cup ")

ToyboxMod.COLLECTIBLE_CATHARSIS = Isaac.GetItemIdByName("Catharsis")
ToyboxMod.COLLECTIBLE_URANIUM = Isaac.GetItemIdByName("Uranium")
ToyboxMod.COLLECTIBLE_EQUALIZER = Isaac.GetItemIdByName("Equalizer")
ToyboxMod.COLLECTIBLE_GOLDEN_PRAYER_CARD = Isaac.GetItemIdByName("Golden Prayer Card")
ToyboxMod.COLLECTIBLE_GOLDEN_SCHOOLBAG = Isaac.GetItemIdByName("Golden Schoolbag")
ToyboxMod.COLLECTIBLE_ZERO_GRAVITY = Isaac.GetItemIdByName("Zero-Gravity")
ToyboxMod.COLLECTIBLE_SUPER_HAMBURGER = Isaac.GetItemIdByName("Super Hamburger")
    
--ToyboxMod.COLLECTIBLE_BTRAIN = Isaac.GetItemIdByName("B-Train")                      --*LOST MEDIA (its actually just the origin of Fast Forward from d!edith)

ToyboxMod.COLLECTIBLE_COMPRESSED_DICE = Isaac.GetItemIdByName("Compressed Dice")
ToyboxMod.COLLECTIBLE_PORTABLE_TELLER = Isaac.GetItemIdByName("Portable Teller")

--ToyboxMod.COLLECTIBLE_LASER_POINTER = Isaac.GetItemIdByName("Laser Pointer")         --*UNUSED (i dont like the item)
--ToyboxMod.COLLECTIBLE_TOY_GUN = Isaac.GetItemIdByName("Toy Gun")                     --*UNUSED (same as above)
--ToyboxMod.COLLECTIBLE_MALICIOUS_BRAIN = Isaac.GetItemIdByName("Malicious Brain")     --*UNUSED (same)

ToyboxMod.TRINKET_ANTIBIOTICS = Isaac.GetTrinketIdByName("Antibiotics")
ToyboxMod.TRINKET_WONDER_DRUG = Isaac.GetTrinketIdByName("Wonder Drug")
ToyboxMod.TRINKET_AMBER_FOSSIL = Isaac.GetTrinketIdByName("Amber Fossil")
ToyboxMod.TRINKET_JONAS_LOCK = Isaac.GetTrinketIdByName("Jonas' Lock")
ToyboxMod.TRINKET_SINE_WORM = Isaac.GetTrinketIdByName("Sine Worm")
ToyboxMod.TRINKET_BIG_BLIND = Isaac.GetTrinketIdByName("Big Blind")
ToyboxMod.TRINKET_BATH_WATER = Isaac.GetTrinketIdByName("Bath Water")
ToyboxMod.TRINKET_BLACK_RUNE_SHARD = Isaac.GetTrinketIdByName("Black Rune Shard")
ToyboxMod.TRINKET_YELLOW_BELT = Isaac.GetTrinketIdByName("Yellow Belt")
ToyboxMod.TRINKET_SUPPOSITORY = Isaac.GetTrinketIdByName("Suppository")
ToyboxMod.TRINKET_DIVIDED_JUSTICE = Isaac.GetTrinketIdByName("Divided Justice")
ToyboxMod.TRINKET_KILLSCREEN = Isaac.GetTrinketIdByName("Killscreen")
ToyboxMod.TRINKET_MIRROR_SHARD = Isaac.GetTrinketIdByName("Mirror Shard")
ToyboxMod.TRINKET_LUCKY_TOOTH = Isaac.GetTrinketIdByName("Lucky Tooth")

--ToyboxMod.TRINKET_LIMIT_BREAK = Isaac.GetTrinketIdByName("LIMIT BREAK")            --*UNUSED
--ToyboxMod.TRINKET_FOAM_BULLET = Isaac.GetTrinketIdByName("Foam Bullet")            --*UNUSED

---@type Card[]
ToyboxMod.CONSUMABLE = {
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
ToyboxMod.PILL_EFFECT = {
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
ToyboxMod.FAMILIAR_VARIANT = {
    HYPNOS = Isaac.GetEntityVariantByName("Malicious Brain"),
    SILK_BAG = Isaac.GetEntityVariantByName("Silk Bag"),
    BONE_BOY = Isaac.GetEntityVariantByName("Bone Boy"),
    EVIL_SHADOW = Isaac.GetEntityVariantByName("Black Spirit"),
    VIRUS = Isaac.GetEntityVariantByName("Virus (Red)"),
    MASK_SHADOW = Isaac.GetEntityVariantByName("Shadow Fly"),
    DR_BUM = Isaac.GetEntityVariantByName("Dr Bum"),
    BATH_WATER = Isaac.GetEntityVariantByName("Bath Water"),
    SACK_OF_CHESTS = Isaac.GetEntityVariantByName("Sack of Chests"),
    EFFIGY = Isaac.GetEntityVariantByName("Effigy"),
    PYTHAGORAS_CUP = Isaac.GetEntityVariantByName("Pythagoras' Cup"),
}

---@type SlotVariant[]
ToyboxMod.SLOT_VARIANT = {
    PYRAMID_DONATION = Isaac.GetEntityVariantByName("Pyramid Donation Machine")
}

---@type EffectVariant[]
ToyboxMod.EFFECT_VARIANT = {
    BLOOD_RITUAL_PENTAGRAM = Isaac.GetEntityVariantByName("Blood Ritual Pentagram"),
    METEOR_TEAR_EXPLOSION = Isaac.GetEntityVariantByName("Meteor Tear Explosion"),
    GOLDMANTLE_BREAK = Isaac.GetEntityVariantByName("Gold Mantle Shatter"),
    GREED_SIGIL_CHARGEBAR = Isaac.GetEntityVariantByName("Greed Sigil Chargebar"),
    ASCENSION_PLAYER_DEATH = Isaac.GetEntityVariantByName("Ascension Dead Player"),
    AURA = Isaac.GetEntityVariantByName("Enemy Fear Aura"),
    VESSEL_BREAK = Isaac.GetEntityVariantByName("Glass Vessel Break"),
    BARBED_WIRE_HALO = Isaac.GetEntityVariantByName("Barbed Wire Halo (TOYBOX)"),
    DRILL = Isaac.GetEntityVariantByName("Drill"),
    PYTHAGORAS_CUP_SPILL = Isaac.GetEntityVariantByName("Pythagoras' Cup Spill"),
    KILLSCREEN_GLITCH = Isaac.GetEntityVariantByName("Killscreen Glitch"),
    JUICE_TRAIL = Isaac.GetEntityVariantByName("Good Juice Trail"),

    ZERO_GRAV_CROSSHAIR = Isaac.GetEntityVariantByName("Zero-Gravity Crosshair")
}

---@type PickupVariant[]
ToyboxMod.PICKUP_VARIANT = {
    MAMMONS_OFFERING_PENNY = Isaac.GetEntityVariantByName("Mammon's Offering Penny"),
    BLACK_SOUL = Isaac.GetEntityVariantByName("Black Soul"),
    BLOOD_SOUL = Isaac.GetEntityVariantByName("Blood Soul"),

    SMORGASBORD = Isaac.GetEntityVariantByName("Smorgasbord"),

    ETERNAL_MOUND = Isaac.GetEntityVariantByName("Eternal Mound"),
}

---@type integer[]
ToyboxMod.PICKUP_SUBTYPE = {
    COIN_INK_1 = Isaac.GetEntitySubTypeByName("Ink (1)"),
    COIN_INK_2 = Isaac.GetEntitySubTypeByName("Ink (2)"),
    COIN_INK_5 = Isaac.GetEntitySubTypeByName("Ink (5)"),

    HEART_QUAD = Isaac.GetEntitySubTypeByName("Quad Heart"),
    HEART_SOUL_DOUBLE = Isaac.GetEntitySubTypeByName("Double Soul Heart"),
    HEART_BLACK_DOUBLE = Isaac.GetEntitySubTypeByName("Double Black Heart"),
    HEART_ROTTEN_DOUBLE = Isaac.GetEntitySubTypeByName("Double Rotten Heart"),
    HEART_ETERNAL_FULL = Isaac.GetEntitySubTypeByName("Full Eternal Heart (TOYBOX)"),
    HEART_BLENDED_DOUBLE = Isaac.GetEntitySubTypeByName("Double Blended Heart"),
    HEART_GOLD_DOUBLE = Isaac.GetEntitySubTypeByName("Double Gold Heart"),
    HEART_BONE_DOUBLE = Isaac.GetEntitySubTypeByName("Double Bone Heart"),
    HEART_BLENDEDBLACK_DOUBLE = Isaac.GetEntitySubTypeByName("Double Blended Black Heart"),
    HEART_BLENDEDIMMORAL_DOUBLE = Isaac.GetEntitySubTypeByName("Double Blended Immoral Heart"),
    HEART_IMMORAL_DOUBLE = Isaac.GetEntitySubTypeByName("Double Immoral Heart"),
    HEART_MORBID_DOUBLE = Isaac.GetEntitySubTypeByName("Double Morbid Heart"),
    HEART_MORBID_FOURTHIRDS = Isaac.GetEntitySubTypeByName("Four-Thirds Morbid Heart"),
}

---@type TearVariant[]
ToyboxMod.TEAR_VARIANT = {
    COOL = Isaac.GetEntityVariantByName("Cool Tear"),
    --METEOR = Isaac.GetEntityVariantByName("Meteor Tear"),
    --BULLET = Isaac.GetEntityVariantByName("Foam Bullet Tear"),
    --SOUNDWAVE = Isaac.GetEntityVariantByName("Soundwave Tear"),
    --PAPER = Isaac.GetEntityVariantByName("Tome Paper Tear"),
}

---@type SoundEffect
ToyboxMod.SOUND_EFFECT = {
    FOUR_FOUR_SCREAM = Isaac.GetSoundIdByName("(TOYBOX) 4 4 Scream"),
    SILK_BAG_SHIELD = Isaac.GetSoundIdByName("(TOYBOX) Silk Bag Shield"),
    TOY_GUN_RELOAD = Isaac.GetSoundIdByName("(TOYBOX) Gun Reload"),
    BULLET_FIRE = Isaac.GetSoundIdByName("(TOYBOX) Bullet Shoot"),
    BULLET_HIT = Isaac.GetSoundIdByName("(TOYBOX) Bullet Hit"),
    POWERUP = Isaac.GetSoundIdByName("(TOYBOX) Powerup"),
    POWERDOWN = Isaac.GetSoundIdByName("(TOYBOX) Powerdown"),
    VIRUS_SPAWN = Isaac.GetSoundIdByName("(TOYBOX) Virus Spawn"),
    VIRUS_SHOOT = Isaac.GetSoundIdByName("(TOYBOX) Virus Shoot"),
    VIRUS_DIE = Isaac.GetSoundIdByName("(TOYBOX) Virus Die"),
    SHADOW_SCREAM = Isaac.GetSoundIdByName("(TOYBOX) Shadow Scream"),
    BLOODY_WHISTLE = Isaac.GetSoundIdByName("(TOYBOX) Whistle"),
    SLIPPER_WHIP = Isaac.GetSoundIdByName("(TOYBOX) Whip"),
    COLOSSAL_ORB_SHOCKWAVE = Isaac.GetSoundIdByName("(TOYBOX) Colossal Orb Shockwave"),

    ATLASA_ROCKCRACK = Isaac.GetSoundIdByName("(TOYBOX) Rock Crack"),
    ATLASA_ROCKBREAK = Isaac.GetSoundIdByName("(TOYBOX) Rock Break"),
    ATLASA_METALBLOCK = Isaac.GetSoundIdByName("(TOYBOX) Metal Block"),
    ATLASA_METALBREAK = Isaac.GetSoundIdByName("(TOYBOX) Metal Break"),
    ATLASA_GLASSBREAK = Isaac.GetSoundIdByName("(TOYBOX) Glass Break"),
}
for _, soundEffect in ipairs(ToyboxMod.SOUND_EFFECT) do
    sfx:Preload(soundEffect)
end

---@type Giantbook
ToyboxMod.GIANTBOOK = {
    BIG_BANG = Isaac.GetGiantBookIdByName("Big Bang (TOYBOX)"),
    MOMS_PHOTOBOOK = Isaac.GetGiantBookIdByName("Mom's Photobook"),
}

ToyboxMod.FAMILIAR_VIRUS_SUBTYPE = {
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
ToyboxMod.FAMILIAR_MASK_SHADOW_SUBTYPE = {
    FLY = Isaac.GetEntitySubTypeByName("Shadow Fly"),
    URCHIN = Isaac.GetEntitySubTypeByName("Shadow Urchin"),
    CRAWLER = Isaac.GetEntitySubTypeByName("Shadow Crawler"),
    BALL = Isaac.GetEntitySubTypeByName("Shadow Fly"),
    ORBITAL = Isaac.GetEntitySubTypeByName("Shadow Urchin"),
    CHASER = Isaac.GetEntitySubTypeByName("Shadow Crawler"),
}
ToyboxMod.EFFECT_AURA_SUBTYPE = {
    ENEMY_FEAR = 0,
    BOMB_BLESSED = 1,
    DARK_MANTLE = 2,
    HOLY_MANTLE = 3,
}

---@type ShaderType
ToyboxMod.SHADERS = {
    EMPTY = "ToyboxEmptyShader",
    BLOOM = "ToyboxBloomShader",
    ASCENSION = "ToyboxAscensionShader",
}

ToyboxMod.TEAR_COPYING_FAMILIARS = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.SPRINKLER] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
    [FamiliarVariant.BLOOD_BABY] = true,
    [FamiliarVariant.UMBILICAL_BABY] = true,
    [FamiliarVariant.CAINS_OTHER_EYE] = true,
    --[FamiliarVariant.FATES_REWARD] = true,
}
ToyboxMod.RED_HEART_SUBTYPES = {
    [HeartSubType.HEART_HALF] = true,
    [HeartSubType.HEART_FULL] = true,
    [HeartSubType.HEART_DOUBLEPACK] = true,
    [HeartSubType.HEART_SCARED] = true,

    [ToyboxMod.PICKUP_SUBTYPE.HEART_QUAD] = true,

    --[HeartSubType.HEART_ROTTEN] = true,
    --[HeartSubType.HEART_BLENDED] = true,
}

ToyboxMod.NPC_BOSS = Isaac.GetEntityTypeByName("Shy Gal")
ToyboxMod.BOSS_SHYGAL = Isaac.GetEntityVariantByName("Shy Gal")
ToyboxMod.NPC_SHYGAL_CLONE = Isaac.GetEntityVariantByName("Shy Gal Clone")
ToyboxMod.NPC_SHYGAL_MASK = Isaac.GetEntityVariantByName("Shy Gal Mask")

ToyboxMod.BOSS_RED_MEGALODON = Isaac.GetEntityVariantByName("Red Megalodon")
ToyboxMod.NPC_STONE_CREEP_VAR = Isaac.GetEntityVariantByName("Stone Creep")

ToyboxMod.NPC_MAIN = Isaac.GetEntityTypeByName("Stumpy")
ToyboxMod.VAR_STUMPY = Isaac.GetEntityVariantByName("Stumpy")



---@type CallbackID[]
ToyboxMod.CUSTOM_CALLBACKS = {
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

ToyboxMod.DAMAGE_TYPE = {
    KNIFE = 1<<0,
    LASER = 1<<1,
    DARK_ARTS = 1<<2,
    ABYSS_LOCUST = 1<<3,
    BOMB = 1<<4,
    AQUARIUS = 1<<5,
    ROCKET = 1<<6,
    TEAR = 1<<7,
}

ToyboxMod.ACHIEVEMENTS = {
    {
        Achievement = ToyboxMod.ACHIEVEMENT.ROCK_CANDY,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.BOSS_RUSH)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.SALTPETER,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.HUSH)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.ASCENSION,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.ISAAC)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.GLASS_VESSEL,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.BLUE_BABY)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.MISSING_PAGE_3,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.SATAN)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.BONE_BOY,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.LAMB)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.GILDED_APPLE,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.ULTRA_GREED)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.PRISMSTONE,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.ULTRA_GREED)>=2
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.AMBER_FOSSIL,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.MOTHER)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.STEEL_SOUL,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.BEAST)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.HOSTILE_TAKEOVER,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.DELIRIUM)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.MANTLES,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.ATLAS_A, CompletionType.MEGA_SATAN)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.MIRACLE_MANTLE,
        Condition = function()
            return Isaac.AllMarksFilled(ToyboxMod.PLAYER_TYPE.ATLAS_A)>=2
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.JONAS_LOCK,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.BOSS_RUSH)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.WONDER_DRUG,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.HUSH)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.DADS_PRESCRIPTION,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.ISAAC)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.CANDY_DISPENSER,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.BLUE_BABY)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.DR_BUM,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.SATAN)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.JONAS_MASK,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.LAMB)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.ANTIBIOTICS,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.ULTRA_GREED)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.FOIL_CARD,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.ULTRA_GREED)>=2
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.HORSE_TRANQUILIZER,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.MOTHER)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.CLOWN_PHD,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.BEAST)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.GIANT_CAPSULE,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.DELIRIUM)>0
        end,
    },
    {
        Achievement = ToyboxMod.ACHIEVEMENT.PILLS,
        Condition = function()
            return Isaac.GetCompletionMark(ToyboxMod.PLAYER_TYPE.JONAS_A, CompletionType.MEGA_SATAN)>0
        end,
    },
}

--#endregion
--#region --!ATLAS_A

ToyboxMod.MANTLE_DATA = {
    NONE = {
        ID = 0,
        HP = 0,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,0),
        ANIM = "Empty",
        HURT_SFX = 0,
        BREAK_SFX = 0,
    },
    DEFAULT = {
        ID = 1,
        HP = 2,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_ROCK,
        SHARD_COLOR = Color(153/255,139/255,136/255,1),
        ANIM = "RockMantle",
        HURT_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Useless",
        REG_DESC = "Rock and roll",

        TRANSF_NAME = "Rock!",
        TRANSF_DESC = "Useless",
    },
    POOP = {
        ID = 2,
        HP = 2,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_POOP,
        SHARD_COLOR = Color(124/255,86/255,52/255,1),
        ANIM = "PoopMantle",
        HURT_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Flies on room clear + more poops",
        REG_DESC = "On-command diarrhea",

        TRANSF_NAME = "Poop!",
        TRANSF_DESC = "Poop healing + better poop drops",
    },
    BONE = {
        ID = 3,
        HP = 3,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_BONE,
        SHARD_COLOR = Color(95/255,112/255,121/255,1),
        ANIM = "BoneMantle",
        HURT_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Bones on kill + bones when lost",
        REG_DESC = "Bone buddy + bones on kill",

        TRANSF_NAME = "Bone!",
        TRANSF_DESC = "Panic = sorrow",
    },
    DARK = {
        ID = 4,
        HP = 2,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_DARK,
        SHARD_COLOR = Color(59/255,59/255,59/255,1),
        ANIM = "DarkMantle",
        HURT_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKBREAK,

        ATLAS_DESC = "DMG up + room damage when lost",
        REG_DESC = "Mass floor damage",

        TRANSF_NAME = "Dark!",
        TRANSF_DESC = "Dark aura",
    },
    HOLY = {
        ID = 5,
        HP = 2,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_HOLY,
        FLIGHT_COSTUME = Isaac.GetCostumeIdByPath("gfx_tb/characters/costume_atlas_wings.anm2"),
        SHARD_COLOR = Color(190/255,190/255,190/255,1),
        ANIM = "HolyMantle",
        HURT_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Range up + sacred tears",
        REG_DESC = "Eternity + \"god\" tears",

        TRANSF_NAME = "Holy!",
        TRANSF_DESC = "Flight + holy aura",
    },
    SALT = {
        ID = 6,
        HP = 2,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_SALT,
        CHARIOT_COSTUME = Isaac.GetCostumeIdByPath("gfx_tb/characters/costume_atlas_salt.anm2"),
        SHARD_COLOR = Color(1,1,1,1),
        ANIM = "SaltMantle",
        HURT_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKBREAK,
                
        ATLAS_DESC = "Tears up",
        REG_DESC = "Temporary sorrow",

        TRANSF_NAME = "Salt!",
        TRANSF_DESC = "On-command salt chariot",
    },
    GLASS = {
        ID = 7,
        HP = 1,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_GLASS,
        SHARD_COLOR = Color(1,1,1,1),
        ANIM = "GlassMantle",
        HURT_SFX = 0,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_GLASSBREAK,
                
        ATLAS_DESC = "DMG + shotspeed up + brittle protection",
        REG_DESC = "DMG up + fragility up",

        TRANSF_NAME = "Glass!",
        TRANSF_DESC = "DMG up + brittler protection",
    },
    METAL = {
        ID = 8,
        HP = 3,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_METAL,
        SHARD_COLOR = Color(147/255,147/255,147/255,1),
        ANIM = "MetalMantle",
        HURT_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_METALBREAK,
                
        ATLAS_DESC = "Speed down + defense up",
        REG_DESC = "Tough skin",

        TRANSF_NAME = "Metal!",
        TRANSF_DESC = "Better defense",
    },
    GOLD = {
        ID = 9,
        HP = 2,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_GOLD,
        SHARD_COLOR = Color(205/255,181/255,60/255,1),
        ANIM = "GoldMantle",
        HURT_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_ROCKCRACK,
        BREAK_SFX = ToyboxMod.SOUND_EFFECT.ATLASA_METALBREAK,
                
        ATLAS_DESC = "Luck up + gild when lost",
        REG_DESC = "Microtransactions",

        TRANSF_NAME = "Gold!",
        TRANSF_DESC = "Penny tears",
    },

    TAR = {
        ID = 1024,
        HP = 0,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,1),
        ANIM = "TarMantle",
        HURT_SFX = 0,
        BREAK_SFX = 0,
    },
    UNKNOWN = {
        ID = 1000,
        HP = 0,
        CONSUMABLE_SUBTYPE = ToyboxMod.CONSUMABLE.MANTLE_ROCK,
        SHARD_COLOR = Color(0,0,0,0),
        ANIM = "Unknown",
        HURT_SFX = 0,
        BREAK_SFX = 0,
    }
}

ToyboxMod.MANTLE_ID_TO_NAME = {
    [ToyboxMod.MANTLE_DATA.NONE.ID] = "NONE",
    [ToyboxMod.MANTLE_DATA.DEFAULT.ID] = "DEFAULT",
    [ToyboxMod.MANTLE_DATA.POOP.ID] = "POOP",
    [ToyboxMod.MANTLE_DATA.BONE.ID] = "BONE",
    [ToyboxMod.MANTLE_DATA.DARK.ID] = "DARK",
    [ToyboxMod.MANTLE_DATA.HOLY.ID] = "HOLY",
    [ToyboxMod.MANTLE_DATA.SALT.ID] = "SALT",
    [ToyboxMod.MANTLE_DATA.GLASS.ID] = "GLASS",
    [ToyboxMod.MANTLE_DATA.METAL.ID] = "METAL",
    [ToyboxMod.MANTLE_DATA.GOLD.ID] = "GOLD",
    [ToyboxMod.MANTLE_DATA.TAR.ID] = "TAR",
}

-- PICKING MANTLES ENUMS
ToyboxMod.SAME_MANTLE_BIAS = {
    [0]=1,
    [1]=7.5,
    [2]=25,
    [3]=1,
}
ToyboxMod.MANTLE_PICKER = {
    {OUTCOME=ToyboxMod.MANTLE_DATA.DEFAULT.ID, WEIGHT=1},
    {OUTCOME=ToyboxMod.MANTLE_DATA.POOP.ID, WEIGHT=1},
    {OUTCOME=ToyboxMod.MANTLE_DATA.BONE.ID, WEIGHT=1},
    {OUTCOME=ToyboxMod.MANTLE_DATA.DARK.ID, WEIGHT=1},
    {OUTCOME=ToyboxMod.MANTLE_DATA.HOLY.ID, WEIGHT=1},
    {OUTCOME=ToyboxMod.MANTLE_DATA.SALT.ID, WEIGHT=1},
    {OUTCOME=ToyboxMod.MANTLE_DATA.GLASS.ID, WEIGHT=1},
    {OUTCOME=ToyboxMod.MANTLE_DATA.METAL.ID, WEIGHT=1},
    {OUTCOME=ToyboxMod.MANTLE_DATA.GOLD.ID, WEIGHT=1},
}

-- MANTLE HP RENDER ENUMS
ToyboxMod.MANTLE_SHARD_GRAVITY = 7

--#endregion
--#region !MILCOM_A

ToyboxMod.CUSTOM_CHAMPIONS = {
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
ToyboxMod.CUSTOM_CHAMPION_IDX_TO_NAME = {
    "FEAR",
    "ETERNAL",
    "DROWNED",
    "SPIDERS",
    "GOLDEN",
    "JELLY",
}

ToyboxMod.CUSTOM_CHAMPION_PICKER = WeightedOutcomePicker()
ToyboxMod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(1, 100, 1000)
ToyboxMod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(2, 1, 1000)
ToyboxMod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(3, 100, 1000)
ToyboxMod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(4, 1, 1000)
ToyboxMod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(5, 1, 1000)
ToyboxMod.CUSTOM_CHAMPION_PICKER:AddOutcomeFloat(6, 100, 1000)

--#endregion