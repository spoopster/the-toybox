MilcomMOD = RegisterMod("milcomMod", 1)
local mod = MilcomMOD

local mod_files = {
    "scripts.enums",
    "scripts.custom_data",
    "scripts.helper",
    "scripts.save_data",

    "scripts.players.milcom.a.milcom",
    "scripts.players.milcom.a.stats",
    "scripts.players.milcom.a.helper_funcs",
    "scripts.players.milcom.a.hopping_logic",
    "scripts.players.milcom.a.pickups_logic",
    "scripts.players.milcom.a.crafting_menu",

    --"scripts.players.milcom.a.craftables.",
    --"scripts.players.milcom.a.craftables.makeshift_bomb", -- THIS FILE DOES NOTHING, AS ITS EFFECT IS DONE IN "pickups_logic.lua"
    --"scripts.players.milcom.a.craftables.makeshift_key", -- THIS FILE DOES NOTHING, AS ITS EFFECT IS DONE IN "pickups_logic.lua"
    --"scripts.players.milcom.a.craftables.credit_cardboard", -- THIS FILE DOES NOTHING, AS ITS EFFECT IS DONE IN "pickups_logic.lua"

    "scripts.players.milcom.b.milcom",
    "scripts.players.milcom.b.stats",
    "scripts.players.milcom.b.closet_unlock",
}
for _, path in ipairs(mod_files) do
    include(path)
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)