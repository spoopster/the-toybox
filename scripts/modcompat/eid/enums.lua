local mod = MilcomMOD

local function isDoubleTrinketMultiplier(descObj)
    if(PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX)) then return true end
    if((descObj.ObjSubType>=TrinketType.TRINKET_GOLDEN_FLAG)) then return true end
    return false
end
local function isTripleTrinketMultiplier(descObj)
    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and descObj.ObjSubType>=TrinketType.TRINKET_GOLDEN_FLAG
end

local ITEMS = {
    --#region --!PASSIVES
    [mod.COLLECTIBLE_COCONUT_OIL] = {
        Name = "Coconut Oil",
        Description = {
            "\1 +0.5 Tears",
            "\2 -0.25 Speed",
            "Your friction is increased, effectively increasing your movespeed",
        },
    },
    [mod.COLLECTIBLE_CONDENSED_MILK] = {
        Name = "Condensed Milk",
        Description = {
            "\1 x1.2 Tears",
            "Your {{Damage}} damage cannot go above or below 3.5, instead all damage modifiers get funneled into your {{Tears}} tears",
        },
        DescriptionAppend = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LIBRA)
                end,
                DescriptionToAdd = {
                    "{{Collectible304}} Stats are distributed more towards tears and not at all towards damage",
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM)
                end,
                DescriptionToAdd = {
                    "{{Collectible562}} Damage remains unchangeable",
                },
            },
        },
    },
    [mod.COLLECTIBLE_GOAT_MILK] = {
        Name = "Goat Milk",
        Description = {
            "\1 x0.8 Firedelay",
            "Everytime you fire, your firedelay will instead be randomly multiplied by anywhere from x0.45 to x1.35",
        },
    },
    [mod.COLLECTIBLE_NOSE_CANDY] = {
        Name = "Nose Candy",
        Description = {
            "\1 Every floor, you get +0.2 speed",
            "{{Blank}}  \7 If this bonus would make your speed higher than 2, the overflowing speed becomes a bonus to a non-speed stat",
            "\1 Every floor, you get a small stat-up to a non-speed stat",
            "\2 Every floor, you get a small stat-down to a non-speed stat",
        },
    },
    [mod.COLLECTIBLE_LION_SKULL] = {
        Name = "Lion Skull",
        Description = {
            "\1 Every room cleared gives a stacking x1.04 damage multiplier",
            "\2 When you take damage, lose the multiplier and get a damage down proportional to rooms cleared damageless",
            "{{Blank}} The damage down will slowly wear off as you clear rooms",
        },
    },
    [mod.COLLECTIBLE_CARAMEL_APPLE] = {
        Name = "Caramel Apple",
        Description = {
            "\1 +1 Health",
            "\1 Picking up a heart has a 33% chance to give an additional unit of the same heart type, if possible",
        },
        --[[  exampel
        DescriptionAppend = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_ISAAC)
                end,
                DescriptionToAdd = {
                    "\1 Test Any Player Is Isaac (ADD TO BOTTOM)",
                },
            },
            {
                AddToTop=true,
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_SAD_ONION)
                end,
                DescriptionToAdd = {
                    "\1 Test Any Player Has Sad Onion (ADD TO TOP)",
                },
            },
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_ISAAC)
                end,
                TextToModify = {
                    {--↑
                        Old = "\1 %+1 Health",
                        New = "{{ColorLime}}+20000 health (this is green bc player is isaac){{CR}}"
                    }
                },
            },
        },
        --]]
    },
    [mod.COLLECTIBLE_PAINKILLERS] = {
        Name = "Painkillers",
        Description = {
            "\1 Taking damage delays it with a 1 second timer which resets every time you take damage",
            "\2 While this timer is active, you have no immunity frames and all damage taken is added to a counter",
            "When the time is up, you take an amount of damage proportional to the damage counter",
            "\1 x1.25 Damage"
        },
    },
    [mod.COLLECTIBLE_TECH_IX] = {
        Name = "Tech IX",
        Description = {
            "While firing, you get a {{Collectible395}} Tech X ring around you",
            "This ring grows in size as you fire, and slowly shrinks while not firing"
        },
    },
    [mod.COLLECTIBLE_MAMMONS_OFFERING] = {
        Name = "Mammon's Offering",
        Description = {
            "On death, enemies have a 1/3 chance to spawn a special obol worth 3 coins",
            "\2 On pickup, obols grant a small damage down",
            "\1 On new floors, all obols that weren't picked up grant a damage up",
            "!!! Obols can't be picked up by Bums or Ultra Greed",
        },
    },
    [mod.COLLECTIBLE_PAINT_BUCKET] = {
        Name = "Paint Bucket",
        Description = {
            " ",
        },
    },
    [mod.COLLECTIBLE_FATAL_SIGNAL] = {
        Name = "Fatal Signal",
        Description = {
            "\1 +1 Health",
            "Gives a passive {{Collectible721}} glitched item on pickup"
        },
    },
    [mod.COLLECTIBLE_PEPPER_X] = {
        Name = "Pepper X",
        Description = {
            "9% chance to shoot a meteor tear that spawns fire upon contact",
            "{{Luck}} 50% chance at 13 luck",
            "The fire deals contact damage and blocks shots, disappears after 5 seconds",
        },
    },
    [mod.COLLECTIBLE_METEOR_SHOWER] = {
        Name = "Meteor Shower",
        Description = {
            "In active rooms, every 4 seconds spawns a meteor that falls from the sky",
            "When landing, it spawns a fire and a cross stream of fire jets",
            "The fire deals contact damage and blocks shots, disappears after 4 seconds",
        },
    },
    [mod.COLLECTIBLE_BLESSED_RING] = {
        Name = "Blessed Ring",
        Description = {
            "In active rooms, every 7 seconds spawns a beam of light at the position of 3 random enemies which loosely follow them around",
            "After a short delay, the light beams turn into a divine smite that deals 7 total damage",
        },
    },
    [mod.COLLECTIBLE_4_4] = {
        Name = "4 4",
        Description = {
            "Double tap to shoot out a spread of spectral piercing sound waves that confuse enemies",
            "1% chance to inflict non-boss enemies with Overflow",
            "{{Luck}} 10% chance at 100 luck",
            "{{ToyboxOverflowingStatus}} Overflow makes enemies have no AI and slide around with no friction",
        },
    },
    [mod.COLLECTIBLE_EYESTRAIN] = {
        Name = "Eyestrain",
        Description = {
            "\1 +0.75 Luck",
            "\1 +1 Damage",
        },
    },
    [mod.COLLECTIBLE_SCATTERED_TOME] = {
        Name = "Scattered Tome",
        Description = {
            "Slow orbital that occasionally fires out a paper tear that targets the nearest enemy",
            "The paper tear deals 5 damage",
        },
    },
    [mod.COLLECTIBLE_MALICIOUS_BRAIN] = {
        Name = "Malicious Brain",
        Description = {
            "Gives an orbital brain familiar",
            "Slowly charges up in active rooms, when fully charged double-tap to release his rage, firing powerful lasers at enemies for a few seconds",
            "\1 In boss rooms, gives a temporary fading 1.5x damage multiplier",
        },
    },
    [mod.COLLECTIBLE_SIGIL_OF_GREED] = {
        Name = "Sigil of Greed",
        Description = {
            "{{Chargeable}} Firing for 6.66 seconds charges up a golden sigil",
            "Upon release, the sigil expands and deals 66.6 damage to all nearby enemies",
            "{{Collectible202}} 25% chance for the sigil to petrify enemies and turn them to gold for 2 seconds",
            "{{Coin}} Killing a golden enemy spawns coins"
        },
    },
    [mod.COLLECTIBLE_OBSIDIAN_SHARD] = {
        Name = "Obsidian Shard",
        Description = {
            "Tinted rocks are colored purple, making them easier to see",
            "Tinted rocks drop an assortment of \"evil\" pickups",
            "{{BleedingOut}} 7.5% chance to shoot tears that inflict bleeding",
            "{{Luck}} 20% chance at 18 luck"
        },
    },
    [mod.COLLECTIBLE_OBSIDIAN_CHUNK] = {
        Name = "Obsidian Chunk",
        Description = {
            "\1 +0.75 Damage",
            "\2 -0.2 Shotspeed",
            "{{BlackHeart}} +1 Black Heart",
            "5% chance to shoot a hunk of obsidian that deals 2x damage, along with a few smaller chunks that deal 2 damage each",
            "{{Luck}} 20% chance at 25 luck"
        },
    },
    --#endregion

    --#region --!ACTIVES
    [mod.COLLECTIBLE_PLIERS] = {
        Name = "Pliers",
        Description = {
            "\1 +0.7 Tears for the room",
            "!!! Deals half a heart of damage to Isaac",
            "{{Heart}} Removes Red Hearts first",
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "+0.7 Tears",
                        New = "+0.7/{{Collectible356}}{{BlinkYellowGreen}}+1.0{{CR}} Tears"
                    },
                },
            },
        },
    },
    [mod.COLLECTIBLE_BLOOD_RITUAL] = {
        Name = "Blood Ritual",
        Description = {
            "Spawns 3 {{DevilChanceSmall}} evil familiars for the room that orbit around you",
            "Additional uses in a room only spawn 1 familiar",
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "Spawns 3",
                        New = "Spawns 3/{{Collectible356}}{{BlinkYellowGreen}}5{{CR}}"
                    },
                    {
                        Old = "spawn 1",
                        New = "spawn 1/{{Collectible356}}{{BlinkYellowGreen}}2{{CR}}"
                    },
                },
            },
        },
    },
    [mod.COLLECTIBLE_SILK_BAG] = {
        Name = "Silk Bag",
        Description = {
            "\1 Gives 0.5 seconds of invincibility",
            "!!! Has a limited number of uses, at 0 uses the item gets removed",
            "Starts with 8 uses, gets 4 uses every floor (up to 8)"
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "0.5 seconds",
                        New = "0.5/{{Collectible356}}{{BlinkYellowGreen}}1{{CR}} second(s)"
                    },
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_9_VOLT)
                end,
                TextToModify = {
                    {
                        Old = "4 uses every floor",
                        New = "4/{{Collectible116}}{{BlinkYellowGreen}}5{{CR}} uses every floor"
                    },
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "up to 8",
                        New = "up to 8/{{Collectible63}}{{BlinkYellowGreen}}12{{CR}}"
                    },
                },
            },
        },
    },
    [mod.COLLECTIBLE_TOY_GUN] = {
        Name = "Toy Gun",
        Description = {
            "When used, fires a foam bullet in the chosen direction that deals 15 damage",
            "Can be used as long as it has bullets in the magazine, which reloads a bullet every 10 seconds, up to 5",
            "Trinkets have a 20% chance to be replaced by {{Trinket"..mod.TRINKET_FOAM_BULLET.."}}Foam Bullets, which are automatically smelted",
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "fires a foam bullet",
                        New = "fires 1 bullet/{{Collectible356}}{{BlinkYellowGreen}}3 inaccurate{{CR}} bullets"
                    },
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_9_VOLT)
                end,
                TextToModify = {
                    {
                        Old = "every 10 seconds",
                        New = "every 10/{{Collectible116}}{{BlinkYellowGreen}}5{{CR}} seconds"
                    },
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "up to 5",
                        New = "up to 5/{{Collectible63}}{{BlinkYellowGreen}}10{{CR}}"
                    },
                },
            },
        },
    },
    [mod.COLLECTIBLE_GOLDEN_TWEEZERS] = {
        Name = "Golden Tweezers",
        Description = {
            "{{Coin}} +5 coins",
            "\1 Pay 5 {{Coin}} coins and get +0.7 Tears for the room",
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "+0.7 Tears",
                        New = "+0.7/{{Collectible356}}{{BlinkYellowGreen}}+1.0{{CR}} Tears"
                    },
                },
            },
        },
    },
    --#endregion
}
local EXTRA_ITEM_MODIFIERS = {
    { --! ATLAS
        --* special condition to apply to all of them
        [0] = {
            BaseCondition = function(descObj)
                return mod:isAnyPlayerAtlasA()
            end,
            Icon = "{{Player"..mod.PLAYER_ATLAS_A.."}}",
            Color = "{{ColorSilver}}",
        },
        [CollectibleType.COLLECTIBLE_YUM_HEART] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "+1 Rock mantle",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_YUCK_HEART] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "+1 Poop mantle",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_PRAYER_CARD] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "+1 Holy mantle",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_GUPPYS_PAW] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Your leftmost mantle is destroyed and replaced with a Metal mantle that has 1 HP",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_CONVERTER] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Your leftmost mantle is destroyed and replaced with a random mantle",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_SATANIC_BIBLE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "+1 Dark mantle",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_THE_NAIL] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "+1 Dark mantle",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "+1 Metal mantle",
                    },
                },
            },
        },
    },
    { --! LIMIT BREAK
        [0] = {
            BaseCondition = function(descObj)
                return mod.anyPlayerHasLimitBreak()
            end,
            Icon = "{{Trinket"..mod.TRINKET_LIMIT_BREAK.."}}",
            Color = "{{ColorToyboxLimitBreak}}",
        },
        [CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Troll bombs spawned deal no damage to the player",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_ANARCHIST_COOKBOOK] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Troll bombs spawned deal no damage to the player",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_LITTLE_CHAD] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Spawns a {{Heart}} full Red Heart instead",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_THE_WIZ] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Reduced spread",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BOOM] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Megatroll bombs devolve into normal troll bombs",
                        "Troll bombs have a 15% chance to become duds and never explode",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_KAMIKAZE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "The explosion inherits your bomb modifiers",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_SHADE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Shade has a chance to {{Fear}} Fear enemies it hits",
                        "When killing an enemy, Shade has a chance to spawn a friendly black charger for the rest of the room",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_THE_JAR] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "When used with 4 full hearts inside it, consume the hearts and get a filled heart container",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_OBSESSED_FAN] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Has a chance to {{Charm}} Charm enemies it hits",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_MISSING_PAGE_2] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Using active items has a chance to trigger {{Collectible35}} Necronomicon",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BUM_FRIEND] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Picked up coins have doubled value",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BUMBO] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Picked up coins have doubled value",
                    },
                },
            },
        },
    },
    { --! JONAS
        [0] = {
            BaseCondition = function(descObj)
                return PlayerManager.AnyoneIsPlayerType(mod.PLAYER_JONAS_A)
            end,
            Icon = "{{Player"..mod.PLAYER_JONAS_A.."}}",
            Color = "{{ColorJonas}}",
        },
        [CollectibleType.COLLECTIBLE_URANUS] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Frozen enemies can only drop pills when shattered",
                    },
                },
            },
        },
    },
}

