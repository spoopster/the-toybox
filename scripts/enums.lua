local mod = MilcomMOD

mod.loadedData = false

--#region PLAYERS

mod.PLAYER_MILCOM_A = Isaac.GetPlayerTypeByName("Milcom", false)
mod.PLAYER_MILCOM_B = Isaac.GetPlayerTypeByName("Milcom", true)

mod.PLAYER_ATLAS_A = Isaac.GetPlayerTypeByName("Atlas", false)
mod.PLAYER_ATLAS_B = Isaac.GetPlayerTypeByName("Atlas", true)

--#endregion
--#region ACHIEVEMENTS

mod.ACH_MILCOM_B = Isaac.GetAchievementIdByName("Tainted Milcom")
mod.ACH_ATLAS_B = Isaac.GetAchievementIdByName("Tainted Atlas")

--#endregion
--#region ITEMS

-- mod.COLLECTIBLE_ = Isaac.GetItemIdByName("")
mod.COLLECTIBLE_SLICKWATER = Isaac.GetItemIdByName("Slickwater") --
mod.COLLECTIBLE_CONDENSED_MILK = Isaac.GetItemIdByName("Condensed Milk") --
mod.COLLECTIBLE_EYESTRAIN = Isaac.GetItemIdByName("Eyestrain")
mod.COLLECTIBLE_PILE_OF_SAND = Isaac.GetItemIdByName("Pile of Sand")
mod.COLLECTIBLE_OBSIDIAN_SHARD = Isaac.GetItemIdByName("Obsidian Shard")
mod.COLLECTIBLE_GOAT_MILK = Isaac.GetItemIdByName("Goat Milk") --
mod.COLLECTIBLE_BRONZE_BULL = Isaac.GetItemIdByName("Bronze Bull")
mod.COLLECTIBLE_BLOODY_NEEDLE = Isaac.GetItemIdByName("Bloody Needle") --
mod.COLLECTIBLE_NOSE_CANDY = Isaac.GetItemIdByName("Nose Candy") --
mod.COLLECTIBLE_LION_SKULL = Isaac.GetItemIdByName("Lion Skull") --
mod.COLLECTIBLE_CURSED_CHAINS = Isaac.GetItemIdByName("Cursed Chains")
mod.COLLECTIBLE_MAMMONS_OFFERING = Isaac.GetItemIdByName("Mammon's Offering")

--#endregion
--#region MILCOM_A

mod.MATERIAL_A_VARIANT = Isaac.GetEntityVariantByName("MATERIAL - Cardboard")
mod.MATERIAL_A_SUBTYPE = {
    CARDBOARD = 0,
    DUCT_TAPE = 1,
    NAILS = 2,
}

mod.CRAFTABLES_A = include("scripts.players.milcom.a.enums.craftable_enums")
mod.CRAFTABLE_A_CATEGORIES = {
    --[[MAKESHIFT BOMB]]{ "MAKESHIFT_BOMB", "NAIL_BOMB", "BOMB3", "BOMB4", },
    --[[MAKESHIFT KEY]]{ "MAKESHIFT_KEY", "KEY2", "KEY3", "KEY4", },
    --[[NAILGUN]]{ "NAILGUN", "GUN2", "GUN3", "GUN4", },
    --[[MAGIC STAFF]]{ "MAGIC_STAFF", "STAFF2", "STAFF3", "STAFF4", },
    --[[CREDIT CARDBOARD]]{ "CREDIT_CARDBOARD", },
}

--#endregion
--#region ATLAS_A
mod.MANTLES = {
    TAR = -1,
    NONE = 0,
    DEFAULT = 1,
    POOP = 2,
    BONE = 3,
    EVIL = 4,
    HOLY = 5,
    SALT = 6,
    GLASS = 7,
    METAL = 8,
    GOLD = 9,
}

--#endregion