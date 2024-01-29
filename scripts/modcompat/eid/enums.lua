local mod = MilcomMOD

local ITEMS = {
    -- add descs for bloody needle, condensed milk, goat milk and slickwater lol
    [mod.COLLECTIBLE_NOSE_CANDY] = {
        Name = "Nose Candy",
        Description = {
            "\1 Every floor, you get +0.2 speed",
            "{{Blank}}  \7 If this bonus would make your speed higher than 2, the overflowing speed becomes a bonus to a non-speed stat",
            "\1 Every floor, you get a small stat-up to a non-speed stat",
            "\2 Every floor, you get a small stat-down to a non-speed stat",
        },
    }
}

local TRINKETS = {}

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