local TRINKETS = {
    [mod.TRINKET_PLASMA_GLOBE] = {
        Name = "Plasma Globe",
        Description = {
            "On new rooms, enemies have a 15% chance to be electrified for 4 seconds",
            "{{Luck}} 50% chance at 20 luck",
            "{{ToyboxElectrifiedStatus}} Electrified makes enemies arc weak electricity beams in random directions, hurting them in the process",
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "4 seconds",
                        New = "{{ColorYellow}}6{{CR}} seconds",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "4 seconds",
                        New = "{{ColorRainbow}}9{{CR}} seconds",
                    },
                },
            },
        },
    },
    [mod.TRINKET_FOAM_BULLET] = {
        Name = "Foam Bullet",
        Description = {
            "When you deal damage, 2.5% chance to double the damage",
            "{{Luck}} 50% chance at 30 luck",
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "2.5%% chance",
                        New = "{{ColorYellow}}5%%{{CR}} chance",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "2.5%% chance",
                        New = "{{ColorRainbow}}7.5%%{{CR}} chance",
                    },
                },
            },
        },
        DescriptionAppend = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_TOY_GUN)
                end,
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_TOY_GUN.."}} Trinket is automatically smelted",
                    "{{Collectible"..mod.COLLECTIBLE_TOY_GUN.."}} +1 Toy Gun magazine size",
                    "{{Collectible"..mod.COLLECTIBLE_TOY_GUN.."}} +1.5 Toy Gun bullet damage",
                },
            },
        },
    },
    [mod.TRINKET_LIMIT_BREAK] = {
        Name = "LIMIT BREAK",
        Description = {
            "\1 Certain \"bad\" items are buffed",
        },
    },
}
--! for double and triple
local EXTRA_TRINKET_MODIFIERS = {}

