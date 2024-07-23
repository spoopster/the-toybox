local mod = MilcomMOD

local function isDoubleTrinketMultiplier(descObj)
    return not(not PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) == not (descObj.ObjSubType>=TrinketType.TRINKET_GOLDEN_FLAG))
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
    [mod.COLLECTIBLE_OBSIDIAN_CHUNK] = {
        Name = "Obsidian Chunk",
        Description = {
            "\1 +0.75 Damage",
            "\2 -0.2 Shotspeed",
            "{{BlackHeart}} +1 Black Heart",
            "5% chance to shoot a hunk of obsidian that deals 2x damage, along with a few smaller chunks that deal 2 damage each",
            "{{Luck}} 20% chance at 50 luck"
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
local EXTRA_ITEM_MODIFERS = {
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
    }
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
            "Using multiple pills grants a stat bonus",
            "Stat bonus is lost on new floor or by clearing rooms without using a pill",
            "Pill pool gets rerolled every floor",
        },
        Birthright = {
            "{{Pill}} Bad and neutral pills become good pills",
            "{{ToyboxGoldenPill}} Spawns a Golden Pill",
        },
    },
}

return {
    ["ITEMS"] = ITEMS,
    ["EXTRA_ITEM_MODIFIERS"] = EXTRA_ITEM_MODIFERS,
    ["TRINKETS"] = TRINKETS,
    ["CARDS"] = CARDS,
    ["PLAYERS"] = PLAYERS,
}