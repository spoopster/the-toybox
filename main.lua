MilcomMOD = RegisterMod("milcomMod", 1)
local mod = MilcomMOD

--! INCLUDE SHIT
local mod_files = {
    "scripts.enums",

    "scripts.custom.data",
    "scripts.custom.callback_includes",
    "scripts.custom.bombflags",
    "scripts.custom.ludo_trigger",
    "scripts.custom.statuseffects",
    "scripts.custom.tearvariants",
    "scripts.custom.throwables",

    "scripts.helper",

    "scripts.libraries.custom_object_spawn",

    "scripts.config",
    "scripts.savedata.save_data",

    "scripts.statuseffects.electrified",
    "scripts.statuseffects.overflowing",

    "scripts.bosses.toinclude",

    "scripts.players.milcom.toinclude",
    "scripts.players.atlas.toinclude",
    "scripts.players.jonas.toinclude",

    "scripts.items.toinclude",

    "scripts.modcompat.eid.eid",

    "scripts.toybox_imgui",

    "scripts.funny_shaders",

    --"scripts.test",
}
for _, path in ipairs(mod_files) do
    include(path)
end