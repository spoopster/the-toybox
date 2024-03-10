local mod = MilcomMOD

local function forceDecreaseCardboard(_, player, craftable)
    mod.MILCOM_A_PICKUPS.CARDBOARD_NOUPGRADE = mod.MILCOM_A_PICKUPS.CARDBOARD-craftable.COST.CARDBOARD
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_MILCOM_CRAFT_CRAFTABLE, forceDecreaseCardboard, "CREDIT CARDBOARD")