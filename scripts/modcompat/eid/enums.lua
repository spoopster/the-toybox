local mod = MilcomMOD

local ITEMS = {
    --PASSIVES
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
            "\2 x1.15 Firedelay",
            "\2 x0.85 Damage",
            "\1 While shooting, your tears and damage stats gradually increase",
            "The stat increase has diminishing returns",
            "The stat increase rapidly goes down while not shooting",
        },
        DescriptionAppend = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_LILITH)
                end,
                DescriptionToAdd = {
                    "{{Player13}} Lilith's Incubus gives a small increase to stats while firing",
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_LILITH_B)
                end,
                DescriptionToAdd = {
                    "{{Player32}} Tainted Lilith's Gello gives a small increase to stats while firing",
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_INCUBUS)
                end,
                DescriptionToAdd = {
                    "{{Collectible360}} Incubus gives a small increase to stats while firing",
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_TWISTED_PAIR)
                end,
                DescriptionToAdd = {
                    "{{Collectible698}} Twisted Pair babies give a small increase to stats while firing",
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_GELLO)
                end,
                DescriptionToAdd = {
                    "{{Collectible728}} Gello gives a small increase to stats while firing",
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
            "\1 Picking up a heart has a 25% chance to give an additional unit of the same heart type, if possible",
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

    --ACTIVES
    [mod.COLLECTIBLE_BLOODY_NEEDLE] = {
        Name = "Bloody Needle",
        Description = {
            "\1 +0.5 Tears for the room",
            "!!! Deals half a heart of damage to Isaac",
            "{{Heart}} Removes Red Hearts first"
        },
    },
    [mod.COLLECTIBLE_BLOOD_RITUAL] = {
        Name = "Blood Ritual",
        Description = {
            "Spawns 3 {{DevilChanceSmall}} evil familiars for the room that orbit around you",
            "Additional uses in a room only spawn 1 familiar",
        },
    },
    [mod.COLLECTIBLE_SILK_BAG] = {
        Name = "Silk Bag",
        Description = {
            "\1 Gives 0.5 seconds of invincibility",
            "!!! Has a limited number of uses, at 0 uses the item gets removed",
            "Starts with 8 uses, gets 4 every floor (up to 8)"
        },
    },
}

local TRINKETS = {
    [mod.TRINKET_PLASMA_GLOBE] = {
        Name = "Plasma Globe",
        Description = {
            "On new rooms, enemies have a 15% chance to be electrified",
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
            "Chance to block damage",
            "{{AtlasATransformationMetal}} {{ColorGray}}Transformation{{CR}}",
            "Fixed 40% chance to block damage",
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

return {
    ["ITEMS"] = ITEMS,
    ["TRINKETS"] = TRINKETS,
    ["CARDS"] = CARDS,
}