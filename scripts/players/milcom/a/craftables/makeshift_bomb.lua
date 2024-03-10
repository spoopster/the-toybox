local mod = MilcomMOD

local function forceDecreaseTape(_, player, craftable)
    mod.MILCOM_A_PICKUPS.DUCT_TAPE_NOUPGRADE = mod.MILCOM_A_PICKUPS.DUCT_TAPE-craftable.COST.TAPE
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_MILCOM_CRAFT_CRAFTABLE, forceDecreaseTape, "MAKESHIFT BOMB")