local CARDS = {
    [mod.CONSUMABLE_MANTLE_ROCK] = {
        Name = "Rock Mantle",
        Description = {
            "2 HP",
            "Does nothing",
            "{{AtlasATransformationRock}} {{ColorGray}}Transformation{{CR}}",
            "No effect",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_POOP] = {
        Name = "Poop Mantle",
        Description = {
            "2 HP",
            "Chance to spawn 2 blue flies on room clear",
            "{{AtlasATransformationPoop}} {{ColorGray}}Transformation{{CR}}",
            "Destroying poops heals you",
            "Poops have a higher chance to drop pickups",
            "Poops drop pickups from a better pool that includes {{Key}} keys, {{Bomb}} bombs, {{Card}}{{Pill}} consumables and {{Trinket}} trinkets",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_BONE] = {
        Name = "Bone Mantle",
        Description = {
            "\1 3 HP",
            "Killing enemies has a chance to spawn a bone orbital",
            "{{AtlasATransformationBone}} {{ColorGray}}Transformation{{CR}}",
            "Shoot out a circle of bone tears when damaged",
            "You can heal by touching hearts",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_DARK] = {
        Name = "Dark Mantle",
        Description = {
            "2 HP",
            "\1 x1.1 damage up",
            "{{AtlasATransformationDark}} {{ColorGray}}Transformation{{CR}}",
            "Upon losing a mantle, all enemies take 60 damage",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_HOLY] = {
        Name = "Holy Mantle",
        Description = {
            "2 HP",
            "\1 +0.5 range up",
            "Chance to fire a {{Collectible182}} Sacred Heart shot when firing",
            "{{AtlasATransformationHoly}} {{ColorGray}}Transformation{{CR}}",
            "Flight",
            "Spectral tears",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_SALT] = {
        Name = "Salt Mantle",
        Description = {
            "2 HP",
            "\1 +0.33 tears up",
            "{{AtlasATransformationSalt}} {{ColorGray}}Transformation{{CR}}",
            "Press the DROP key to toggle \"auto-targetting\"",
            "\"Auto-targetting\" makes your shots fire towards the nearest enemy",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_GLASS] = {
        Name = "Glass Mantle",
        Description = {
            "\2 1 HP",
            "\1 x1.16 damage up",
            "\1 +0.1 shotspeed up",
            "!!! Losing a glass mantle destroys all glass mantles",
            "{{AtlasATransformationGlass}} {{ColorGray}}Transformation{{CR}}",
            "\1 x1.5 damage up",
            "!!! Losing a mantle destroys all mantles",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_METAL] = {
        Name = "Metal Mantle",
        Description = {
            "\1 3 HP",
            "\2 -0.1 speed down",
            "6.6% chance to block damage",
            "{{AtlasATransformationMetal}} {{ColorGray}}Transformation{{CR}}",
            "Fixed 25% chance to block damage",
            "Spike damage is always blocked",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_GOLD] = {
        Name = "Gold Mantle",
        Description = {
            "2 HP",
            "\1 +0.5 luck up",
            "{{AtlasATransformationGold}} {{ColorGray}}Transformation{{CR}}",
            "Gives effect of {{Collectible429}} Head of the Keeper",
            "Touching an enemy turns it to gold",
            "Losing a mantle turns all nearby enemies to gold",
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
}
--! for tarot cloth
local EXTRA_CARD_MODIFIERS = {}

local PILLS = {
    [mod.PILL_DYSLEXIA] = {
        Name = "Dsylxeia",
        Description = {
            "{{Timer}} You fire backwards for 30 seconds"
        },
    },
    [mod.PILL_I_BELIEVE] = {
        Name = "I Believe I Can Fly!",
        Description = {
            "{{Timer}} Flight for the room"
        },
    },
    [mod.PILL_DEMENTIA] = {
        Name = "Dementia",
        Description = {
            "Rerolls the current pill pool"
        }
    },
    [mod.PILL_PARASITE] = {
        Name = "Parasite!",
        Description = {
            "Spawns 1 blue fly for every enemy in the room, along with 2 additional blue flies"
        }
    },
    [mod.PILL_OSSIFICATION] = {
        Name = "Ossification",
        Description = {
            "Turns 1 heart container into an {{EmptyBoneHeart}} empty bone heart"
        }
    },
    [mod.PILL_YOUR_SOUL_IS_MINE] = {
        Name = "Your Soul is Mine",
        Description = {
            "Turns all of your Soul Hearts into {{BlackHeart}} Black Hearts",
            "If you have no Soul Hearts, gives 1 {{BlackHeart}} Black Heart"
        }
    },
    [mod.PILL_FOOD_POISONING] = {
        Name = "Food Poisoning",
        Description = {
            "Spawns a poisonous cloud at your position",
            "The cloud hurts you if you stand in it for too long",
        }
    },
    [mod.PILL_CAPSULE] = {
        Name = "Capsule",
        Description = {
            "Gives a random smelted trinket",
        }
    },
    [mod.PILL_HEARTBURN] = {
        Name = "Heartburn",
        Description = {
            "{{Timer}} Reduces all healing by half a heart for the room",
        }
    },
    [mod.PILL_COAGULANT] = {
        Name = "Coagulant",
        Description = {
            "The next hit you take is reduced by half a heart",
        }
    },
    [mod.PILL_FENT] = {
        Name = "Fent",
        Description = {
            "{{Collectible582}} Uses Wavy Cap once",
            "{{Timer}} For the next 10 seconds, you are invincible and have a 0.7x damage multiplier"
        }
    },
    [mod.PILL_ARTHRITIS] = {
        Name = "Arthritis",
        Description = {
            "{{Timer}} For the next 10 seconds, you gain a 3x tears multiplier but you can only fire in 1 direction",
        }
    },
    [mod.PILL_MUSCLE_ATROPHY] = {
        Name = "Muscle Atrophy",
        Description = {
            "\2 Your damage is lowered to 0.5 and slowly recovers over the next 18 seconds",
        }
    },
    [mod.PILL_VITAMINS] = {
        Name = "Vitamins!",
        Description = {
            "{{Timer}} Gives temporary stats that fade over the next 24 seconds:",
            "{{Blank}} \7 +0.3 speed",
            "{{Blank}} \7 +1 range",
            "{{Blank}} \7 +0.3 shotspeed",
        }
    },
    [mod.PILL_DMG_UP] = {
        Name = "Damage Up",
        Description = {
            "+0.45 damage",
        }
    },
    [mod.PILL_DMG_DOWN] = {
        Name = "Damage Down",
        Description = {
            "-0.35 damage",
        }
    },
}
--! for horse pills
local EXTRA_PILL_MODIFIERS = {
    { --! HORSE
        [0] = {
            BaseCondition = function(descObj)
                return (descObj.ObjSubType & PillColor.PILL_GIANT_FLAG ~= 0)
            end,
            Icon = "{{ToyboxHorsePill}}",
            Color = "{{ColorToyboxHorsePill}}",
        },
        [mod.PILL_DYSLEXIA] = {
            DescriptionModifiers = {
                {
                    TextToModify = {
                        {
                            Old = "backwards",
                            New = "{{ColorToyboxHorsePill}}in random directions{{CR}}"
                        }
                    },
                },
            },
        },
        [mod.PILL_I_BELIEVE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Invincibility for 7 seconds",
                    },
                },
            },
        },
        [mod.PILL_DEMENTIA] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Unidentifies all pills",
                        "The resulting pill pool doesn't contain any neutral effects"
                    },
                },
            },
        },
        [mod.PILL_PARASITE] = {
            DescriptionModifiers = {
                {
                    TextToModify = {
                        {
                            Old = "1 blue fly",
                            New = "{{ColorToyboxHorsePill}}2{{CR}} blue flies"
                        }
                    },
                },
            },
        },
        [mod.PILL_OSSIFICATION] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Turns all of your heart containers into {{EmptyBoneHeart}} empty bone hearts",
                    },
                },
            },
        },
        [mod.PILL_YOUR_SOUL_IS_MINE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "+1 {{BlackHeart}} Black Heart",
                        "For every Soul Heart converted, spawns a {{Collectible576}} friendly black dip"
                    },
                },
            },
        },
        [mod.PILL_FOOD_POISONING] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "The poisonous cloud is larger and lasts for the rest of the room",
                        "Spawns a puddle of green creep that hurts enemies"
                    },
                },
            },
        },
        [mod.PILL_CAPSULE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "The trinket is golden",
                    },
                },
            },
        },
        [mod.PILL_HEARTBURN] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "You cannot gain any health or heart containers this room",
                    },
                },
            },
        },
        [mod.PILL_COAGULANT] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "The next time you take damage, gain 3 seconds of invincibility",
                    },
                },
            },
            DescriptionModifiers = {
                {
                    TextToModify = {
                        {
                            Old = "reduced by half a heart",
                            New = "{{ColorToyboxHorsePill}}completely negated{{CR}}"
                        }
                    },
                },
            },
        },
        [mod.PILL_FENT] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Negates the damage multiplier",
                    },
                },
            },
            DescriptionModifiers = {
                {
                    TextToModify = {
                        {
                            Old = "once",
                            New = "{{ColorToyboxHorsePill}}twice{{CR}}"
                        }
                    },
                },
            },
        },
        [mod.PILL_ARTHRITIS] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Also get +1.5 damage",
                    },
                },
            },
        },
        [mod.PILL_MUSCLE_ATROPHY] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Permanent -0.1 damage",
                    },
                },
            },
            DescriptionModifiers = {
                {
                    TextToModify = {
                        {
                            Old = "18 seconds",
                            New = "{{ColorToyboxHorsePill}}27{{CR}} seconds"
                        }
                    },
                },
            },
        },
        [mod.PILL_VITAMINS] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Additionally gives a temporary +1 damage",
                    },
                },
            },
            DescriptionModifiers = {
                {
                    TextToModify = {
                        {
                            Old = "+0.3 speed",
                            New = "{{ColorToyboxHorsePill}}+0.45{{CR}} speed"
                        },
                        {
                            Old = "+1 range",
                            New = "{{ColorToyboxHorsePill}}+1.5{{CR}} range"
                        },
                        {
                            Old = "+0.3 shotspeed",
                            New = "{{ColorToyboxHorsePill}}+0.45{{CR}} shotspeed"
                        },
                    },
                },
            },
        },
        [mod.PILL_DMG_UP] = {
            DescriptionModifiers = {
                {
                    TextToModify = {
                        {
                            Old = "+0.45 damage",
                            New = "{{ColorToyboxHorsePill}}+0.9{{CR}} damage"
                        },
                    },
                },
            },
        },
        [mod.PILL_DMG_DOWN] = {
            DescriptionModifiers = {
                {
                    TextToModify = {
                        {
                            Old = "-0.35 damage",
                            New = "{{ColorToyboxHorsePill}}-0.7{{CR}} damage"
                        },
                    },
                },
            },
        },
    },
    { --! PLACEBO
        [0] = {
            BaseCondition = function(descObj)
                return (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_PLACEBO))
            end,
            Icon = "{{Collectible348}}",
            Color = "{{ColorSilver}}",
        },
        [mod.PILL_DYSLEXIA] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "6 charges",
                    },
                },
            },
        },
        [mod.PILL_I_BELIEVE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "3 charges",
                    },
                },
            },
        },
        [mod.PILL_DEMENTIA] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "3 charges",
                    },
                },
            },
        },
        [mod.PILL_PARASITE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "2 charges",
                    },
                },
            },
        },
        [mod.PILL_OSSIFICATION] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "4 charges",
                    },
                },
            },
        },
        [mod.PILL_YOUR_SOUL_IS_MINE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "6 charges",
                    },
                },
            },
        },
        [mod.PILL_FOOD_POISONING] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "3 charges",
                    },
                },
            },
        },
        [mod.PILL_CAPSULE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "12 charges",
                    },
                },
            },
        },
        [mod.PILL_HEARTBURN] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "4 charges",
                    },
                },
            },
        },
        [mod.PILL_COAGULANT] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "12 charges",
                    },
                },
            },
        },
        [mod.PILL_FENT] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "6 charges",
                    },
                },
            },
        },
        [mod.PILL_ARTHRITIS] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "4 charges",
                    },
                },
            },
        },
        [mod.PILL_MUSCLE_ATROPHY] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "3 charges",
                    },
                },
            },
        },
        [mod.PILL_VITAMINS] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "6 charges",
                    },
                },
            },
        },
        [mod.PILL_DMG_UP] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "6 charges",
                    },
                },
            },
        },
        [mod.PILL_DMG_DOWN] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "4 charges",
                    },
                },
            },
        },
    },
}

