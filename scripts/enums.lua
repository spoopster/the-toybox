local mod = MilcomMOD

mod.loadedData = false

mod.PLAYER_MILCOM_A = Isaac.GetPlayerTypeByName("Milcom", false)
mod.PLAYER_MILCOM_B = Isaac.GetPlayerTypeByName("Milcom", true)

mod.ACH_MILCOM_B = Isaac.GetAchievementIdByName("Tainted Milcom")

mod.MATERIAL_A_VARIANT = Isaac.GetEntityVariantByName("MATERIAL - Cardboard")
mod.MATERIAL_A_SUBTYPE = {
    CARDBOARD = 0,
    DUCT_TAPE = 1,
    NAILS = 2,
}

--#region MILCOM_A

mod.CRAFTABLES_A = include("scripts.players.milcom.a.enums.craftable_enums")
mod.CRAFTABLE_A_CATEGORIES = {
    --[[MAKESHIFT BOMB]]{ "MAKESHIFT_BOMB", "NAIL_BOMB", "BOMB3", "BOMB4", },
    --[[MAKESHIFT KEY]]{ "MAKESHIFT_KEY", "KEY2", "KEY3", "KEY4", },
    --[[NAILGUN]]{ "NAILGUN", "GUN2", "GUN3", "GUN4", },
    --[[MAGIC STAFF]]{ "MAGIC_STAFF", "STAFF2", "STAFF3", "STAFF4", },
    --[[CREDIT CARDBOARD]]{ "CREDIT_CARDBOARD", },
}

--#endregion