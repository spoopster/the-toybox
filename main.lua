MilcomMOD = RegisterMod("milcomMod", 1)
local mod = MilcomMOD

local mod_files = {
    "scripts.enums",
    "scripts.helper",
    "scripts.save_data",

    "scripts.player.a.milcom",
    "scripts.player.a.hopping_logic",
}
for _, path in ipairs(mod_files) do
    include(path)
end