local PLAYERS = {
    [mod.PLAYER_ATLAS_A] = {
        Name="Atlas",
        Description = {
            "Your health is replaced by mantles which have a chance to spawn instead of hearts",
            "Each mantle type has different effects, having 3 mantles of the same type gives you a unique effect until you get 3 mantles of a different type or lose all mantles",
            "Losing all of your mantles turns you into Tar with temporarily increased stats until you recover at least 1 mantle",
        },
        Birthright = {
            "You can now have 2 mantle transformations at once",
            "When you lose a transformation, it gets transferred into the second transformation slot where it functions alongside the current transformation",
            "Turning into {{AtlasATransformationTar}}Tar form removes both transformations",
        },
    },
    [mod.PLAYER_ATLAS_A_TAR] = {
        Name="Atlas",
        Description = {
            "Your health is replaced by mantles which have a chance to spawn instead of hearts",
            "Each mantle type has different effects, having 3 mantles of the same type gives you a unique effect until you get 3 mantles of a different type or lose all mantles",
            "Losing all of your mantles turns you into Tar with temporarily increased stats until you recover at least 1 mantle",
        },
        Birthright = {
            "You can now have 2 mantle transformations at once",
            "When you lose a transformation, it gets transferred into the second transformation slot where it functions alongside the current transformation",
            "Turning into {{AtlasATransformationTar}}Tar form removes both transformations",
        },
    },
    [mod.PLAYER_JONAS_A] = {
        Name="Jonas",
        Description = {
            "Enemies may drop pills on death",
            "Using a pill grants a small all stats up with diminishing returns",
            "The stat bonus from pills is reset if you clear too many rooms without using a pill",
            "You lose 2/3rds of the stat bonus at the start every floor",
            "Pill pool gets rerolled and unidentified at the start of every floor",
        },
        Birthright = {
            "{{Pill}} Bad and neutral pills become good pills",
            "{{ToyboxGoldenPill}} Spawns a Golden Pill",
        },
    },
}

return {
    ["ITEMS"] = ITEMS,
    ["TRINKETS"] = TRINKETS,
    ["CARDS"] = CARDS,
    ["PILLS"] = PILLS,

    ["EXTRA_ITEM_MODIFIERS"] = EXTRA_ITEM_MODIFIERS,
    ["EXTRA_TRINKET_MODIFIERS"] = EXTRA_TRINKET_MODIFIERS,
    ["EXTRA_CARD_MODIFIERS"] = EXTRA_CARD_MODIFIERS,
    ["EXTRA_PILL_MODIFIERS"] = EXTRA_PILL_MODIFIERS,

    ["PLAYERS"] = PLAYERS,
}