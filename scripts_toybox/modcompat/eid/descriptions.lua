local mod = ToyboxMod
local enums = require("scripts_toybox.modcompat.eid.stored")

--- ITEMS ---

enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.COCONUT_OIL,
    Name = "Coconut Oil",
    Description = {
        "\1 +0.5 Tears",
        "\1 -0.25 Speed",
        "Your friction is increased, effectively increasing your movespeed",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.CONDENSED_MILK,
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
    ID = mod.COLLECTIBLE.GOAT_MILK,
    Name = "Goat Milk",
    Description = {
        "\1 +0.5 tears",
        "Everytime you fire, your firedelay will instead be randomly multiplied by anywhere from x0.45 to x1.35",
    },
    StackModifiers = {
        {
            ToModify = {
                "Firedelay multiplier is more extreme",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.NOSE_CANDY,
    Name = "Nose Candy",
    Description = {
        "\1 Every floor, you get +0.2 speed",
        "{{Blank}}  \7 If this bonus would make your speed higher than 2, the overflowing speed becomes a bonus to a non-speed stat",
        "\1 Every floor, you get a small stat-up to a non-speed stat",
        "\2 Every floor, you get a small stat-down to a non-speed stat",
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
    ID = mod.COLLECTIBLE.LION_SKULL,
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
    ID = mod.COLLECTIBLE.CARAMEL_APPLE,
    Name = "Caramel Apple",
    Description = {
        "\1 +1 Health",
        "\1 Heart spawns have a 25% chance to be doubled",
    },
    StackModifiers = {
        {
            ToModify = {
                "Chance does not increase with multiple copies",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.PAINKILLERS,
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
    ID = mod.COLLECTIBLE.TECH_IX,
    Name = "Tech IX",
    Description = {
        "While firing, you get a {{Collectible395}} Tech X ring around you",
        "This ring grows in size as you fire, and slowly shrinks while not firing",
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
    ID = mod.COLLECTIBLE.FATAL_SIGNAL,
    Name = "Fatal Signal",
    Description = {
        "\1 +1 Health",
        "Gives a passive {{Collectible721}} glitched item on pickup",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.PEPPER_X,
    Name = "Pepper X",
    Description = {
        "9% chance to shoot a meteor tear that spawns fire upon contact",
        "{{Luck}} 50% chance at 13 luck",
        "The fire deals contact damage and blocks shots, disappears after 5 seconds",
    },
    StackModifiers = {
        {
            ToModify = {
                "Fires an additional meteor for every item stack",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.METEOR_SHOWER,
    Name = "Meteor Shower",
    Description = {
        "In active rooms, every 4 seconds spawns a meteor that falls from the sky",
        "When landing, it spawns a fire and a cross stream of fire jets",
        "The fire deals contact damage and blocks shots, disappears after 4 seconds",
    },
    StackModifiers = {
        {
            ToModify = {
                "Spawns an additional meteor for every item stack",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.BLESSED_RING,
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
    ID = mod.COLLECTIBLE.FOUR_FOUR,
    Name = "4 4",
    Description = {
        "Double tap to shoot out a spread of spectral piercing sound waves that confuse enemies, has a 10 second cooldown",
        "1% chance to inflict non-boss enemies with Overflow",
        "{{Luck}} 10% chance at 44 luck",
        "{{ToyboxOverflowingStatus}} Overflow makes enemies have no AI and slide around with no friction",
    },
    StackModifiers = {
        {
            ToModify = {
                "Double tap ability has a 20% shorter cooldown",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.EYESTRAIN,
    Name = "Eyestrain",
    Description = {
        "\1 +1 Damage",
        "\1 +0.75 Luck",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.SIGIL_OF_GREED,
    Name = "Sigil of Greed",
    Description = {
        "{{Chargeable}} Firing for 6.66 seconds charges up a golden sigil",
        "Upon release, the sigil expands and deals 66.6 damage to all nearby enemies",
        "{{Collectible202}} 25% chance for the sigil to petrify enemies and turn them to gold for 2 seconds",
        "{{Coin}} Killing a golden enemy spawns coins"
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.EVIL_ROCK,
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
    ID = mod.COLLECTIBLE.ONYX,
    Name = "Onyx",
    Description = {
        "\1 +1.2 Damage",
        "\1 +0.5 Tears",
        "\1 +0.2 Speed",
        "{{BlackHeart}} +1 Black Heart",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.DADS_PRESCRIPTION,
    Name = "Dad's Prescription",
    Description = {
        "{{Pill}} Entering a special room spawns a pill",
    },
    StackModifiers = {
        {
            ToModify = {
                "+1 pill for every item stack, every 2 pills spawned are instead merged into a single horse pill",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.HORSE_TRANQUILIZER,
    Name = "Horse Tranquilizer",
    Description = {
        "{{ToyboxHorsePill}} Spawns a horse pill",
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
    ID = mod.COLLECTIBLE.SILK_BAG,
    Name = "Silk Bag",
    Description = {
        "{{Card"..mod.CONSUMABLE.LAUREL.."}} Spawns 1 Laurel every 6 rooms",
        "{{Blank}} Laurels give 5 seconds of invincibility when used",
    },
    Modifiers = {
        {
            Condition = function(descObj)
                return (mod:getPersistentData("HAS_SEEN_YANNY")==1)
            end,
            ToModify = {
                "{{Card"..mod.CONSUMABLE.YANNY.."}} 0.1% chance to spawn a Yanny instead of a Laurel",
                "{{Blank}} Yannies deal 30 damage to all enemies in the room when used",
            }
        },
    },
    BFFSModifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            ToModify = {
                {"every 6 rooms", "every 4 rooms"}
            },
        },
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.ROCK_CANDY,
    Name = "Rock Candy",
    Description = {
        "\1 +0.3 Tears",
        "\1 +0.15 Shotspeed",
        "{{Card"..mod.CONSUMABLE.MANTLE_ROCK.."}} Spawns a random Mantle consumable",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.MISSING_PAGE_3,
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
    ID = mod.COLLECTIBLE.GLASS_VESSEL,
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
    ID = mod.COLLECTIBLE.BONE_BOY,
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
    ID = mod.COLLECTIBLE.STEEL_SOUL,
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
    ID = mod.COLLECTIBLE.BOBS_HEART,
    Name = "Bob's Heart",
    Description = {
        "Grants immunity to explosions",
        "Taking damage spawns a cloud of poisonous gas and creep",
        "Taking damage has a 50% chance for Isaac to explode"
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
    ID = mod.COLLECTIBLE.CLOWN_PHD,
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
    ID = mod.COLLECTIBLE.GIANT_CAPSULE,
    Name = "Giant Capsule",
    Description = {
        "Using a consumable spawns a virus orbital that disappears after 40 seconds",
        "Viruses shoot tears with different effects depending on their color",
        "Viruses have different colors based on what type of consumable was used",
    },
    StackModifiers = {
        {
            ToModify = {
                "+1 virus for every item stack",
                "Viruses live for +20 seconds per item stack",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.LOVE_LETTER,
    Name = "Love Letter",
    Description = {
        "{{Charm}} 10% chance to shoot charming tears",
        "Charmed enemies take 33% more damage",
        "Charmed enemies and their projectiles cannot damage you",
    },
    StackModifiers = {
        {
            ToModify = {
                "+16% extra damage to charmed enemies",
                "+5% chance to charm enemies",
            }
        }
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.QUAKE_BOMBS,
    Name = "Quake Bombs",
    Description = {
        "{{Bomb}} +5 Bombs",
        "Bombs explode additional connected rocks up to 2 tiles away",
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
    ID = mod.COLLECTIBLE.ATHEISM,
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
    ID = mod.COLLECTIBLE.MAYONAISE,
    Name = "A Spoonful of Mayonnaise",
    Description = {
        "\1 +0.15 Shotspeed",
        "{{EternalHeart}} +1 Eternal Heart",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.AWESOME_FRUIT,
    Name = "Awesome Fruit",
    Description = {
        "\1 +1 Health",
        "{{HealingRed}} Heals 1 heart",
        "\1 +1 progress for all Transformations",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.JONAS_MASK,
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
    ID = mod.COLLECTIBLE.SALTPETER,
    Name = "Saltpeter",
    Description = {
        "When enemies take damage, nearby enemies are hurt for 50% of that damage",
        "Tears have a 5% chance to explode upon hitting an enemy",
    },
    StackModifiers = {
        {
            ToModify = {
                "+50% AOE damage",
                "+5% chance to explode",
            },
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.DR_BUM,
    Name = "Dr. Bum",
    Description = {
        "{{Card}} Picks up cards, runes, and objects and turns them into {{Pill}} pills",
        "Pills spawned by this are more likely to be positive or neutral"
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.PREFERRED_OPTIONS,
    Name = "Preferred Options",
    Description = {
        "{{BossRoom}} You may choose between 2 items after beating a boss",
        "One of the items will be a duplicate of the last item you took from a boss room",
        --"{{Blank}} {{ColorGray}}Cannot duplicate story items{{CR}}", --# i feel like its kind of obvious
    },
    StackModifiers = {
        {
            ToModify = {
                "Multiple copies have no additional effect",
            },
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.PLASMA_GLOBE,
    Name = "Plasma Globe",
    Description = {
        "\2 -0.2 Shotspeed",
        "While flying, your tears fire electric lasers at nearby enemies",
        "The lasers deal 25% of the tear's damage",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.CURSED_EULOGY,
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
    ID = mod.COLLECTIBLE.BLESSED_BOMBS,
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
    ID = mod.COLLECTIBLE.HEMORRHAGE,
    Name = "Haemorrhage",
    Description = {
        "{{BoneHeart}} +1 empty Bone Heart",
        "Taking damage gives a large fading tears up",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.FISH,
    Name = "Fish",
    Description = {
        "\1 Doubles all blue fly/spider spawns",
        "Taking damage spawns 1 blue fly and blue spider",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.BOBS_THESIS,
    Name = "Bob's Thesis",
    Description = {
        "All item spawns are replaced by {{Collectible"..mod.COLLECTIBLE.PLACEHOLDER.."}} Placeholder",
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
    ID = mod.COLLECTIBLE.PLACEHOLDER,
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
    ID = mod.COLLECTIBLE.PLIERS,
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
    ID = mod.COLLECTIBLE.BLOOD_RITUAL,
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
    ID = mod.COLLECTIBLE.SUNK_COSTS,
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
    ID = mod.COLLECTIBLE.ASCENSION,
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
    ID = mod.COLLECTIBLE.GILDED_APPLE,
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
    ID = mod.COLLECTIBLE.PEZ_DISPENSER,
    Name = "Candy Dispenser",
    Description = {
        "{{Card}} Can store up to 2 consumables of any type",
        "Swap between stored consumables by pressing the Drop key ({{ButtonRT}})",
        "When activated, puts the frontmost stored consumable into your consumable slot",
        
        --"Hold the Map key ({{ButtonSelect}}) to see the frontmost stored consumable's name"
    },
    Modifiers = {
        {
            Condition = enums.CONSTANTS.ModifierCondition.CarBattery,
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
    ID = mod.COLLECTIBLE.ALPHABET_BOX,
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
    ID = mod.COLLECTIBLE.HOSTILE_TAKEOVER,
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
    ID = mod.COLLECTIBLE.BLOODY_WHISTLE,
    Name = "Bloody Whistle",
    Description = {
        "Spawns a pool of blood creep",
        "The creep deals 21 damage per second",
        "The creep spawns blood tears that deal 7 damage"
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.D,
    Name = "D0",
    Description = {
        "{{Timer}} Adds anywhere from +3 minutes to -3 minutes to the game's timer",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.ASTEROID_BELT,
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
    ID = mod.COLLECTIBLE.BARBED_WIRE,
    Name = "Barbed Wire",
    Description = {
        "When a projectile gets near you, the enemy who fired it takes 1.5 damage",
    },
    StackModifiers = {
        {
            ToModify = {
                "+1.5 damage dealt"
            }
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.COFFEE_CUP,
    Name = "Coffee Cup",
    Description = {
        "\1 +0.2 Speed",
        "\1 +0.4 Tears",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.LAST_BEER,
    Name = "Last Beer",
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
    ID = mod.COLLECTIBLE.CONJUNCTIVITIS,
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
    ID = mod.COLLECTIBLE.FOOD_STAMPS,
    Name = "Food Stamps",
    Description = {
        "{{Heart}} All future items give +1 Health",
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
    ID = mod.COLLECTIBLE.GOLDEN_CALF,
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
    ID = mod.COLLECTIBLE.ART_OF_WAR,
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
                for _, item in ipairs(mod.TEAR_REPLACEMENT_ITEMS) do
                    s = s.."{{Collectible"..item[1].."}} "
                end

                return s
            end,
        }
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.BIG_BANG,
    Name = "Big Bang",
    Description = {
        "!!! SINGLE USE !!!",
        "Resets all item pools",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.CHOCOLATE_BAR,
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
    ID = mod.COLLECTIBLE.EXORCISM_KIT,
    Name = "Exorcism Kit",
    Description = {
        "Instantly kills the nearest enemy and all other enemies of the same type and variant",
        "Bosses instead take 40 damage"
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.RETROFALL,
    Name = "RETROFALL",
    Description = {
        "{{Collectible105}} All non-timed active items have 6 charges and reroll pedestal items in the room",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.BRUNCH,
    Name = "Brunch",
    Description = {
        "\1 +1 Health",
        "{{HealingRed}} Heals 2 hearts",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)
            end,
            ToModify = {
                {"2", "{{BlinkGreen}}3{{CR}}"}
            }
        },
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)
            end,
            ToModify = {
                "{{Collectible664}} \1 +2.5 Range",
                "{{Collectible664}} \1 +1 Luck",
                "{{Collectible664}} \1 Temporary +3.6 damage",
                "{{Collectible664}} \2 -0.03 Speed",
            }
        },
    }
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.TOAST,
    Name = "Toast",
    Description = {
        "\1 +1 Empty heart container",
        "{{BlackHeart}} +1 Black Heart",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER)
            end,
            ToModify = {
                {"Empty heart container", "{{BlinkGreen}}Health{{CR}}"}
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
    ID = mod.COLLECTIBLE.DELIVERY_BOX,
    Name = "Delivery Box",
    Description = {
        "{{Coin}} Pay 3 coins to spawn a {{Bomb}} Bomb or {{Key}} Key",
        "The pickup you have less of is more common",
    },
})


--- OTHER ITEM MODIFIERS ---

enums.FUNCTIONS.AddItem({
    ID = CollectibleType.COLLECTIBLE_URANUS,
    Modifiers = {
        {
            Condition = function(descObj)
                return PlayerManager.AnyoneIsPlayerType(mod.PLAYER_TYPE.JONAS_A)
            end,
            ToModify = {
                "{{Player"..mod.PLAYER_TYPE.JONAS_A.."}} {{ColorJonas}}Frozen enemies can only drop pills when shattered{{CR}}",
            }
        },
    }
})


--- TRINKETS ---

enums.FUNCTIONS.AddTrinket({
    ID = mod.TRINKET.WONDER_DRUG,
    Name = "Wonder Drug",
    Description = {
        "{{ToyboxGoldenPill}} Doubles the chance for gold pills to spawn",
        "{{ToyboxHorsePill}} Doubles the chance for horse pills to spawn",
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
    ID = mod.TRINKET.ANTIBIOTICS,
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
    ID = mod.TRINKET.AMBER_FOSSIL,
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
    ID = mod.TRINKET.SINE_WORM,
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
    ID = mod.TRINKET.BIG_BLIND,
    Name = "Big Blind",
    Description = {
        "{{Coin}} Every COUNTER damage dealt to enemies, spawn a coin",
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
                --mult = mult+(descObj.Entity and Isaac.GetPlayer():GetTrinketMultiplier(mod.TRINKET.BIG_BLIND) or 0)

                local counter = mod:getBigBlindDamageRequirement(Isaac.GetPlayer())/mult
                counter = tostring(math.floor(counter))

                local replaceString = (color or "")..counter..(color and "{{CR}}" or "")
                descObj.Description = string.gsub(descObj.Description, "COUNTER", replaceString)
                return descObj.Description
            end,
        }
    }
})
enums.FUNCTIONS.AddTrinket({
    ID = mod.TRINKET.JONAS_LOCK,
    Name = "Jonas' Lock",
    Description = {
        "{{Pill}} Using a pill grants a stat bonus equivalent to 50% of a random \"stat up\" pill's effect",
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
    ID = mod.TRINKET.BATH_WATER,
    Name = "Bath Water",
    Description = {
        "Familiar that shatters when you take damage and spawns a pool of creep, once per room",
        "The creep deals 24 damage per second",
    },
})
enums.FUNCTIONS.AddTrinket({
    ID = mod.TRINKET.BLACK_RUNE_SHARD,
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
    ID = mod.TRINKET.SUPPOSITORY,
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

enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.PRISMSTONE,
    Name = "Prismstone",
    Description = {
        "{{Rune}} Spawns 3 runes or soul stones",
        "Only 1 can be taken"
    },
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.FOIL_CARD,
    Name = "Foil Card",
    Description = {
        "{{Coin}} Spawns a golden heart, penny, key or bomb",
    },
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.LAUREL,
    Name = "Laurel",
    Description = {
        "Gives 5 seconds of invincibility when used",
    },
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.YANNY,
    Name = "Yanny",
    Description = {
        "Deals 30 damage to all enemies in the room when used",
    },
})

enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_ROCK,
    Name = "Rock Mantle",
    Description = {
        "{{Timer}} For the room:",
        "Grants {{Collectible592}} Terra",
        "Taking damage fires a shockwave at the enemy who hurt you",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "Does nothing",
                "{{AtlasATransformationRock}} {{ColorGray}}Transformation{{CR}}",
                "No effect",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_POOP,
    Name = "Poop Mantle",
    Description = {
        "Hold up a throwable poop",
        "When thrown, it leaves liquid poop creep under it as it flies"
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "50% chance to spawn 2 blue flies on room clear",
                "+3.33% chance for rocks to be replaced with poop",
                "{{AtlasATransformationPoop}} {{ColorGray}}Transformation{{CR}}",
                "Destroying poops heals 1 HP to your leftmost damaged mantle",
                "+10% chance to get pickups from poops",
                "Poops can now drop keys, bombs, consumables and batteries",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_BONE,
    Name = "Bone Mantle",
    Description = {
        "{{Charm}} Spawns a friendly Bony",
        "{{Timer}} For the room, enemies have a 67% chance to spawn an orbital bone shard on death",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "\1 3 HP",
                "+10% chance to spawn a bone orbital on kill",
                "Losing a Bone Mantle spawns a friendly Bony",
                "{{AtlasATransformationBone}} {{ColorGray}}Transformation{{CR}}",
                "Fire bones in a circle around you when damaged",
                "+0.6 Tears for every missing Mantle",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_DARK,
    Name = "Dark Mantle",
    Description = {
        "Deals 10 damage to all enemies on the floor",
        "{{BlackHeart}} 10% chance for enemies killed by this to drop a Black Heart",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "\1 +0.4 Damage",
                "Losing a Dark Mantle deals 60 damage to all enemies",
                "{{AtlasATransformationDark}} {{ColorGray}}Transformation{{CR}}",
                "Gain a dark aura that gives +0.5 Damage for every enemy inside it",
                "Losing any Mantle deals 60 damage to all enemies"
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_HOLY,
    Name = "Holy Mantle",
    Description = {
        "{{EternalHeart}} +1 Eternal Heart",
        "{{Timer}} Your tears gain a damaging aura for the room"
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "\1 +0.5 Range",
                "+3.33% chance to fire a {{Collectible182}} Sacred Heart tear",
                "{{AtlasATransformationHoly}} {{ColorGray}}Transformation{{CR}}",
                "Flight",
                "Gain an aura that deals 10 damage per second",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_SALT,
    Name = "Salt Mantle",
    Description = {
        "{{Timer}} Gives the effect of a random \"Tears Up\" item for the room",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "\1 +0.33 Tears",
                "{{AtlasATransformationSalt}} {{ColorGray}}Transformation{{CR}}",
                "Press the DROP key to enter or leave \"salt statue\" form",
                "While in this form, you have x2.5 Tears but are immobile",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_GLASS,
    Name = "Glass Mantle",
    Description = {
        "{{Timer}} For the room:",
        "\1 x1.5 Damage",
        "\2 Damage taken is doubled and increased by 1 extra heart"
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "\2 1 HP",
                "\1 +0.5 Damage",
                "\1 +0.1 Shotspeed",
                "!!! Losing a Glass Mantle destroys all other Glass Mantles",
                "{{AtlasATransformationGlass}} {{ColorGray}}Transformation{{CR}}",
                "\1 x1.5 Damage",
                "!!! Taking damage has a 90% chance to destroy all Mantles",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_METAL,
    Name = "Metal Mantle",
    Description = {
        "{{SoulHeart}} +1 Soul Heart",
        "All of your full Soul/Black Hearts gain a metal shield that blocks 1 damage",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "\1 3 HP",
                "\2 -0.1 Speed",
                "+5% chance to block damage",
                "{{AtlasATransformationMetal}} {{ColorGray}}Transformation{{CR}}",
                "+10% chance to block damage",
                "Spike damage is always blocked",
            },
        }
    }
})
enums.FUNCTIONS.AddCard({
    ID = mod.CONSUMABLE.MANTLE_GOLD,
    Name = "Gold Mantle",
    Description = {
        "{{Coin}} Removes 1 coin, spawns a random pickup",
        "Only has a 5% chance to be consumed on use",
    },
    Modifiers = {
        {
            Type = enums.CONSTANTS.DescriptionModifier.REPLACE,
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = function()
                return ""
            end
        },
        {
            Condition = mod.isAnyPlayerAtlasA,
            ToModify = {
                "2 HP",
                "\1 +1 Luck",
                "Losing a Gold Mantle turns nearby enemies to gold",
                "{{AtlasATransformationGold}} {{ColorGray}}Transformation{{CR}}",
                "Tears have a 5% chance to spawn a penny upon hitting an enemy",
                "Losing any Mantle turns nearby enemies to gold",
            },
        }
    }
})

enums.FUNCTIONS.AddPill({
    ID = mod.PILL_EFFECT.DYSLEXIA,
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
    ID = mod.PILL_EFFECT.I_BELIEVE,
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
    ID = mod.PILL_EFFECT.DEMENTIA,
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
    ID = mod.PILL_EFFECT.PARASITE,
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
    ID = mod.PILL_EFFECT.OSSIFICATION,
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
    ID = mod.PILL_EFFECT.YOUR_SOUL_IS_MINE,
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
    ID = mod.PILL_EFFECT.FOOD_POISONING,
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
    ID = mod.PILL_EFFECT.CAPSULE,
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
    ID = mod.PILL_EFFECT.HEARTBURN,
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
    ID = mod.PILL_EFFECT.COAGULANT,
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
    ID = mod.PILL_EFFECT.FENT,
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
    ID = mod.PILL_EFFECT.ARTHRITIS,
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
    ID = mod.PILL_EFFECT.MUSCLE_ATROPHY,
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
    ID = mod.PILL_EFFECT.VITAMINS,
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
    ID = mod.PILL_EFFECT.DMG_UP,
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
    ID = mod.PILL_EFFECT.DMG_DOWN,
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
    ID = mod.PLAYER_TYPE.ATLAS_A,
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
    ID = mod.PLAYER_TYPE.ATLAS_A_TAR,
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
    ID = mod.PLAYER_TYPE.JONAS_A,
    Name = "Jonas",
    Description = {
        "Pill pool gets rerolled and unidentified at the start of every floor",
        "Enemies may drop pills on death",
        "All stats up proportional to your \"Pill Bonus\"",
        "Gain Pill Bonus by using pills",
        "Lose Pill Bonus on new floor, or if you go too long without using a pill",
    },
    BirthrightDescription = {
        "{{Pill}} Higher chance for enemies to drop a pill",
        "{{Card}} When an enemy drops a pill, 20% chance to turn it into a card/rune",
        "Cards and runes give Pill Bonus",
    }
})
enums.FUNCTIONS.AddPlayer({
    ID = mod.PLAYER_TYPE.MILCOM_A,
    Name = "Milcom",
    Description = {
        "{{Coin}} Bombs and keys instead give coins when gained, and consume coins when used",
        "No room clear rewards in normal rooms",
        "Higher champion chance, champions drop 2-6 coins"
    },
    BirthrightDescription = {
        "Bombs cost 3 coins to use",
        "Keys cost 5 coins to use",
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
                if((mod.CONFIG.ALPHABETBOX_EID_DISPLAYS or 0)<=0) then return false end

                return PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.ALPHABET_BOX)
            end,
            ToModify = function(descObj)
                local boxDesc = "{{Collectible"..mod.COLLECTIBLE.ALPHABET_BOX.."}} :"

                local idx = mod:getNextAlphabetItem(descObj.ObjSubType, false)
                for i=1, mod.CONFIG.ALPHABETBOX_EID_DISPLAYS do
                    if(i~=1) then boxDesc = boxDesc.." -> " end

                    if(idx==-1) then
                        boxDesc = boxDesc.."Item disappears"
                        break
                    else
                        boxDesc = boxDesc.."{{Collectible"..mod.ABOX_ITEMS_ALPHABETICAL[idx][2].."}}"
                    end
                    
                    idx = mod:getNextAlphabetItem(mod.ABOX_ITEMS_ALPHABETICAL[idx][2], false)
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

                return PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.FOOD_STAMPS)
            end,
            ToModify = {
                "{{Collectible"..mod.COLLECTIBLE.FOOD_STAMPS.."}} {{Heart}} +1 Health",
            }
        }
    }
})
enums.FUNCTIONS.AddGlobalModifier({
    ID = "FoodStamps",
    Modifiers = {
        {
            Condition = function(descObj)
                if(not (descObj.ObjType==5 and descObj.ObjVariant==100)) then return false end
                if(not mod:canApplyRetrofall(descObj.ObjSubType)) then return false end

                return PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.RETROFALL)
            end,
            ToModify = {
                "{{Collectible"..mod.COLLECTIBLE.RETROFALL.."}} Rerolls pedestal items in the room",
            }
        }
    }
})

--- JOKES ---

enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.URANIUM,
    Name = "Uranium",
    Description = {
        "Nearby rocks are irradiated and will destroy after a short duration",
        "Nearby enemies are poisoned",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.CATHARSIS,
    Name = "Catharsis",
    Description = {
        "\1 +1 Tears",
        "\1 Tears cap is doubled",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.EQUALIZER,
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
    ID = mod.COLLECTIBLE.COMPRESSED_DICE,
    Name = "Compressed Dice",
    Description = {
        "Starts a new run with a random character and difficulty",
    },
})
enums.FUNCTIONS.AddItem({
    ID = mod.COLLECTIBLE.PORTABLE_TELLER,
    Name = "Portable Teller",
    Description = {
        "{{Coin}} Spend 1 coin to display a fortune or a chance to spawn a trinket, card or soul heart",
    },
})