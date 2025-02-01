local mod = MilcomMOD

local function isDoubleTrinketMultiplier(descObj)
    if(PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX)) then return true end
    if((descObj.ObjSubType>=TrinketType.TRINKET_GOLDEN_FLAG)) then return true end
    return false
end
local function isTripleTrinketMultiplier(descObj)
    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) and descObj.ObjSubType>=TrinketType.TRINKET_GOLDEN_FLAG
end
local function getStackFunction(item)
    return function(descObj)
        if(descObj.Entity==nil) then return false end
        return PlayerManager.AnyoneHasCollectible(item) or PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DIPLOPIA)
    end
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
            "\1 +0.5 tears",
            "Everytime you fire, your firedelay will instead be randomly multiplied by anywhere from x0.45 to x1.35",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_GOAT_MILK),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_GOAT_MILK.."}} {{ColorItemStack}}Firedelay multiplier is more extreme{{CR}}",
                },
            },
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
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_NOSE_CANDY),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_NOSE_CANDY.."}} {{ColorItemStack}}All stat increases/decreases from this item are amplified{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_LION_SKULL] = {
        Name = "Lion Skull",
        Description = {
            "\1 +0.15 Damage for every room cleared without taking damage",
            "\2 Getting hit turns the damage up granted by this into a damage down that wears off as you clear rooms",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_LION_SKULL),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_LION_SKULL.."}} {{ColorItemStack}}+0.15 Damage granted per stack{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_CARAMEL_APPLE] = {
        Name = "Caramel Apple",
        Description = {
            "\1 +1 Health",
            "\1 Picking up a heart has a 33% chance to give an additional unit of the same heart type, if possible",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_CARAMEL_APPLE),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_CARAMEL_APPLE.."}} {{ColorItemStack}}Chance does not increase with multiple copies{{CR}}",
                },
            },
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
            "\2 Invincibility frames after taking damage are 90% shorter",
            "\1 15% chance to block damage and get 2.5 seconds of invincibility",
            "{{Luck}} 50% chance at 30 luck",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_PAINKILLERS),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_PAINKILLERS.."}} {{ColorItemStack}}Invincibility frames are completely removed{{CR}}",
                    "{{Collectible"..mod.COLLECTIBLE_PAINKILLERS.."}} {{ColorItemStack}}+10% block chance for every copy of the item, maximum chance is capped at 50%{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_TECH_IX] = {
        Name = "Tech IX",
        Description = {
            "While firing, you get a {{Collectible395}} Tech X ring around you",
            "This ring grows in size as you fire, and slowly shrinks while not firing"
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_TECH_IX),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_TECH_IX.."}} {{ColorItemStack}}Multiple copies have no additional effect{{CR}}",
                },
            },
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
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_PEPPER_X),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_PEPPER_X.."}} {{ColorItemStack}}Fires an additional meteor for every item stack{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_METEOR_SHOWER] = {
        Name = "Meteor Shower",
        Description = {
            "In active rooms, every 4 seconds spawns a meteor that falls from the sky",
            "When landing, it spawns a fire and a cross stream of fire jets",
            "The fire deals contact damage and blocks shots, disappears after 4 seconds",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_METEOR_SHOWER),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_METEOR_SHOWER.."}} {{ColorItemStack}}Spawns an additional meteor for every item stack{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_BLESSED_RING] = {
        Name = "Blessed Ring",
        Description = {
            "In active rooms, every 7 seconds 2 random enemies are struck by a beam of light",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_BLESSED_RING),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_BLESSED_RING.."}} {{ColorItemStack}}Spawns beams twice as fast{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_4_4] = {
        Name = "4 4",
        Description = {
            "Double tap to shoot out a spread of spectral piercing sound waves that confuse enemies, has a 10 second cooldown",
            "1% chance to inflict non-boss enemies with Overflow",
            "{{Luck}} 10% chance at 44 luck",
            "{{ToyboxOverflowingStatus}} Overflow makes enemies have no AI and slide around with no friction",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_4_4),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_4_4.."}} {{ColorItemStack}}Double tap ability has a 20% shorter cooldown{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_EYESTRAIN] = {
        Name = "Eyestrain",
        Description = {
            "\1 +1 Damage",
            "\1 +0.75 Luck",
        },
    },
    --[[
    [mod.COLLECTIBLE_MALICIOUS_BRAIN] = {
        Name = "Malicious Brain",
        Description = {
            "Gives an orbital brain familiar",
            "Slowly charges up in active rooms, when fully charged double-tap to release his rage, firing powerful lasers at enemies for a few seconds",
            "\1 In boss rooms, gives a temporary fading 1.5x damage multiplier",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_MALICIOUS_BRAIN),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_MALICIOUS_BRAIN.."}} {{ColorItemStack}}Multiple copies have no additional effect and do not spawn additional brain orbitals{{CR}}",
                },
            },
            {
                Condition = function()
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BFFS)
                end,
                DescriptionToAdd = {
                    "{{Collectible247}} {{BlinkPink}}When enraged, the brain enters an ethereal state and fires a gigantic rainbow laser at enemies{{CR}}",
                },
            },
        },
    },
    --]]
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
    [mod.COLLECTIBLE_DADS_PRESCRIPTION] = {
        Name = "Dad's Prescription",
        Description = {
            "{{Pill}} Entering a special room spawns a pill",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_DADS_PRESCRIPTION),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_DADS_PRESCRIPTION.."}} {{ColorItemStack}}+1 pill for every item stack, every 2 pills spawned are instead merged into a single horse pill{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_HORSE_TRANQUILIZER] = {
        Name = "Horse Tranquilizer",
        Description = {
            "{{ToyboxHorsePill}} Spawns a horse pill",
            "Picking up an item uses a random horse pill",
            "Higher quality items make you use worse pills",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_HORSE_TRANQUILIZER),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_HORSE_TRANQUILIZER.."}} {{ColorItemStack}}Multiple copies have no additional effect{{CR}}",
                },
            },
            --[[
            {
                Condition = function()
                    for i=0, Game():GetNumPlayers()-1 do
                        local pvals = mod:getPlayerPhdValues(Isaac.GetPlayer(i))
                        if(pvals.GOOD==true and pvals.BAD==false) then return true end
                    end
                    return false
                end,
                DescriptionToAdd = {
                    "{{Collectible75}} {{ColorJonas}}{{Quality0}}, {{Quality1}}, and {{Quality2}} are positive, {{Quality3}} and {{Quality4}} are neutral{{CR}}",
                },
            },
            {
                Condition = function()
                    for i=0, Game():GetNumPlayers()-1 do
                        local pvals = mod:getPlayerPhdValues(Isaac.GetPlayer(i))
                        if(pvals.GOOD==false and pvals.BAD==true) then return true end
                    end
                    return false
                end,
                DescriptionToAdd = {
                    "{{Collectible654}} {{ColorJonas}}{{Quality0}} and {{Quality1}} are neutral, {{Quality2}}, {{Quality3}}, and {{Quality4}} are negative{{CR}}",
                },
            },
            {
                Condition = function()
                    for i=0, Game():GetNumPlayers()-1 do
                        local pvals = mod:getPlayerPhdValues(Isaac.GetPlayer(i))
                        if(pvals.GOOD==true and pvals.BAD==true) then return true end
                    end
                    return false
                end,
                DescriptionToAdd = {
                    "{{Blank}}{{ColorJonas}}{{Collectible654}} + {{Collectible75}}: No change{{CR}}",
                },
            },
            --]]
        },
    },
    [mod.COLLECTIBLE_SILK_BAG] = {
        Name = "Silk Bag",
        Description = {
            "{{Card"..mod.CONSUMABLE_LAUREL.."}} Spawns 1 Laurel every 6 rooms",
            "{{Blank}} Laurels give 5 seconds of invincibility when used",
        },
        DescriptionAppend = {
            {
                Condition = function()
                    return (mod:getPersistentData("HAS_SEEN_YANNY")==1)
                end,
                DescriptionToAdd = {
                    "{{Card"..mod.CONSUMABLE_YANNY.."}} 0.1% chance to spawn a Yanny instead of a Laurel",
                    "{{Blank}} Yannies deal 30 damage to all enemies in the room when used",
                },
            },
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BFFS)
                end,
                TextToModify = {
                    {
                        Old = "6 rooms",
                        New = "4/{{Collectible247}} {{BlinkPink}}4{{CR}} rooms"
                    },
                },
            },
        },
    },
    [mod.COLLECTIBLE_ROCK_CANDY] = {
        Name = "Rock Candy",
        Description = {
            "\1 +0.3 Tears",
            "\1 +0.15 Shotspeed",
            "{{Card"..mod.CONSUMABLE_MANTLE_ROCK.."}} Spawns a random Mantle consumable",
        },
    },
    [mod.COLLECTIBLE_MISSING_PAGE_3] = {
        Name = "Missing Page 3",
        Description = {
            "{{DeathMark}} Enemies have a 4% chance to spawn as a Skull champion",
            --"{{Blank}} {{ColorGray}}Skull champions have 2x health and trigger {{Collectible35}} The Necronomicon effect on death{{CR}}",
            "{{BlackHeart}} Skull champions are guaranteed to drop a black heart on death",
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return Game():IsHardMode()
                end,
                TextToModify = {
                    {
                        Old = "are guaranteed",
                        New = "have a 33%% chance"
                    },
                },
            },
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_MISSING_PAGE_3),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_MISSING_PAGE_3.."}} {{ColorItemStack}}+4% chance for Skull champions to spawn for every item stack{{CR}}",
                    "{{Collectible"..mod.COLLECTIBLE_MISSING_PAGE_3.."}} {{ColorItemStack}}Skull champions spawned by this item don't have increased health{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_GLASS_VESSEL] = {
        Name = "Glass Vessel",
        Description = {
            "Grants a glass shield that negates one hit",
            "{{Heart}} When the shield is broken, you can recharge it by picking up a red heart, which will consume the heart in the process",
        },
        DescriptionAppend = {
            {
                Condition = function()
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
                end,
                DescriptionToAdd = {
                    "{{Collectible"..CollectibleType.COLLECTIBLE_HOLY_MANTLE.."}} This blocks damage before Holy Mantle",
                },
            },
            {
                Condition = function()
                    return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER) or PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER_B)
                end,
                DescriptionToAdd = {
                    "{{Player14}} With coin health, picking up a coin recharges the shield",
                },
            },
            {
                Condition = getStackFunction(mod.COLLECTIBLE_GLASS_VESSEL),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_GLASS_VESSEL.."}} {{ColorItemStack}}No effect with multiple stacks{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_BONE_BOY] = {
        Name = "Bone Boy",
        Description = {
            "{{DeathMark}} Grants a Bony familiar that loves to party!",
            "He chases nearby enemies and throws bones at them",
            "He blocks projectiles and can die after 5 hits, turning into an immobile pile of bones that revives after 15 seconds"
        },
        DescriptionAppend = {
            {
                Condition = function()
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BFFS)
                end,
                DescriptionToAdd = {
                    "{{Collectible247}} {{BlinkPink}}Grants a Black Bony that fires a barrage of 3 bones less frequently{{CR}}",
                    "{{Collectible247}} {{BlinkPink}}On death, the Black Bony creates an explosion that can't hurt you{{CR}}"
                },
            },
            {
                Condition = function()
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD)
                end,
                DescriptionToAdd = {
                    "{{Collectible545}} On use, Book of the Dead revives any dead Bony familiars",
                },
            },
            {
                Condition = function()
                    return false--PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_HALLOWED_GROUND)
                end,
                DescriptionToAdd = {
                    "{{Collectible543}} When the Bony enters a Hallowed Ground aura, it levels up, gaining more HP and firing arced bones that leave behind flames on impact",
                    "{{Collectible543}} On death, the Bony levels back down into a normal bony",
                },
            },
        },
    },
    [mod.COLLECTIBLE_STEEL_SOUL] = {
        Name = "Steel Soul",
        Description = {
            "{{SoulHeart}} +1 Soul Heart",
            "Any full Soul/Black Hearts gained have a metal shield that can block 1 additional damage",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_STEEL_SOUL),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_STEEL_SOUL.."}} {{ColorItemStack}}No effect with multiple stacks{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_BOBS_HEART] = {
        Name = "Bob's Heart",
        Description = {
            "Grants immunity to explosions",
            "Taking damage spawns a cloud of poisonous gas and creep",
            "Taking damage has a 50% chance for Isaac to explode"
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_BOBS_HEART),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_BOBS_HEART.."}} {{ColorItemStack}}No effect with multiple stacks{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_CLOWN_PHD] = {
        Name = "Clown PHD",
        Description = {
            "{{Pill}} When used, pills have a random effect",
            "Converts negative pills into positive ones",
            "Pills can no longer be identified",
            
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_CLOWN_PHD),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_CLOWN_PHD.."}} {{ColorItemStack}}Multiple copies have no additional effect{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_GIANT_CAPSULE] = {
        Name = "Giant Capsule",
        Description = {
            "Using a consumable spawns a virus orbital that disappears after 40 seconds",
            "Viruses shoot tears with different effects depending on their color",
            "Viruses have different colors based on what type of consumable was used",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_GIANT_CAPSULE),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_GIANT_CAPSULE.."}} {{ColorItemStack}}+1 virus for every item stack{{CR}}",
                    "{{Collectible"..mod.COLLECTIBLE_GIANT_CAPSULE.."}} {{ColorItemStack}}Viruses live for +20 seconds per item stack{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_LOVE_LETTER] = {
        Name = "Love Letter",
        Description = {
            "{{Charm}} 10% chance to shoot charming tears",
            "Charmed enemies take 33% more damage",
            "Charmed enemies and their projectiles cannot damage you",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_LOVE_LETTER),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_LOVE_LETTER.."}} {{ColorItemStack}}+16% extra damage to charmed enemies{{CR}}",
                    "{{Collectible"..mod.COLLECTIBLE_LOVE_LETTER.."}} {{ColorItemStack}}+5% chance to charm enemies{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_QUAKE_BOMBS] = {
        Name = "Quake Bombs",
        Description = {
            "{{Bomb}} +5 Bombs",
            "Bombs explode additional connected rocks up to 2 tiles away",
            "Rocks destroyed by your bombs have doubled drops"
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_QUAKE_BOMBS),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_QUAKE_BOMBS.."}} {{ColorItemStack}}Multiple copies have no additional effect{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_ATHEISM] = {
        Name = "Atheism",
        Description = {
            "{{AngelDevilChance}} +15% Devil/Angel deal chance",
            "{{AngelDevilChance}} Devil/Angel deals are replaced by {{TreasureRoom}} Treasure rooms which contain a choice between 2 items",
        },
        DescriptionAppend = {
            {
                Condition = function(descObj)
                    return (Game().Difficulty==Difficulty.DIFFICULTY_GREED or Game().Difficulty==Difficulty.DIFFICULTY_GREEDIER)
                end,
                DescriptionToAdd = {
                    "{{GreedMode}} In Greed Mode, replaces deals with {{GreedTreasureRoom}} Silver Treasure rooms",
                },
            },
        },
    },
    [mod.COLLECTIBLE_MAYONAISE] = {
        Name = "A Spoonful of Mayonnaise",
        Description = {
            "\1 +0.15 Shotspeed",
            "{{EternalHeart}} +1 Eternal Heart",
        },
    },
    [mod.COLLECTIBLE_AWESOME_FRUIT] = {
        Name = "Awesome Fruit",
        Description = {
            "\1 +1 Health",
            "{{HealingRed}} Heals 1 heart",
            "\1 +1 progress for all Transformations",
        },
    },
    [mod.COLLECTIBLE_JONAS_MASK] = {
        Name = "Jonas' Mask",
        Description = {
            "Gives 1 of 3 shadow familiars:",
            "{{Blank}} \7 Fly that bounces around the room and screams at enemies",
            "{{Blank}} \7 Spider that crawls around and pounces on enemies",
            "{{Blank}} \7 Urchin that orbits you and blocks projectiles",
            "Every floor the familiar is rerolled"
        },
    },
    [mod.COLLECTIBLE_SALTPETER] = {
        Name = "Saltpeter",
        Description = {
            "When enemies take damage, nearby enemies are hurt for 50% of that damage",
            "Tears have a 5% chance to explode upon hitting an enemy",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_SALTPETER),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_SALTPETER.."}} {{ColorItemStack}}+50% AOE damage{{CR}}",
                    "{{Collectible"..mod.COLLECTIBLE_SALTPETER.."}} {{ColorItemStack}}+5% chance to explode{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_DR_BUM] = {
        Name = "Dr. Bum",
        Description = {
            "{{Card}} Picks up cards, runes, and objects and turns them into {{Pill}} pills",
            "Pills spawned by this are more likely to be positive or neutral"
        },
    },
    [mod.COLLECTIBLE_PREFERRED_OPTIONS] = {
        Name = "Preferred Options",
        Description = {
            "{{BossRoom}} You may choose between 2 items after beating a boss",
            "One of the items will be a duplicate of the last item you took from a boss room",
            --"{{Blank}} {{ColorGray}}Cannot duplicate story items{{CR}}", --# i feel like its kind of obvious
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_PREFERRED_OPTIONS),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_PREFERRED_OPTIONS.."}} {{ColorItemStack}}Multiple copies have no additional effect{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_PLASMA_GLOBE] = {
        Name = "Plasma Globe",
        Description = {
            "\2 -0.2 Shotspeed down",
            "While flying, your tears fire electric lasers at nearby enemies",
            "The lasers deal 25% of the tear's damage",
        },
    },
    [mod.COLLECTIBLE_CURSED_EULOGY] = {
        Name = "Cursed Eulogy",
        Description = {
            "{{BlackHeart}} +1 Black Heart",
            "\2 Items have a 20% chance to spawn as a Curse Room or Red Chest item",
        },
        DescriptionAppend = {
            {
                Condition = getStackFunction(mod.COLLECTIBLE_CURSED_EULOGY),
                DescriptionToAdd = {
                    "{{Collectible"..mod.COLLECTIBLE_CURSED_EULOGY.."}} {{ColorItemStack}}+20% chance to replace items{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_BLESSED_BOMBS] = {
        Name = "Blessed Bombs",
        Description = {
            "{{Bomb}} +5 Bombs",
            "Bombs take twice as long to explode",
            "While fused, bombs have a holy aura that grants:",
            "\1 x3 Tears",
            "\1 x2 Damage",
            "Homing tears",
        },
    },
    [mod.COLLECTIBLE_CATHARSIS] = {
        Name = "Catharsis",
        Description = {
            "\1 +1 Tears",
            "\1 Tears cap is doubled",
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
    --[[
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
    --]]
    [mod.COLLECTIBLE_SUNK_COSTS] = {
        Name = "Sunk Costs",
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
    [mod.COLLECTIBLE_ASCENSION] = {
        Name = "Ascension",
        Description = {
            "{{Timer}} For the next 3 seconds: gain flight and spectral tears",
            "When time is up, get teleported back to where you used the item and gain 1 second of invincibility",
            "You can end the effect early by using the item again"
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "3 seconds",
                        New = "3/{{Collectible356}}{{BlinkYellowGreen}}6{{CR}} seconds"
                    },
                },
            },
        },
    },
    [mod.COLLECTIBLE_GILDED_APPLE] = {
        Name = "Gilded Apple",
        Description = {
            "{{GoldenHeart}} +1 Golden Heart",
        },
    },
    [mod.COLLECTIBLE_PEZ_DISPENSER] = {
        Name = nil,
        Description = {
            "{{Card}} Can store up to 2 consumables of any type",
            "Swap between stored consumables by pressing the Drop key ({{ButtonRT}})",
            "When activated, puts the frontmost stored consumable into your consumable slot",
            
            --"Hold the Map key ({{ButtonSelect}}) to see the frontmost stored consumable's name"
        },
        DescriptionAppend = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                end,
                DescriptionToAdd = {
                    "{{Collectible63}} {{BlinkYellowGreen}}Can store an extra consumable{{CR}}",
                },
            },
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                DescriptionToAdd = {
                    "{{Collectible356}} {{BlinkYellowGreen}}Can store an extra consumable{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_ALPHABET_BOX] = {
        Name = "Alphabet Box",
        Description = {
            "Rerolls all items in the room into the next item in alphabetical order",
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "next item",
                        New = "next/{{Collectible356}}{{BlinkYellowGreen}}second next{{CR}} item"
                    },
                },
            },
        },
    },
    [mod.COLLECTIBLE_HOSTILE_TAKEOVER] = {
        Name = "Hostile Takeover",
        Description = {
            "{{Timer}} For the room:",
            "Gives stats that wear off over 10 seconds:",
            "{{Blank}} \1 +0.2 Speed",
            "{{Blank}} \1 +2 Damage",
            "{{Blank}} \1 +1 Tears",
            "Grants {{Collectible647}} 4.5 Volt",
            "On death, enemies spawn puddles of slowing tar",
            "Touching a puddle absorbs it, extends the temporary stats and adds partial active charge to this item"
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "+0.2 Speed",
                        New = "+0.2/{{Collectible356}}{{BlinkYellowGreen}}0.3{{CR}} Speed"
                    },
                    {
                        Old = "+2 Damage",
                        New = "+2/{{Collectible356}}{{BlinkYellowGreen}}3{{CR}} Damage"
                    },
                    {
                        Old = "+1 Tears",
                        New = "+1/{{Collectible356}}{{BlinkYellowGreen}}1.5{{CR}} Tears"
                    },
                },
            },
        },
        DescriptionAppend = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                DescriptionToAdd = {
                    "{{Collectible356}} {{BlinkYellowGreen}}Gain more partial charge from tar puddles{{CR}}",
                },
            },
        },
    },
    [mod.COLLECTIBLE_BLOODY_WHISTLE] = {
        Name = "Bloody Whistle",
        Description = {
            "Spawns a pool of blood creep",
            "The creep deals 21 damage per second",
            "The creep spawns blood tears that deal 7 damage"
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY)
                end,
                TextToModify = {
                    {
                        Old = "next item",
                        New = "next/{{Collectible356}}{{BlinkYellowGreen}}second next{{CR}} item"
                    },
                },
            },
        },
    },

    [mod.COLLECTIBLE_D] = {
        Name = "D",
        Description = {
            "{{Timer}} Adds anywhere from +3 minutes to -3 minutes to the game's timer",
        },
    },
    [mod.COLLECTIBLE_EQUALIZER] = {
        Name = "Equalizer",
        Description = {
            "{{Coin}} +3 Coins",
            "{{Bomb}} +1 Bomb",
            "{{Key}} +1 Key",
            "On pickup/on use, chooses a pickup and a stat",
            "You will get a bonus to that stat proportional to how many of that pickup you have, until the next time you use the item"
        },
    },
    [mod.COLLECTIBLE_PORTABLE_TELLER] = {
        Name = "Portable Teller",
        Description = {
            "{{Coin}} Spend 1 coin to display a fortune or a chance to spawn a trinket, card or soul heart",
        },
    },
    --#endregion
}
local EXTRA_ITEM_MODIFIERS = {
    { --! ATLAS
        --* special condition to apply to all of them
        ["0"] = {
            BaseCondition = function(descObj)
                return false --return mod:isAnyPlayerAtlasA()
            end,
            Icon = "{{Player"..mod.PLAYER_ATLAS_A.."}}",
            Color = "{{ColorSilver}}",
        },
        [mod.COLLECTIBLE_STEEL_SOUL] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "When used, mantles have a 25% chance to gain a shield",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_YUM_HEART] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Heals up to 2 HP on your damaged mantles",
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
        [mod.COLLECTIBLE_GILDED_APPLE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "+1 Gold mantle",
                    },
                },
            },
        },
    },
    --[[
    { --! LIMIT BREAK
        ["0"] = {
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
                        "Shade has a 25% chance to {{Fear}} Fear enemies it hits",
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
                        "Has a 50% chance to {{Charm}} Charm enemies it hits",
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
        [CollectibleType.COLLECTIBLE_PORTABLE_SLOT] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "You can swap between Portable Slot and a portable Fortune Teller with the Drop button ({{ButtonRT}})",
                    },
                },
            },
        },
        [mod.COLLECTIBLE_PORTABLE_TELLER] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "You can swap between Portable Teller and Portable Slot with the Drop button ({{ButtonRT}})",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BEAN] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Additionally leaves behind a large {{Poison}} poison cloud that lasts for 10 seconds",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BATTERY_PACK] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "On room clear, 25% chance to spawn a {{Battery}} Micro Battery",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BROWN_NUGGET] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Fly's tear damage increased to 5",
                        "The fly copies your tear effects",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_MOMS_PAD] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "25% chance for enemies to be permanently {{Fear}} Feared for the rest of the room",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_KEY_BUM] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Spawned chests automatically open for no cost",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_ABEL] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Tears do +2.5 Damage",
                        "Fires rock tears that split into 4 smaller tears upon contact",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BLOOD_RIGHTS] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Enemies killed by this have a 10% chance to spawn a {{HalfHeart}} half red heart",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_LINGER_BEAN] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "The cloud spawns a poisonous gas cloud every 3 seconds",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_POOP] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "While uncharged, you can use this item to pick up and throw poops",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_BOX] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Additionally spawns a {{GoldenKey}} Golden Key and a {{GoldenBomb}} Golden Bomb",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_MAGIC_FINGERS] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Enemies damaged by this have a 7.77% chance to be petrified and {{Collectible202}} turned to gold",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_PAGEANT_BOY] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Pennies have a 13.5% chance to be converted into Double Pennies, and a 1.5% chance to be converted to Nickels",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_QUARTER] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Pennies have a 5% chance to be converted into Lucky Pennies",
                    },
                },
            },
        },
    },
    --]]
    { --! JONAS
        ["0"] = {
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
    { --! PREFERRED OPTIONS WARNING
        ["0"] = {
            BaseCondition = function(descObj)
                return PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_PREFERRED_OPTIONS)
            end,
            Icon = "{{Collectible"..mod.COLLECTIBLE_PREFERRED_OPTIONS.."}}",
            Color = "{{ColorGray}}",
        },
        [CollectibleType.COLLECTIBLE_POLAROID] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Cannot be copied by Preferred Options",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_NEGATIVE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Cannot be copied by Preferred Options",
                    },
                },
            },
        },
        [CollectibleType.COLLECTIBLE_DADS_NOTE] = {
            DescriptionAppend = {
                {
                    DescriptionToAdd = {
                        "Cannot be copied by Preferred Options",
                    },
                },
            },
        },
    },
}

