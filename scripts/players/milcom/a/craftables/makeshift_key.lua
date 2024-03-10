local mod = MilcomMOD

local function forceDecreaseNails(_, player, craftable)
    mod.MILCOM_A_PICKUPS.NAILS_NOUPGRADE = mod.MILCOM_A_PICKUPS.NAILS-craftable.COST.NAILS
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_MILCOM_CRAFT_CRAFTABLE, forceDecreaseNails, "MAKESHIFT KEY")