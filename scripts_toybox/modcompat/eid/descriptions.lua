
local enums = require("scripts_toybox.modcompat.eid.stored")

--- ITEMS ---

enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_COCONUT_OIL,
    Name = "Coconut Oil",
    Description = {
        "\1 +0.5 Tears",
        "\2 -0.25 Speed",
        "Your friction is decreased, effectively increasing your movespeed",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CONDENSED_MILK,
    Name = "Condensed Milk",
    Description = {
        "\1 x1.2 Tears",
        "Your {{Damage}} damage cannot go above or below 3.5, instead all damage modifiers get funneled into your {{Tears}} tears",
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_LIBRA)
            end,
            ToModify = {
                "{{Collectible304}} Stats are distributed more towards tears and not at all towards damage",
            },
        },
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_ROCK_BOTTOM)
            end,
            ToModify = {
                "{{Collectible562}} Damage remains unchangeable",
            },
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GOAT_MILK,
    Name = "Goat Milk",
    Description = {
        "\1 +0.5 Tears",
        "Everytime you fire, your fire delay is randomized",
    },
    StackModifiers = {
        {
            ToModify = {
                "Fire delay randomization is more extreme",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_NOSE_CANDY,
    Name = "Nose Candy",
    Description = {
        "At the start of every floor:",
        "\1 +0.2 Speed",
        "\1 Increase to a random non-Speed stat",
        "\2 Decrease to a random non-Speed stat",
    },
    StackModifiers = {
        {
            ToModify = {
                "All stat increases/decreases from this item are amplified",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_LION_SKULL,
    Name = "Lion Skull",
    Description = {
        "\1 +0.15 Damage on room clear",
        "\2 On hit, -0.15 Damage for each room cleared since the last time you got hit",
        "The damage down will wear off as you clear rooms",
    },
    StackModifiers = {
        {
            ToModify = {
                "+/-0.15 Damage granted per stack",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CARAMEL_APPLE,
    Name = "Caramel Apple",
    Description = {
        "\1 +1 Health",
        "{{HalfHeart}} Turns half Red Hearts and half Soul Hearts into their full counterparts",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PAINKILLERS,
    Name = "Painkillers",
    Description = {
        "\2 Invincibility frames after taking damage are 90% shorter",
        "\1 15% chance to block damage and get 2.5 seconds of invincibility",
        "{{Luck}} 50% chance at 30 luck",
    },
    StackModifiers = {
        {
            ToModify = {
                "Invincibility frames are completely removed",
                "+10% block chance for every copy of the item, maximum chance is capped at 50%",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_TECH_IX,
    Name = "Laser Brain",
    Description = {
        "While firing, you get a green laser ring around you",
        "The ring slowly grows in size and damage as you fire, and dissipates when you stop firing",
    },
    StackModifiers = {
        {
            ToModify = {
                "+50% laser damage",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_FATAL_SIGNAL,
    Name = "Fatal Signal",
    Description = {
        "\1 +1 Health",
        "{{SoulHeart}} +1 Soul Heart",
        "Items that modify your Red, Soul or Black Hearts are rerolled",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PEPPER_X,
    Name = "Pepper X",
    Description = {
        "5% chance to shoot out a spectral stream of flames that block enemy shots and deal contact damage",
        "{{Luck}} 50% chance at 20 luck",
        "The stream of flames lasts for 1 second and can be controlled by shooting/movement inputs",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_METEOR_SHOWER,
    Name = "Meteor Shower",
    Description = {
        "In active rooms, every 2-4 seconds a meteor falls from the sky",
        "{{Burning}} When landing, the meteor explodes, dealing 35 damage and burning nearby enemies",
        "!!! The meteors can also hurt you",
    },
    StackModifiers = {
        {
            ToModify = {
                "Meteors fall more often",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BLESSED_RING,
    Name = "Blessed Ring",
    Description = {
        "In active rooms, every 7 seconds 2 random enemies are struck by a beam of light",
    },
    StackModifiers = {
        {
            ToModify = {
                "Spawns beams twice as fast",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_4_4,
    Name = "4 4",
    Description = {
        "\1 +0.5 Tears",
        "{{Confusion}} While firing, nearby enemies are Confused",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_EYESTRAIN,
    Name = "Eyestrain",
    Description = {
        "\1 +0.7 Tears",
        "\1 +1 Luck",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_SIGIL_OF_GREED,
    Name = "Sigil of Greed",
    Description = {
        "{{Chargeable}} Firing for 6.66 seconds charges up a golden sigil",
        "Upon release, the sigil expands and deals 66.6 damage to all nearby enemies",
        "{{Collectible202}} 25% chance for the sigil to petrify enemies and turn them to gold for 2 seconds",
        "{{Coin}} Killing a golden enemy spawns coins"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_EVIL_ROCK,
    Name = "Evil Rock",
    Description = {
        "Tinted rocks are darker and easier to see",
        "Drops from tinted rocks are changed:",
        "{{SoulHeart}} Soul Hearts > Black Hearts",
        "{{Key}} Keys > Troll Bombs/Pills",
        "{{Chest}} Chests > Red Chests",
        "{{Collectible90}} The Small Rock > {{ColorYellow}}???{{CR}}",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ONYX,
    Name = "Onyx",
    Description = {
        "\1 +1.2 Damage",
        "\1 +0.5 Tears",
        "\1 +0.2 Speed",
        "{{BlackHeart}} +1 Black Heart",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_DADS_PRESCRIPTION,
    Name = "Dad's Prescription",
    Description = {
        "{{Pill}} Entering a special room spawns a pill",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_HORSE_TRANQUILIZER,
    Name = "Horse Tranquilizer",
    Description = {
        enums.CONSTANTS.Icon_HorsePill .. " Spawns a horse pill",
        "Picking up an item uses a random horse pill",
        "Higher quality items make you use worse pills",
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_SILK_BAG,
    Name = "Silk Bag",
    Description = {
        "{{SoulHeart}} +1 Soul Heart",
        "Doubles invincibility frames",
        "Converts invincibility frames into a protective shield"
    },
    StackModifiers = {
        {
            ToModify = {
                "Further increases invincibility frames",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ROCK_CANDY,
    Name = "Rock Candy",
    Description = {
        "\1 +0.7 Damage",
        "\1 +0.16 Shotspeed",
        enums.CONSTANTS.Icon_CardMantleRock .. " Spawns a random Mantle consumable",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_MISSING_PAGE_3,
    Name = "Missing Page 3",
    Description = {
        "{{DeathMark}} Enemies have a 4% chance to spawn as a Skull champion",
        --"{{Blank}} {{ColorGray}}Skull champions have 2x health and trigger {{Collectible35}} The Necronomicon effect on death{{CR}}",
        "{{BlackHeart}} Skull champions are guaranteed to drop a black heart on death",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = function(descObj)
                return Game():IsHardMode()
            end,
            ToModify = {
                {"are guaranteed", "have a 33%% chance"}
            }
        }
    },
    StackModifiers = {
        {
            ToModify = {
                "+4% chance for Skull champions to spawn for every item stack",
                "Skull champions spawned by this item don't have increased health",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GLASS_VESSEL,
    Name = "Glass Vessel",
    Description = {
        "Grants a glass shield that negates one hit",
        "{{Heart}} When the shield is broken, you can recharge it by picking up a red heart, which will consume the heart in the process",
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
            end,
            ToModify = {
                "{{Collectible"..CollectibleType.COLLECTIBLE_HOLY_MANTLE.."}} This blocks damage before Holy Mantle",
            }
        },
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER) or PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER_B)
            end,
            ToModify = {
                "{{Player14}} With coin health, picking up a coin recharges the shield",
            }
        },
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BONE_BOY,
    Name = "Bone Boy",
    Description = {
        "{{DeathMark}} Grants a Bony familiar that loves to party!",
        "He chases nearby enemies and throws bones at them",
        "He blocks projectiles and can die after 5 hits, turning into an immobile pile of bones that revives after 15 seconds"
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD)
            end,
            ToModify = {
                "{{Collectible545}} On use, Book of the Dead revives any dead Bony familiars",
            },
        },
        {
            Condition = function(descObj)
                return false--PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_HALLOWED_GROUND)
            end,
            ToModify = {
                "{{Collectible543}} When the Bony enters a Hallowed Ground aura, it levels up, gaining more HP and firing arced bones that leave behind flames on impact",
                "{{Collectible543}} On death, the Bony levels back down into a normal bony",
            },
        },
    },
    BFFSModifiers = {
        {
            ToModify = {
                "Grants a Black Bony that fires a barrage of 3 bones less frequently",
                "On death, the Black Bony creates an explosion that can't hurt you"
            },
        },
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_STEEL_SOUL,
    Name = "Steel Soul",
    Description = {
        "{{SoulHeart}} +1 Soul Heart",
        "Any full Soul/Black Hearts gained have a metal shield that can block 1 additional damage",
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BOBS_HEART,
    Name = "Bob's Heart",
    Description = {
        "Grants immunity to explosions",
        "Taking damage spawns a cloud of poisonous gas and makes you explode",
        "The explosion inherits bomb effects"
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CLOWN_PHD,
    Name = "Clown PHD",
    Description = {
        "{{Pill}} When used, pills have a random effect",
        "Converts negative pills into positive ones",
        "Pills can no longer be identified",
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GIANT_CAPSULE,
    Name = "Giant Capsule",
    Description = {
        "Using a consumable spawns a virus familiar that lasts 60 seconds",
        "Viruses follow you and shoot tears with different effects based on their color",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_LOVE_LETTER,
    Name = "Love Letter",
    Description = {
        "{{Charm}} 10% chance to shoot charming tears",
        "Charmed enemies take 50% more damage",
        "Charmed enemies and their projectiles cannot damage you",
    },
    StackModifiers = {
        {
            ToModify = {
                "+25% extra damage to charmed enemies",
                "+5% chance to charm enemies",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_QUAKE_BOMBS,
    Name = "Quake Bombs",
    Description = {
        "{{Bomb}} +5 Bombs",
        "Bombs explode additional connected rocks up to 3 tiles away",
        "Rocks destroyed by your bombs have doubled drops"
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ATHEISM,
    Name = "Atheism",
    Description = {
        "{{AngelDevilChance}} +15% Devil/Angel deal chance",
        "{{AngelDevilChance}} Devil/Angel deals are replaced by {{TreasureRoom}} Treasure rooms which contain a choice between 2 items",
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return (Game().Difficulty==Difficulty.DIFFICULTY_GREED or Game().Difficulty==Difficulty.DIFFICULTY_GREEDIER)
            end,
            ToModify = {
                "{{GreedMode}} In Greed Mode, replaces deals with {{GreedTreasureRoom}} Silver Treasure rooms",
            },
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_MAYONAISE,
    Name = "A Spoonful of Mayonnaise",
    Description = {
        "\1 +0.15 Shotspeed",
        "{{EternalHeart}} +1 Eternal Heart",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_AWESOME_FRUIT,
    Name = "Awesome Fruit",
    Description = {
        "\1 +1 Health",
        "{{HealingRed}} Heals 1 heart",
        "\1 +1 progress for all Transformations",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_JONAS_MASK,
    Name = "Jonas' Mask",
    Description = {
        "Gives 1 of 3 shadow familiars:",
        "{{Blank}} \7 Fly that bounces around the room and screams at enemies",
        "{{Blank}} \7 Spider that crawls around and pounces on enemies",
        "{{Blank}} \7 Urchin that orbits you and blocks projectiles",
        "Every floor the familiar is rerolled"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_SALTPETER,
    Name = "Saltpeter",
    Description = {
        "\1 +1.5 Range",
        "When enemies take damage, nearby enemies take 50% of that damage",
        "The radius of this effect scales with your range"
    },
    StackModifiers = {
        {
            ToModify = {
                "+50% AOE damage",
            },
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_DR_BUM,
    Name = "Dr. Bum",
    Description = {
        "{{Card}} Picks up cards, runes, and objects and turns them into {{Pill}} pills",
        "Pills spawned by this are more likely to be positive or neutral"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PLASMA_GLOBE,
    Name = "Plasma Globe",
    Description = {
        "\2 -0.2 Shotspeed",
        "While flying, your tears fire electric lasers at nearby enemies",
        "The lasers deal 25% of the tear's damage",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CURSED_EULOGY,
    Name = "Cursed Eulogy",
    Description = {
        "{{BlackHeart}} +1 Black Heart",
        "\2 Items have a 20% chance to spawn as a Curse Room or Red Chest item",
    },
    StackModifiers = {
        {
            ToModify = {
                "+20% chance to replace items",
            },
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BLESSED_BOMBS,
    Name = "Blessed Bombs",
    Description = {
        "{{Bomb}} +5 Bombs",
        "Bombs take twice as long to explode",
        "While fused, bombs have a holy aura that grants:",
        "\1 x3 Tears",
        "\1 x2 Damage",
        "Homing tears",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_HEMORRHAGE,
    Name = "Haemorrhage",
    Description = {
        "{{EmptyBoneHeart}} +1 Bone Heart",
        "{{EmptyBoneHeart}} When a heart container is emptied, removes it and grants a Bone Heart",
        "Taking damage gives a large fading tears up",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_FISH,
    Name = "Fish",
    Description = {
        "\1 Doubles all blue fly/spider spawns",
        "Taking damage spawns 1 blue fly and blue spider",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BOBS_THESIS,
    Name = "Bob's Thesis",
    Description = {
        "All item spawns are replaced by {{Collectible"..ToyboxMod.COLLECTIBLE_PLACEHOLDER.."}} Placeholder",
        --"{{Blank}} {{ColorGray}}Placeholder gives an all stats up, but turns into a random item at the start of next floor{{CR}}",
        "Placeholder gives an all stats up, but turns into a random item at the start of next floor",
    },
    StackModifiers = {
        {
            ToModify = {
                "Placeholder's stat-ups are doubled",
                "Placeholder gives better items",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PLACEHOLDER,
    Name = "Placeholder",
    Description = {
        "\1 +0.15 Speed",
        "\1 +0.5 Tears",
        "\1 +0.5 Damage",
        "\1 +1 Range",
        "\1 +0.1 Shotspeed",
        "\1 +1 Luck",
        "At the start of next floor, will turn into an item from the ITEMPOOL pool"
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = function(descObj)
                local lastPool = Game():GetItemPool():GetLastPool()
                local poolName = EID:getDescriptionEntry("itemPoolNames")[lastPool]
                local poolIcon = (EID.ItemPoolTypeToMarkup[lastPool] or "{{ItemPoolTreasure}}")

                return string.gsub(descObj.Description, "ITEMPOOL", poolIcon.." {{ColorSilver}}"..poolName.."{{CR}}")
            end
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PLIERS,
    Name = "Pliers",
    Description = {
        "\1 +0.7 Tears for the room",
        "!!! Deals half a heart of damage to Isaac",
        "{{Heart}} Removes Red Hearts first",
    },
    CarBatteryModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"+0.7 Tears", "+1 Tears"},
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BLOOD_RITUAL,
    Name = "Blood Ritual",
    Description = {
        "Spawns 3 {{DevilChanceSmall}} evil familiars for the room that orbit around you",
        "Additional uses in a room only spawn 1 familiar",
    },
    CarBatteryModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"3 {{DevilChanceSmall}} evil familiars", "5 {{DevilChanceSmall}} evil familiars"},
                {"1 familiar", "2 familiars"},
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_SUNK_COSTS,
    Name = "Sunk Costs",
    Description = {
        "{{Coin}} +5 coins",
        "\1 Pay 5 {{Coin}} coins and get +0.7 Tears for the room",
    },
    CarBatteryModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"+0.7 Tears", "+1 Tears"},
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ASCENSION,
    Name = "Ascension",
    Description = {
        "{{Timer}} For the next 3 seconds: gain flight and spectral tears",
        "When time is up, get teleported back to where you used the item and gain 1 second of invincibility",
        "You can end the effect early by using the item again"
    },
    CarBatteryModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"3 seconds", "6 seconds"},
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GILDED_APPLE,
    Name = "Gilded Apple",
    Description = {
        "{{GoldenHeart}} +1 Golden Heart",
    },
    CarBatteryModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"+1 Golden Heart", "+2 Golden Hearts"},
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PEZ_DISPENSER,
    Name = "Candy Dispenser",
    Description = {
        "{{Card}} Can store up to 3 consumables of any type",
        "Swap between stored consumables by pressing the Drop key ({{ButtonRT}})",
        "When activated, puts the selected stored consumable into your consumable slot",
        
        --"Hold the Map key ({{ButtonSelect}}) to see the frontmost stored consumable's name"
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
            end,
            ToModify = {
                "{{Collectible63}} {{BlinkYellowGreen}}Can store an extra consumable{{CR}}",
            }
        },
    },
    CarBatteryModifiers = {
        {
            ToModify = {
                "Can store an extra consumable",
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ALPHABET_BOX,
    Name = "Alphabet Box",
    Description = {
        "Rerolls all items in the room into the next item in alphabetical order",
    },
    CarBatteryModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"next item", "second next item"},
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_HOSTILE_TAKEOVER,
    Name = "Hostile Takeover",
    Description = {
        "{{Timer}} For the room:",
        "Gives stats that wear off over 10 seconds:",
        "{{Blank}} \1 +0.2 Speed",
        "{{Blank}} \1 +2 Damage",
        "{{Blank}} \1 +1 Tears",
        "On death, enemies spawn puddles of slowing tar",
        "Touching a puddle absorbs it and extends the temporary stats"
    },
    CarBatteryModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"+0.2", "+0.3"},
                {"+2", "+3"},
                {"+1", "+1.5"},
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BLOODY_WHISTLE,
    Name = "Bloody Whistle",
    Description = {
        "Spawns a pool of blood creep",
        "The creep deals 21 damage per second",
        "The creep spawns blood tears that deal 7 damage"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_D,
    Name = "D0",
    Description = {
        "{{Timer}} Adds anywhere from +3 minutes to -3 minutes to the game's timer",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ASTEROID_BELT,
    Name = "Asteroid Belt",
    Description = {
        "Gain 8 orbital rocks that block projectiles and deal 1 damage",
        "Killing an enemy grants another rocks",
        "Clearing a room gives 5 rocks",
        "Can have up to 20 rocks orbiting you",
    },
    StackModifiers = {
        {
            ToModify = {
                "Can have 20 more rocks orbiting you"
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BARBED_WIRE,
    Name = "Barbed Wire",
    Description = {
        "When a projectile gets near you, the enemy who fired it takes 5 damage",
    },
    StackModifiers = {
        {
            ToModify = {
                "+5 damage dealt"
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_COFFEE_CUP,
    Name = "Coffee Cup",
    Description = {
        "\1 +0.2 Speed",
        "\1 +0.5 Tears",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_LAST_BEER,
    Name = "Beer Can",
    Description = {
        "{{Timer}} +10% chance to fire an additional tear for each enemy killed in the room",
        "Guaranteed after 10 kills"
    },
    StackModifiers = {
        {
            ToModify = {
                "+1 additional tear fired"
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS,
    Name = "Conjunctivitis",
    Description = {
        "\1 +0.5 Damage for the right eye",
        "\2 -0.2 Shotspeed for the right eye",
        "{{Poison}} Tears from right eye have a 25% chance to inflict poison"
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect"
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_FOOD_STAMPS,
    Name = "Food Stamps",
    Description = {
        "{{Heart}} All future Boss Room items give +1 Health",
        "{{HealingRed}} All future items fully heal you",
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect"
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GOLDEN_CALF,
    Name = "Golden Calf",
    Description = {
        "{{Charm}} On death, enemies have a 10% chance to respawn as a friendly copy with halved health",
        "Works on bosses at a much lower chance"
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect"
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ART_OF_WAR,
    Name = "Art of War",
    Description = {
        "{{Timer}} Grants a random tear replacement item for the room",
        "Picks items from the following list:"
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return true
            end,
            ToModify = function(descObj)
                local s = "{{Blank}} "
                for _, item in ipairs(ToyboxMod.TEAR_REPLACEMENT_ITEMS) do
                    s = s.."{{Collectible"..item[1].."}} "
                end

                return s
            end,
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BIG_BANG,
    Name = "Big Bang",
    Description = {
        "!!! SINGLE USE !!!",
        "Resets all item pools",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CHOCOLATE_BAR,
    Name = "Chocolate Bar",
    Description = {
        "{{Timer}} +1 Health for the room",
        "Heals friendly enemies for 30 HP"
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return (Game():GetNumPlayers()>1)
            end,
            ToModify = {
                "Heals other players for half a heart",
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_RETROFALL,
    Name = "RETROFALL",
    Description = {
        "{{Collectible105}} All non-timed active items have 6 charges and trigger the effect of The D6",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = function(descObj)
                return ToyboxMod.CONFIG.SUPER_RETROFALL_BROS
            end,
            ToModify = function(descObj)
                local selId = ToyboxMod:getExtraData("SUPER_RETROFALL_ID") or 3
                local data = ToyboxMod.SUPER_RETROFALL_DICE[selId]

                descObj.Description = string.gsub(descObj.Description, "{{Collectible105}}", "{{Collectible"..data.ID.."}}")
                descObj.Description = string.gsub(descObj.Description, "6 charges", data.Charges.." charges")
                descObj.Description = string.gsub(descObj.Description, "The D6", data.Name)

                return descObj.Description
            end
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BRUNCH,
    Name = "Brunch",
    Description = {
        "\1 +1 Heart container",
        "{{RottenHeart}} +1 Rotten Heart",
        "Gives 1 green locust",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_TOAST,
    Name = "Toast",
    Description = {
        "\1 +1 Health",
        "{{HealingRed}} Heals 1 heart",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)
            end,
            ToModify = {
                {"1 heart", "{{BlinkGreen}}2{{CR}} hearts"}
            }
        },
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)
            end,
            ToModify = {
                "{{Collectible664}} \1 +0.5 Tears",
                "{{Collectible664}} \1 +1 Damage",
                "{{Collectible664}} \1 Temporary +3.6 damage",
                "{{Collectible664}} \2 -0.03 Speed",
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_DELIVERY_BOX,
    Name = "Delivery Box",
    Description = {
        "{{Coin}} Pay 3 coins to spawn a {{Bomb}} Bomb or {{Key}} Key",
        "The pickup you have less of is more common",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_LUCKY_PEBBLES,
    Name = "Lucky Pebbles",
    Description = {
        "\1 +1 Health",
        "{{HealingRed}} Heals 1 heart",
        "\1 +1 Luck"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_MOMS_PHOTOBOOK,
    Name = "Mom's Photobook",
    Description = {
        "{{Confusion}} Confuses all enemies in the room for 5 seconds",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_FINGER_TRAP,
    Name = "Finger Trap",
    Description = {
        "\1 +0.7 Damage",
        "\2 -0.16 Shotspeed",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_HEMOLYMPH,
    Name = "Hemolymph",
    Description = {
        "If you have full health, you may pick up Red Hearts to:",
        "{{SoulHeart}} Replenish half Soul/Black Hearts",
        "{{HalfSoulHeart}} Get a half Soul Heart, if you have no Soul/Black Hearts"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_SOLAR_PANEL,
    Name = "Solar Panel",
    Description = {
        "\1 +0.16 Speed",
        "{{Battery}} Entering a non-hostile room for the first time adds 1 active charge",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_SURPRISE_EGG,
    Name = "Surprise Egg",
    Description = {
        "\1 +1 Health",
        "{{Pill}} Forces you to eat a Capsule, and adds it to the pill pool",
        "Capsule grants a random smelted trinket"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_COLOSSAL_ORB,
    Name = "Colossal Orb",
    Description = {
        "{{HealingRed}} +1 Health",
        "\1 +1 Damage",
        "\2 -0.2 Speed",
        "Size up",
        "{{Confusion}} On room entry, all enemies are confused for 4 seconds"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BABY_SHOES,
    Name = "Baby Shoes",
    Description = {
        "\1 +0.2 Speed",
        "+0.5 Speed if room is clear",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_SACK_OF_CHESTS,
    Name = "Sack of Chests",
    Description = {
        "{{Chest}} Spawns a random chest every 9-10 rooms",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_EFFIGY,
    Name = "Effigy",
    Description = {
        "On room entry, tries to turn into a champion copy of a random enemy in the room",
        "Champions spawned by this have a 50% chance of dropping a random pickup when killed"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GAMBLING_ADDICTION,
    Name = "Gambling Addiction",
    Description = {
        "Upon killing an enemy, 25% chance to spawn one of the following:",
        "Nothing",
        "{{Coin}} 1-3 coins",
        "{{Key}} 1 key",
        "{{Bomb}} 1 bomb",
        "{{Heart}} 1-2 hearts",
        "{{Pill}} 1 pill",
        "1-2 blue flies",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PYRAMID_SCHEME,
    Name = "Pyramid Scheme",
    Description = {
        "{{TreasureRoom}} In Treasure Rooms, a special donation machine will spawn",
        "Donating has a 7.5% chance to explode it and drop 1-3 Coins",
        "{{Coin}} Exploding it manually makes it drop 2x the Coins donated to it"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP,
    Name = "Pythagoras' Cup",
    Description = {
        "!!! SINGLE USE !!!",
        "Gives a cup that makes item pedestals cycle through 3 choices",
        "Picking up more than 3 items on the same floor makes the cup spill, removing itself and all items picked up after using this"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE,
    Name = "Pythagoras' Cup",
    Description = {
        "Gives a cup that makes item pedestals cycle through 3 choices",
        "Picking up more than 3 items on the same floor makes the cup spill, removing itself and all items picked up after using this"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_DADS_SLIPPER,
    Name = "Dad's Slipper",
    Description = {
        "\1 +0.16 Shotspeed",
        "Non-boss enemies that hurt you are instantly killed",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GOOD_JUICE,
    Name = "The Good Juice",
    Description = {
        enums.CONSTANTS.Icon_Juice .. " Enemies drop Juice on death equal to their max health",
        "You can trade Juice in the starting room for pickups and stats",
        "{{Blank}} {{ColorSilver}}(Hold the {{ButtonSelect}} Map button to view your Juice){{CR}}"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BUTTERFLY_EFFECT,
    Name = "Butterfly Effect",
    Description = {
        "\1 ^1.25 Damage",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BLOODFLOWER,
    Name = "Bloodflower",
    Description = {
        "{{HealingRed}} +1 Health",
        "{{Heart}} Heal 1 Red Heart when total boss HP in the room reaches 50%",
        "{{HalfSoulHeart}} Heal 1 half Soul Heart if health is full"
    },
    StackModifiers = {
        {
            ToModify = {
                "Heal an additional time"
            }
        }
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = function(descObj)
                return (Game():GetNumPlayers()>1)
            end,
            ToModify = {
                {"Heal 1 Red Heart", "All players heal 1 Red Heart"},
                {"Heal 1 half Soul Heart", "Players heal 1 half Soul Heart"}
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_RED_CLOVER,
    Name = "Red Clover",
    Description = {
        "\1 +1 Luck",
        "\1 40% of Luck is added to Damage",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BLACK_SOUL,
    Name = "Black Soul",
    Description = {
        "On hit, spawn a Shadow that follows you on a 0.5 second delay",
        "Can have up to 5 Shadows",
        "Shadows deal 50 damage per second",
        "Shadows disappear on new floor"
    },
    StackModifiers = {
        {
            ToModify = {
                "+1 max Shadow"
            }
        }
    },
    BFFSModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"50 damage", "100 damage"},
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GOOD_JOB,
    Name = "Good Job",
    Description = {
        "{{BossRoom}} Clearing a Boss Room without taking damage gives:",
        "\1 +0.1 Speed",
        "\1 +0.5 Damage",
        "\1 +1 Luck",
        "{{Chest}} A Chest",
    },
    StackModifiers = {
        {
            ToModify = {
                "Stat-ups are 50% better"
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_BIG_RED_BUTTON,
    Name = "Big Red Button",
    Description = {
        "Hold up a throwable Giga Rocket",
        "When the rocket lands:",
        "{{Collectible483}} Deals 100 damage to all enemies in the room",
        "{{Poison}} Fills the room with poison clouds",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_OIL_PAINTING,
    Name = "Oil Painting",
    Description = {
        "!!! SINGLE USE !!!",
        "{{Coin}} Gives Coins equal to its value",
        "Adds 0-4 Coins to value on every room clear"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_READING_GLASSES,
    Name = "Reading Glasses",
    Description = {
        "{{Pill}} Spawns a pill",
        "{{Pill}} Pills are always identified",
        "15% chance to replace cards with pills"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_LANGTON_LOOP,
    Name = "Langton Loop",
    Description = {
        "While travelling, tears periodically spawn 2 copies of themselves moving in opposite perpendicular directions",
        "The copies deal 0.75x damage"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ODD_ONION,
    Name = "Odd Onion",
    Description = {
        "\1 +0.7 Damage",
        "Grants the effect of a random \"Tears up\" item every room",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CURIOUS_CARROT,
    Name = "Curious Carrot",
    Description = {
        "\1 +1.5 Range",
        "Every floor, reveals 5 random rooms on the map"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_GARLIC,
    Name = "Garlic Head",
    Description = {
        "\2 -1 Range",
        "\2 x0.9 Range",
        "{{Poison}} Tears gain an aura that poisons enemies",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_WHITE_DAISY,
    Name = "White Daisy",
    Description = {
        "!!! Can only be used 6 times per floor",
        "On use, grants for the room:",
        "{{Blank}} \1 +2 Tears",
        "{{Blank}} \1 +2.5 Damage",
        "{{Blank}} \1 +1.5 Range",
        "{{Blank}} \1 +4 Luck",
        "While held:",
        "{{Blank}} \2 -1 Damage",
        "{{Blank}} \2 -2 Luck",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_MELTED_CANDLE,
    Name = "Melted Candle",
    Description = {
        "Start shooting out a stream of flames that block enemy shots and deal contact damage",
        "The stream lasts for 1 second and can be controlled by shooting/movement inputs",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_DRILL,
    Name = "Drill",
    Description = {
        "When used near a priced item, makes it free and sends you to an extra Challenge room",
        "The number of waves scales with the price of the item",
        "The extra Challenge room will not charge active items or spawn any clear rewards"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_LOOSE_BOWELS,
    Name = "Loose Bowels",
    Description = {
        "\1 +2 Range",
        "Every 5-10 seconds, Isaac farts",
        --"The farts poison enemies and deflect projectiles"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_TAMMYS_TAIL,
    Name = "Tammy's Tail",
    Description = {
        "All rooms are cleared an additional time, doubling rewards and active charges gained",
    },
})

--- OTHER ITEM MODIFIERS ---

enums.FUNCTIONS.AddItem({
    ID = CollectibleType.COLLECTIBLE_URANUS,
    Modifiers = {
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_TYPE.JONAS_A)
            end,
            ToModify = {
                enums.CONSTANTS.Icon_PlayerJonas .. enums.CONSTANTS.Color_Jonas .. "Frozen enemies can only drop pills when shattered{{CR}}",
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = CollectibleType.COLLECTIBLE_CHARM_VAMPIRE,
    Modifiers = {
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_GARLIC)
            end,
            ToModify = {
                "{{Collectible"..ToyboxMod.COLLECTIBLE_GARLIC.."}} Can't heal you!",
            }
        },
    }
})


--- TRINKETS ---

enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_WONDER_DRUG,
    Name = "Wonder Drug",
    Description = {
        enums.CONSTANTS.Icon_GoldenPill .. " Doubles the chance for gold pills to spawn",
        enums.CONSTANTS.Icon_HorsePill .. " Doubles the chance for horse pills to spawn",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"Doubles", "Triples"}
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"Doubles", "Quadruples"}
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_ANTIBIOTICS,
    Name = "Antibiotics",
    Description = {
        "{{Pill}} Using a pill has a 20% chance to use it 2 times",
        "100% chance for unidentified pills",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"2 times", "3 times"}
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"2 times", "4 times"}
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_AMBER_FOSSIL,
    Name = "Amber Fossil",
    Description = {
        "Blue flies have a 33% chance to be converted into a random locust",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"33%%", "67%%"}
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"33%%", "100%%"}
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_SINE_WORM,
    Name = "Sine Worm",
    Description = {
        "\1 +0.4 Tears",
        "\1 +1.5 Range",
        "Your tears gradually slow down and speed back up to normal velocity",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"+0.4", "+0.8"},
                {"+1.5", "+3"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"+0.4", "+1.2"},
                {"+1.5", "+4.5"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_BIG_BLIND,
    Name = "Big Blind",
    Description = {
        "{{Coin}} Every 10 damage dealt to enemies, spawn a coin",
        "The requirement for spawning a coin goes up more and more for every coin spawned",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = function(descObj)
                local mult, color
                if(enums.FUNCTIONS.IsTrinketTripled(descObj)) then
                    color="{{ColorRainbow}}"
                    mult = 3
                elseif(enums.FUNCTIONS.IsTrinketDoubled(descObj)) then
                    color="{{ColorGold}}"
                    mult = 2
                else
                    mult = 1
                end
                --mult = mult+(descObj.Entity and Isaac.GetPlayer():GetTrinketMultiplier(ToyboxMod.TRINKET_BIG_BLIND) or 0)

                local counter = ToyboxMod:getBigBlindDamageRequirement(Isaac.GetPlayer())/mult
                counter = tostring(math.floor(counter))

                local replaceString = (color or "")..counter..(color and "{{CR}}" or "")
                descObj.Description = string.gsub(descObj.Description, "10", replaceString)
                return descObj.Description
            end,
        }
    }
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_JONAS_LOCK,
    Name = "Jonas' Lock",
    Description = {
        "{{Pill}} Using a pill grants a stat bonus equivalent to 50% of a random \"Stat Up\" pill effect",
        "The stat bonuses are only applied while holding this trinket"
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"50%%", "100%%"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"50%%", "150%%"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_BATH_WATER,
    Name = "Bath Water",
    Description = {
        "Familiar that shatters when you take damage and spawns a pool of creep, once per room",
        "The creep deals 24 damage per second",
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_BLACK_RUNE_SHARD,
    Name = "Black Rune Shard",
    Description = {
        "{{Coin}} Blue flies and spiders have a 33% chance to be replaced by a coin",
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return (FiendFolio~=nil)
            end,
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"and spiders", ", spiders, and skuzzes"},
            }
        }
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"33%%", "67%%"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"33%%", "100%%"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_SUPPOSITORY,
    Name = "Suppository",
    Description = {
        "{{Pill}} Poop drops have a 20% chance to be replaced by a pill",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"20%%", "40%%"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"20%%", "60%%"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_DIVIDED_JUSTICE,
    Name = "Divided Justice",
    Description = {
        "Common heart, coin, bomb, and key drops have a 10% chance to be replaced by a Smorgasbord",
        "Smorgasbords give 1 coin, 1 bomb, 1 key, and heal 1 red heart"
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"10%%", "20%%"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"10%%", "30%%"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_KILLSCREEN,
    Name = "Killscreen",
    Description = {
        "Enemies on the right side of the room take 1 damage every 0.5 seconds",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"0.5", "0.33"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"0.5", "0.25"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_MIRROR_SHARD,
    Name = "Mirror Shard",
    Description = {
        "\2 -13 Luck",
        "\1 +1 Luck whenever you take damage"
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"1 ", "1.5 "},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"1 ", "2 "},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_LUCKY_TOOTH,
    Name = "Lucky Tooth",
    Description = {
        "\1 Beggars have a flat +33% chance to payout",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"33%%", "67%%"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"33%%", "100%%"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_HOLY_LENS,
    Name = "Holy Lens",
    Description = {
        "{{Planetarium}} Spawns a Planetarium in Cathedral",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"in Cathedral", "{{ColorWhite}}in Cathedral{{CR}} and Chest"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"in Cathedral", "{{ColorWhite}}in Cathedral{{CR}} and Chest"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_DARK_NEBULA,
    Name = "Dark Nebula",
    Description = {
        "{{Planetarium}} Spawns a Planetarium in Sheol",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"in Sheol", "{{ColorWhite}}in Sheol{{CR}} and Dark Room"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"in Sheol", "{{ColorWhite}}in Sheol{{CR}} and Dark Room"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_MAKEUP_KIT,
    Name = "Make-Up Kit",
    Description = {
        "Donation Machines are replaced with Mom's Dressing Tables",
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_YELLOW_BELT,
    Name = "Yellow Belt",
    Description = {
        "10% chance to negate damage taken",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"10%%", "20%%"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"10%%", "30%%"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_ZAP_CAP,
    Name = "Zap Cap",
    Description = {
        "Every 40th time any enemy takes damage, the enemy who got hit explodes for 6x damage taken + 15",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"40th", "30th"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"40th", "20th"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_MISPRINT,
    Name = "Misprint",
    Description = {
        "{{Collectible}} Picking up an item grants 1 copy of that item for 60 seconds",
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"1 copy", "2 copies"},
                {"60 seconds", "90 seconds"},
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"1 copy", "3 copies"},
                {"60 seconds", "120 seconds"},
            }
        },
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = ToyboxMod.TRINKET_CUTOUT,
    Name = "Cutout",
    Description = {
        "When dropped, becomes a decoy that attracts enemies",
        "The decoy can block shots and take damage, when it takes enough damage it turns back into a trinket"
    },
    DoubleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND,
            ToModify = {
                "The decoy deals 7.5 contact damage per second",
            }
        },
    },
    TripleModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND,
            ToModify = {
                "The decoy deals 15 contact damage per second",
            }
        },
    },
})

enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.PRISMSTONE,
    Name = "Prismstone",
    Description = {
        "{{Rune}} Spawns 3 runes or soul stones",
        "Only 1 can be taken"
    },
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.FOIL_CARD,
    Name = "Foil Card",
    Description = {
        "{{Coin}} Spawns a golden heart, penny, key or bomb",
    },
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.POISON_RAIN,
    Name = "Poison Rain",
    Description = {
        "{{Poison}} All enemies, including bosses, are poisoned for 10 seconds",
        "For the rest of the room, rocks will be randomly destroyed"
    },
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.ALIEN_MIND,
    Name = "Alien Mind",
    Description = {
        "{{Friendly}} Picks 3 random enemies to become friendly and mimic your movements and attacks",
        "Enemies with higher health are more likely to be picked"
    },
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.FOUR_STARRED_LADYBUG,
    Name = "4-Starred Ladybug",
    Description = {
        "{{Petrify}} Champion and boss enemies are petrified for 4 seconds",
        "{{Weakness}} Champion and boss enemies are weakened for the rest of the room",
    },
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.LAUREL,
    Name = "Laurel",
    Description = {
        "Gives 5 seconds of invincibility when used",
    },
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.YANNY,
    Name = "Yanny",
    Description = {
        "Deals 30 damage to all enemies in the room when used",
    },
})

enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_ROCK,
    Name = "Mantle - Rock",
    Description = {
        "{{Timer}} For the room:",
        "Grants {{Collectible592}} Terra",
        "Taking damage fires a shockwave at the enemy who hurt you",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "Does nothing",
                enums.CONSTANTS.Icon_AtlasRock .. " {{ColorGray}}Transformation{{CR}}",
                "No effect",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_POOP,
    Name = "Mantle - Poop",
    Description = {
        "Hold up a throwable poop",
        "When thrown, it leaves liquid poop creep under it as it flies"
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "50% chance to spawn 2 blue flies on room clear",
                "+3.33% chance for rocks to be replaced with poop",
                enums.CONSTANTS.Icon_AtlasPoop .. " {{ColorGray}}Transformation{{CR}}",
                "Destroying poops heals 1 HP to your leftmost damaged mantle",
                "+10% chance to get pickups from poops",
                "Poops can now drop keys, bombs, consumables and batteries",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_BONE,
    Name = "Mantle - Bone",
    Description = {
        "{{Charm}} Spawns a friendly Bony",
        "{{Timer}} For the room, enemies have a 67% chance to spawn an orbital bone shard on death",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "\1 3 HP",
                "+10% chance to spawn a bone orbital on kill",
                "Losing a Bone Mantle spawns a friendly Bony",
                enums.CONSTANTS.Icon_AtlasBone .. " {{ColorGray}}Transformation{{CR}}",
                "Fire bones in a circle around you when damaged",
                "+0.6 Tears for every missing Mantle",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_DARK,
    Name = "Mantle - Dark",
    Description = {
        "Deals 10 damage to all enemies on the floor",
        "{{BlackHeart}} 10% chance for enemies killed by this to drop a Black Heart",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "\1 +0.4 Damage",
                "Losing a Dark Mantle deals 60 damage to all enemies",
                enums.CONSTANTS.Icon_AtlasDark .. " {{ColorGray}}Transformation{{CR}}",
                "Gain a dark aura that gives +0.5 Damage for every enemy inside it",
                "Losing any Mantle deals 60 damage to all enemies"
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_HOLY,
    Name = "Mantle - Holy",
    Description = {
        "{{EternalHeart}} +1 Eternal Heart",
        "{{Timer}} Your tears gain a damaging aura for the room"
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "\1 +0.5 Range",
                "+3.33% chance to fire a {{Collectible182}} Sacred Heart tear",
                enums.CONSTANTS.Icon_AtlasHoly .. " {{ColorGray}}Transformation{{CR}}",
                "Flight",
                "Gain an aura that deals 10 damage per second",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_SALT,
    Name = "Mantle - Salt",
    Description = {
        "{{Timer}} Gives the effect of a random \"Tears Up\" item for the room",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "\1 +0.33 Tears",
                enums.CONSTANTS.Icon_AtlasSalt .. " {{ColorGray}}Transformation{{CR}}",
                "Press the DROP key to enter or leave \"salt statue\" form",
                "While in this form, you have x2.5 Tears but are immobile",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_GLASS,
    Name = "Mantle - Glass",
    Description = {
        "{{Timer}} For the room:",
        "\1 x1.5 Damage",
        "\2 Damage taken is doubled and increased by 1 extra heart"
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "\2 1 HP",
                "\1 +0.5 Damage",
                "\1 +0.1 Shotspeed",
                "!!! Losing a Glass Mantle destroys all other Glass Mantles",
                enums.CONSTANTS.Icon_AtlasGlass .. " {{ColorGray}}Transformation{{CR}}",
                "\1 x1.5 Damage",
                "!!! Taking damage has a 90% chance to destroy all Mantles",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_METAL,
    Name = "Mantle - Metal",
    Description = {
        "{{SoulHeart}} +1 Soul Heart",
        "All of your full Soul/Black Hearts gain a metal shield that blocks 1 damage",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "\1 3 HP",
                "\2 -0.1 Speed",
                "+5% chance to block damage",
                enums.CONSTANTS.Icon_AtlasMetal .. " {{ColorGray}}Transformation{{CR}}",
                "+10% chance to block damage",
                "Spike damage is always blocked",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = ToyboxMod.CONSUMABLE.MANTLE_GOLD,
    Name = "Mantle - Gold",
    Description = {
        "{{Coin}} Removes 1 coin, spawns a random pickup",
        "Only has a 5% chance to be consumed on use",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                enums.CONSTANTS.Icon_AtlasEmpty .. " {{ColorGray}}As other players{{CR}}",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = ToyboxMod.areAllPlayersAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.APPEND_TOP,
            Condition = ToyboxMod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "\1 +1 Luck",
                "Losing a Gold Mantle turns nearby enemies to gold",
                enums.CONSTANTS.Icon_AtlasGold .. " {{ColorGray}}Transformation{{CR}}",
                "Tears have a 5% chance to spawn a penny upon hitting an enemy",
                "Losing any Mantle turns nearby enemies to gold",
            },
        }
    }
})

enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.DYSLEXIA,
    Name = "Dyslexia",
    Description = {
        "{{Timer}} You fire backwards for 30 seconds",
    },
    HorseModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"backwards", "in random directions"},
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.I_BELIEVE,
    Name = "I Believe I Can Fly!",
    Description = {
        "{{Timer}} Flight for the room",
    },
    HorseModifiers = {
        {
            ToModify = {
                "Invincibility for 7 seconds",
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.DEMENTIA,
    Name = "Dementia",
    Description = {
        "Rerolls the current pill pool",
        "Unidentifies all pills",
    },
    HorseModifiers = {
        {
            ToModify = {
                "The resulting pill pool doesn't contain any neutral effects",
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.PARASITE,
    Name = "Parasite!",
    Description = {
        "Spawns 1 blue fly for every enemy in the room, along with 2 additional blue flies",
    },
    HorseModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"1 blue fly", "2 blue flies"},
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.OSSIFICATION,
    Name = "Ossification",
    Description = {
        "Turns 1 heart container into an {{EmptyBoneHeart}} empty bone heart",
    },
    HorseModifiers = {
        {
            ToModify = {
                "Turns all heart containers into empty bone hearts",
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.YOUR_SOUL_IS_MINE,
    Name = "Your Soul is Mine",
    Description = {
        "Turns all of your Soul Hearts into {{BlackHeart}} Black Hearts",
        "If you have no Soul Hearts, gives 1 {{BlackHeart}} Black Heart"
    },
    HorseModifiers = {
        {
            ToModify = {
                "+1 {{BlackHeart}} Black Heart",
                "For every Soul Heart converted, spawns a {{Collectible576}} friendly black dip"
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.FOOD_POISONING,
    Name = "Food Poisoning",
    Description = {
        "Spawns a poisonous cloud at your position",
        "The cloud hurts you if you stand in it for too long",
    },
    HorseModifiers = {
        {
            ToModify = {
                "The poisonous cloud is larger and lasts for the rest of the room",
                "Spawns a puddle of green creep that hurts enemies"
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.CAPSULE,
    Name = "Capsule",
    Description = {
        "Gives a random smelted trinket",
    },
    HorseModifiers = {
        {
            ToModify = {
                "The trinket is golden",
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.HEARTBURN,
    Name = "Heartburn",
    Description = {
        "{{Timer}} You are on fire for the next 30 seconds",
        "{{Burning}} While on fire, take damage every second while standing still"
    },
    HorseModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"second", "0.5 seconds"},
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.COAGULANT,
    Name = "Coagulant",
    Description = {
        "Spawns a blood clot",
    },
    HorseModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"a blood clot", "3 blood clots"},
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.FENT,
    Name = "Fent",
    Description = {
        "{{Collectible582}} Uses Wavy Cap once",
        "{{Timer}} For the next 5 seconds, you are invincible and have a 0.7x damage multiplier"
    },
    HorseModifiers = {
        {
            ToModify = {
                "No negative damage multiplier",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"once", "twice"},
            }
        }
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.ARTHRITIS,
    Name = "Arthritis",
    Description = {
        "{{Timer}} For the next 10 seconds, you gain a 3x tears multiplier but you can only fire in 1 direction",
    },
    HorseModifiers = {
        {
            ToModify = {
                "+1.5 Damage for 10 seconds"
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.MUSCLE_ATROPHY,
    Name = "Muscle Atrophy",
    Description = {
        "\2 Your damage is lowered to 0.5 and slowly recovers over the next 18 seconds",
    },
    HorseModifiers = {
        {
            ToModify = {
                "Permanent -0.1 Damage",
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"18 seconds", "27 seconds"},
            },
        }
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.VITAMINS,
    Name = "Vitamins!",
    Description = {
        "{{Timer}} Gives temporary stats that fade over the next 24 seconds:",
        "{{Blank}} \7 +0.3 speed",
        "{{Blank}} \7 +1 range",
        "{{Blank}} \7 +0.3 shotspeed",
    },
    HorseModifiers = {
        {
            ToModify = {
                "Also gives temporary +1 Damage"
            }
        },
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"+0.3", "+0.45"},
                {"+1", "+1.5"},
                {"+0.3", "+0.45"},
            },
        }
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.DMG_UP,
    Name = "Damage Up",
    Description = {
        "\1 +0.45 Damage",
    },
    HorseModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"+0.45", "+0.9"},
            }
        },
    }
})
enums.FUNCTIONS.AddPill({
    ID = ToyboxMod.PILL_EFFECT.DMG_DOWN,
    Name = "Damage Down",
    Description = {
        "\2 -0.35 Damage",
    },
    HorseModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"-0.35", "-0.7"},
            }
        },
    }
})


enums.FUNCTIONS.AddPlayer({
    ID = ToyboxMod.PLAYER_TYPE.ATLAS_A,
    Name = "Atlas",
    Description = {
        "Your health is made of \"mantles\" with various effects, which may replace hearts",
        "Having 3 of the same mantle grants a unique transformation until you get a different transformation",
        "While you have no mantles: lose your transformation, have slightly better stats, and die when you take damage",
    },
    BirthrightDescription = {
        "You can have 2 mantle transformations at once",
        "When you get a new transformation, your original one moves to a second slot",
        "While at no mantles, lose both transformations",
    }
})
enums.FUNCTIONS.AddPlayer({
    ID = ToyboxMod.PLAYER_TYPE.ATLAS_A_TAR,
    Name = "Atlas",
    Description = {
        "Your health is made of \"mantles\" with various effects, which may replace hearts",
        "Having 3 of the same mantle grants a unique transformation, until you get a different transformation",
        "While you have no mantles: lose your transformation, have slightly better stats, and die when you take damage",
    },
    BirthrightDescription = {
        "You can have 2 mantle transformations at once",
        "When you get a new transformation, your original one moves to a second slot",
        "While at no mantles, lose both transformations",
    }
})
enums.FUNCTIONS.AddPlayer({
    ID = ToyboxMod.PLAYER_TYPE.JONAS_A,
    Name = "Jonas",
    Description = {
        "Enemies may drop pills",
        "Pills give a bonus to all stats",
        "Stat bonus is lost if you go too long without using pills",
        "On new floor, pill pool is rerolled and unidentified, and you lose a fraction of the stat bonus",
    },
    BirthrightDescription = {
        "{{Pill}} Higher chance for enemies to drop a pill",
        "{{Card}} When an enemy drops a pill, 20% chance to turn it into a card/rune",
        "Cards and runes give a stat bonus like pills",
    }
})
enums.FUNCTIONS.AddPlayer({
    ID = ToyboxMod.PLAYER_TYPE.MILCOM_A,
    Name = "Milcom",
    Description = {
        enums.CONSTANTS.Icon_Ink .. " Coins, Bombs and Keys become Ink when gained, and consume Ink when used:",
        "{{Blank}} {{Coin}}=1"..enums.CONSTANTS.Icon_Ink..", {{Bomb}}=4"..enums.CONSTANTS.Icon_Ink..", {{Key}}=7"..enums.CONSTANTS.Icon_Ink,
        "No room clear rewards in normal rooms",
        "Higher champion chance, champions drop 2-6 Ink",
    },
    BirthrightDescription = {
        enums.CONSTANTS.Icon_Ink .. " Bombs cost 3 Ink",
        enums.CONSTANTS.Icon_Ink .. " Keys cost 5 Ink",
    }
})


--- GLOBALS ---

enums.FUNCTIONS.AddGlobalModifier({
    ID = "AlphabetBox",
    Modifiers = {
        {
            Condition = function(descObj)
                if(not descObj.Entity) then return false end
                if(not (descObj.ObjType==5 and descObj.ObjVariant==100)) then return false end
                if((ToyboxMod.CONFIG.ALPHABETBOX_EID_DISPLAYS or 0)<=0) then return false end

                return PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_ALPHABET_BOX)
            end,
            ToModify = function(descObj)
                local boxDesc = "{{Collectible"..ToyboxMod.COLLECTIBLE_ALPHABET_BOX.."}} :"

                local idx = ToyboxMod:getNextAlphabetItem(descObj.ObjSubType, false)
                for i=1, ToyboxMod.CONFIG.ALPHABETBOX_EID_DISPLAYS do
                    if(i~=1) then boxDesc = boxDesc.." -> " end

                    if(idx==-1) then
                        boxDesc = boxDesc.."Item disappears"
                        break
                    else
                        boxDesc = boxDesc.."{{Collectible"..ToyboxMod.ABOX_ITEMS_ALPHABETICAL[idx][2].."}}"
                    end
                    
                    idx = ToyboxMod:getNextAlphabetItem(ToyboxMod.ABOX_ITEMS_ALPHABETICAL[idx][2], false)
                end

                return boxDesc
            end
        }
    }
})
enums.FUNCTIONS.AddGlobalModifier({
    ID = "FoodStamps",
    Modifiers = {
        {
            Condition = function(descObj)
                if(not (descObj.ObjType==5 and descObj.ObjVariant==100)) then return false end
                if(not (Game():GetRoom():GetType()==RoomType.ROOM_BOSS)) then return false end

                return PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_FOOD_STAMPS)
            end,
            ToModify = {
                "{{Collectible"..ToyboxMod.COLLECTIBLE_FOOD_STAMPS.."}} {{Heart}} +1 Health",
            }
        },
        {
            Condition = function(descObj)
                if(not (descObj.ObjType==5 and descObj.ObjVariant==100)) then return false end

                return PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_FOOD_STAMPS)
            end,
            ToModify = {
                "{{Collectible"..ToyboxMod.COLLECTIBLE_FOOD_STAMPS.."}} {{HealingRed}} Full health",
            }
        }
    }
})
enums.FUNCTIONS.AddGlobalModifier({
    ID = "RETROFALL",
    Modifiers = {
        {
            Condition = function(descObj)
                if(not (descObj.ObjType==5 and descObj.ObjVariant==100)) then return false end
                if(not ToyboxMod:canApplyRetrofall(descObj.ObjSubType)) then return false end

                return PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_RETROFALL)
            end,
            ToModify = function(descObj)
                if(ToyboxMod.CONFIG.SUPER_RETROFALL_BROS) then
                    local selId = ToyboxMod:getExtraData("SUPER_RETROFALL_ID") or 3
                    local data = ToyboxMod.SUPER_RETROFALL_DICE[selId]

                    return "{{Collectible"..ToyboxMod.COLLECTIBLE_RETROFALL.."}} Triggers the effect of "..data.Name
                else
                    return "{{Collectible"..ToyboxMod.COLLECTIBLE_RETROFALL.."}} Triggers the effect of The D6"
                end
            end
        }
    }
})

--- JOKES ---

enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CURSED_D6,
    Name = "Cursed D6",
    Description = {
        "{{Quality4}} Can reroll items into Q4",
        "{{Quality0}} but can also reroll into Q0",
        "{{BrokenHeart}} or give a broken heart",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_SUPER_HAMBURGER,
    Name = "Super Hamburger",
    Description = {
        "{{Heart}} +50 Health",
        "\2 -2 Speed",
        "Makes you big and fat",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_URANIUM,
    Name = "Uranium",
    Description = {
        "Nearby rocks are irradiated and will destroy after a short duration",
        "Nearby enemies are poisoned",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_CATHARSIS,
    Name = "Catharsis",
    Description = {
        "\1 +1 Tears",
        "\1 Tears cap is doubled",
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_EQUALIZER,
    Name = "Equalizer",
    Description = {
        "{{Coin}} +3 Coins",
        "{{Bomb}} +1 Bomb",
        "{{Key}} +1 Key",
        "On pickup/on use, chooses a pickup and a stat",
        "You will get a bonus to that stat proportional to how many of that pickup you have, until the next time you use the item"
    },
})
enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_ZERO_GRAVITY,
    Name = "Zero-Gravity",
    Description = {
        "\1 +1.5 Damage",
        "You move on a 2 second delay",
        "Releasing movement buttons makes you instantly teleport to the desired position"
    },
})

enums.FUNCTIONS.AddItem({
    ID = ToyboxMod.COLLECTIBLE_PORTABLE_TELLER,
    Name = "Portable Teller",
    Description = {
        "{{Coin}} Spend 1 coin to display a fortune or a chance to spawn a trinket, card or soul heart",
    },
})