local TRINKETS = {
    --[[
    [mod.TRINKET_PLASMA_GLOBE] = {
        Name = "Plasma Globe",
        Description = {
            "On new rooms, enemies have a 15% chance to be electrified for 4 seconds",
            "{{Luck}} 50% chance at 20 luck",
            "{{ToyboxElectrifiedStatus}} Electrified enemies have a damaging electric laser that follows them and arc off damaging sparks that hurt them in the process",
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "4 seconds",
                        New = "{{ColorGold}}6{{CR}} seconds",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "6{{CR}} seconds",
                        New = "{{ColorRainbow}}9{{CR}} seconds",
                    },
                },
            },
        },
        DescriptionAppend = {
            {
                Condition = function() return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_SHARP_PLUG) end,
                DescriptionToAdd = {
                    "{{Collectible205}} Orbital laser and sparks deal 50% more damage",
                },
            },
            {
                Condition = function() return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) end,
                DescriptionToAdd = {
                    "{{Collectible356}} Orbital laser and sparks deal 50% more damage",
                },
            },
            {
                Condition = function() return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_9_VOLT) end,
                DescriptionToAdd = {
                    "{{Collectible116}} Sparks have 50% more range",
                },
            },
            {
                Condition = function() return PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_WATCH_BATTERY) end,
                DescriptionToAdd = {
                    "{{Trinket72}} Sparks have 50% more range",
                },
            },
            {
                Condition = function() return PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_HAIRPIN) end,
                DescriptionToAdd = {
                    "{{Trinket120}} Sparks have 50% more range",
                },
            },
            {
                Condition = function() return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BATTERY) end,
                DescriptionToAdd = {
                    "{{Collectible63}} Sparks arc 25% more frequently",
                },
            },
            {
                Condition = function() return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_JUMPER_CABLES) end,
                DescriptionToAdd = {
                    "{{Collectible520}} Sparks arc 25% more frequently",
                },
            },
            {
                Condition = function() return PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_AAA_BATTERY) end,
                DescriptionToAdd = {
                    "{{Trinket3}} Sparks arc 25% more frequently",
                },
            },
            {
                Condition = function() return PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_OLD_CAPACITOR) end,
                DescriptionToAdd = {
                    "{{Trinket143}} Arcs 2 sparks at the same time",
                },
            },
        }
    },
    --]]
    --[[
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
                        New = "{{ColorGold}}5%%{{CR}} chance",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "{{ColorGold}}5%%{{CR}} chance",
                        New = "{{ColorRainbow}}7.5%%{{CR}}",
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
    --]]
    [mod.TRINKET_WONDER_DRUG] = {
        Name = "Wonder Drug",
        Description = {
            "{{ToyboxGoldenPill}} Doubles the chance for gold pills to spawn",
            "{{ToyboxHorsePill}} Doubles the chance for horse pills to spawn",
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "Doubles",
                        New = "{{ColorGold}}Triples{{CR}}",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "Triples",
                        New = "{{ColorRainbow}}Quadruples{{CR}}",
                    },
                },
            },
        },
    },
    [mod.TRINKET_ANTIBIOTICS] = {
        Name = "Antibiotics",
        Description = {
            "{{Pill}} Using a pill has a 20% chance to use it 2 times",
            "100% chance for unidentified pills",
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "2 times",
                        New = "{{ColorGold}}3{{CR}} times",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "{{ColorGold}}3{{CR}} times",
                        New = "{{ColorRainbow}}4{{CR}} times",
                    },
                },
            },
        },
    },
    [mod.TRINKET_AMBER_FOSSIL] = {
        Name = "Amber Fossil",
        Description = {
            "Your blue flies have a 25% chance to be converted into a random locust",
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "25%% chance",
                        New = "{{ColorGold}}50%%{{CR}} chance",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "{{ColorGold}}50%%{{CR}} chance",
                        New = "{{ColorRainbow}}75%%{{CR}} chance",
                    },
                },
            },
        },
    },
    [mod.TRINKET_SINE_WORM] = {
        Name = "Sine Worm",
        Description = {
            "\1 +0.4 Tears",
            "\1 +1.5 Range",
            "Your tears gradually slow down and speed back up to normal velocity",
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "0.4 Tears",
                        New = "{{ColorGold}}0.8{{CR}} Tears",
                    },
                    {
                        Old = "1.5 Range",
                        New = "{{ColorGold}}3{{CR}} Range",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "0.8{{CR}} Tears",
                        New = "{{ColorRainbow}}1.2{{CR}} Tears",
                    },
                    {
                        Old = "3{{CR}} Range",
                        New = "{{ColorRainbow}}4.5{{CR}} Range",
                    },
                },
            },
        },
    },
    [mod.TRINKET_BIG_BLIND] = {
        Name = "Big Blind",
        Description = {
            "Every 10 damage dealt to enemies, they spawn a coin",
            "The requirement for spawning a coin goes up more and more for every coin spawned",
        },
        DescriptionAppend = {
            {
                Condition = isDoubleTrinketMultiplier,
                DescriptionToAdd = {
                    "{{ColorGold}}Coins are spawned twice as often{{CR}}",
                },
            },
        },
        DescriptionModifiers = {
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "Coins are spawned twice as often",
                        New = "{{ColorRainbow}}Coins are spawned three times as often{{CR}}",
                    },
                },
            },
        },
    },
    [mod.TRINKET_JONAS_LOCK] = {
        Name = "Jonas' Lock",
        Description = {
            "{{Pill}} Using a pill grants a stat bonus equivalent to 50% of a random \"stat up\" pill's effect",
            "The stat bonuses are only applied while holding this trinket"
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "50%%",
                        New = "{{ColorGold}}100%%{{CR}}",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "100%%",
                        New = "{{ColorRainbow}}150%%{{CR}}",
                    },
                },
            },
        },
    },
    [mod.TRINKET_BATH_WATER] = {
        Name = "Bath Water",
        Description = {
            "Familiar that shatters when you take damage and spawns a pool of creep, once per room",
            "The creep deals 24 damage per second",
        },
    },
    [mod.TRINKET_BLACK_RUNE_SHARD] = {
        Name = "Black Rune Shard",
        Description = {
            "{{Coin}} Blue flies and spiders have a 33% chance to be replaced by a coin",
        },
        DescriptionModifiers = {
            {
                Condition = function(descObj)
                    return (FiendFolio~=nil)
                end,
                TextToModify = {
                    {
                        Old = "and spiders",
                        New = ", spiders, and skuzzes",
                    },
                },
            },
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "33%% chance",
                        New = "{{ColorGold}}67%%{{CR}} chance",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "{{ColorGold}}67%%{{CR}} chance",
                        New = "{{ColorRainbow}}100%%{{CR}} chance",
                    },
                },
            },
        },
    },
    [mod.TRINKET_SUPPOSITORY] = {
        Name = "Suppository",
        Description = {
            "{{Pill}} Poop drops have a 20% chance to be replaced by a pill",
        },
        DescriptionModifiers = {
            {
                Condition = isDoubleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "20%% chance",
                        New = "{{ColorGold}}40%%{{CR}} chance",
                    },
                },
            },
            {
                Condition = isTripleTrinketMultiplier,
                TextToModify = {
                    {
                        Old = "{{ColorGold}}40%%{{CR}} chance",
                        New = "{{ColorRainbow}}60%%{{CR}} chance",
                    },
                },
            },
        },
    },
}
--! for double and triple
local EXTRA_TRINKET_MODIFIERS = {

}

local CARDS = {
    [mod.CARD_PRISMSTONE] = {
        Name = "Prismstone",
        Description = {
            "{{Rune}} Spawns 3 runes or soul stones",
            "Only 1 can be taken"
        },
    },
    [mod.CARD_FOIL_CARD] = {
        Name = "Foil Card",
        Description = {
            "{{Coin}} Spawns a golden heart, penny, key or bomb",
        },
    },

    [mod.CONSUMABLE_LAUREL] = {
        Name = "Laurel",
        Description = {
            "Gives 5 seconds of invincibility when used",
        },
    },
    [mod.CONSUMABLE_YANNY] = {
        Name = "Yanny",
        Description = {
            "Deals 30 damage to all enemies in the room when used",
        },
    },

    [mod.CONSUMABLE_MANTLE_ROCK] = {
        Name = "Rock Mantle",
        Description = {
            "2 HP",
            "Does nothing",
            "{{AtlasATransformationRock}} {{ColorGray}}Transformation{{CR}}",
            "No effect",
        },
        NonAtlasDescription = {
            "{{Timer}} For the room:",
            "Grants {{Collectible592}} Terra",
            "Taking damage fires a shockwave at the enemy who hurt you"
        },
    },
    [mod.CONSUMABLE_MANTLE_POOP] = {
        Name = "Poop Mantle",
        Description = {
            "2 HP",
            "50% chance to spawn 2 blue flies on room clear",
            "+3.33% chance for rocks to be replaced with poop",
            "{{AtlasATransformationPoop}} {{ColorGray}}Transformation{{CR}}",
            "Destroying poops heals 1 HP to your leftmost damaged mantle",
            "+10% chance to get pickups from poops",
            "Poops can now drop keys, bombs, consumables and batteries",
        },
        NonAtlasDescription = {
            "Hold up a throwable poop",
            "When thrown, it leaves liquid poop creep under it as it flies"
        },
    },
    [mod.CONSUMABLE_MANTLE_BONE] = {
        Name = "Bone Mantle",
        Description = {
            "\1 3 HP",
            "+10% chance to spawn a bone orbital on kill",
            "Losing a Bone Mantle spawns a friendly Bony",
            "{{AtlasATransformationBone}} {{ColorGray}}Transformation{{CR}}",
            "Fire bones in a circle around you when damaged",
            "+0.6 Tears for every missing Mantle",
        },
        NonAtlasDescription = {
            "{{Charm}} Spawns a friendly Bony",
            "{{Timer}} For the room, enemies have a 67% chance to spawn an orbital bone shard on death",
        },
    },
    [mod.CONSUMABLE_MANTLE_DARK] = {
        Name = "Dark Mantle",
        Description = {
            "2 HP",
            "\1 +0.4 Damage",
            "Losing a Dark Mantle deals 60 damage to all enemies",
            "{{AtlasATransformationDark}} {{ColorGray}}Transformation{{CR}}",
            "Gain a dark aura that gives +0.5 Damage for every enemy inside it",
            "Losing any Mantle deals 60 damage to all enemies"
        },
        NonAtlasDescription = {
            "DescriptionTest",
        },
    },
    [mod.CONSUMABLE_MANTLE_HOLY] = {
        Name = "Holy Mantle",
        Description = {
            "2 HP",
            "\1 +0.5 Range",
            "+3.33% chance to fire a {{Collectible182}} Sacred Heart tear",
            "{{AtlasATransformationHoly}} {{ColorGray}}Transformation{{CR}}",
            "Flight",
            "Gain an aura that deals 10 damage per second",
        },
        NonAtlasDescription = {
            "{{EternalHeart}} +1 Eternal Heart",
            "{{Timer}} Your tears gain a damaging aura for the room"
        },
    },
    [mod.CONSUMABLE_MANTLE_SALT] = {
        Name = "Salt Mantle",
        Description = {
            "2 HP",
            "\1 +0.33 Tears",
            "{{AtlasATransformationSalt}} {{ColorGray}}Transformation{{CR}}",
            "Press the DROP key to enter or leave \"salt statue\" form",
            "While in this form, you have x2.5 Tears but are immobile",
        },
        NonAtlasDescription = {
            "{{Timer}} Gives the effect of a random \"Tears Up\" item for the room",
        },
    },
    [mod.CONSUMABLE_MANTLE_GLASS] = {
        Name = "Glass Mantle",
        Description = {
            "\2 1 HP",
            "\1 +0.5 Damage",
            "\1 +0.1 Shotspeed",
            "!!! Losing a Glass Mantle destroys all other Glass Mantles",
            "{{AtlasATransformationGlass}} {{ColorGray}}Transformation{{CR}}",
            "\1 x1.5 Damage",
            "!!! Taking damage has a 90% chance to destroy all Mantles",
        },
        NonAtlasDescription = {
            "{{Timer}} For the room:",
            "\1 x1.5 Damage",
            "\2 Damage taken is doubled and increased by 1 extra heart"
        },
    },
    [mod.CONSUMABLE_MANTLE_METAL] = {
        Name = "Metal Mantle",
        Description = {
            "\1 3 HP",
            "\2 -0.1 Speed",
            "+5% chance to block damage",
            "{{AtlasATransformationMetal}} {{ColorGray}}Transformation{{CR}}",
            "+10% chance to block damage",
            "Spike damage is always blocked",
        },
        NonAtlasDescription = {
            "{{SoulHeart}} +1 Soul Heart",
            "All of your full Soul/Black Hearts gain a metal shield that blocks 1 damage",
        },
    },
    [mod.CONSUMABLE_MANTLE_GOLD] = {
        Name = "Gold Mantle",
        Description = {
            "2 HP",
            "\1 +1 Luck",
            "Losing a Gold Mantle turns nearby enemies to gold",
            "{{AtlasATransformationGold}} {{ColorGray}}Transformation{{CR}}",
            "Tears have a 5% chance to spawn a penny upon hitting an enemy",
            "Losing any Mantle turns nearby enemies to gold",
        },
        NonAtlasDescription = {
            "{{Coin}} Removes 1 coin, spawns a random pickup",
            "Only has a 5% chance to be consumed on use"
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
            "{{Timer}} For the next 5 seconds, you are invincible and have a 0.7x damage multiplier"
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
            "\1 +0.45 Damage",
        }
    },
    [mod.PILL_DMG_DOWN] = {
        Name = "Damage Down",
        Description = {
            "\2 -0.35 Damage",
        }
    },
}
--! for horse pills
local EXTRA_PILL_MODIFIERS = {
    { --! HORSE
        ["0"] = {
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
        ["0"] = {
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
            "Your health is made of \"mantles\" with various effects, which may replace hearts",
            "Having 3 of the same mantle grants a unique transformation that lasts until you get another transformation or lose all mantles",
            "Losing all mantle turns you into {{AtlasATransformationTar}}{{ColorGray}}Tar{{CR}}, a form where you die in one hit and have slightly better stats",
            "In Tar form, you can turn back to normal by recovering a mantle",
        },
        Birthright = {
            "You can have 2 mantle transformations at once",
            "When you lose a transformation, it gets transferred into the second transformation slot where it functions alongside the current transformation",
            "Turning into {{AtlasATransformationTar}}{{ColorGray}}Tar{{CR}} removes both transformations",
        },
    },
    [mod.PLAYER_ATLAS_A_TAR] = {
        Name="Atlas",
        Description = {
            "Your health is made of \"mantles\" with various effects, which may replace hearts",
            "Having 3 of the same mantle grants a unique transformation that lasts until you get another transformation or lose all mantles",
            "Losing all mantle turns you into {{AtlasATransformationTar}}{{ColorGray}}Tar{{CR}}, a form where you die in one hit and have slightly better stats",
            "In Tar form, you can turn back to normal by recovering a mantle",
        },
        Birthright = {
            "You can have 2 mantle transformations at once",
            "When you lose a transformation, it gets transferred into the second transformation slot where it functions alongside the current transformation",
            "Turning into {{AtlasATransformationTar}}{{ColorGray}}Tar{{CR}} removes both transformations",
        },
    },
    [mod.PLAYER_JONAS_A] = {
        Name="Jonas",
        Description = {
            "Pill pool gets rerolled and unidentified at the start of every floor",
            "Enemies may drop pills on death",
            "All stats up proportional to your \"Pill Bonus\"",
            "Gain Pill Bonus by using pills",
            "Lose Pill Bonus on new floor, or if you go too long without using a pill",
        },
        Birthright = {
            "{{Pill}} Higher chance for enemies to drop a pill",
            "{{Card}} When an enemy drops a pill, 20% chance to turn it into a card/rune",
            "Cards and runes give Pill Bonus",
        },
    },
    [mod.PLAYER_MILCOM_A] = {
        Name="Milcom",
        Description = {
            "{{Coin}} Bombs and keys instead give coins when gained, and consume coins when used",
            "No room clear rewards in normal rooms",
            "Higher champion chance, champions drop 2-6 coins"
        },
        Birthright = {
            "Bombs cost 3 coins to use",
            "Keys cost 5 coins to use",
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