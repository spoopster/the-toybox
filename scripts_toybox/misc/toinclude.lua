local t = {
    --PILL POOL
    "scripts_toybox.misc.pill_pool_library",

    --CHAMPIONS
    "scripts_toybox.misc.champions.champion_chances",
    "scripts_toybox.misc.champions.mod_champion_logic",
        "scripts_toybox.misc.champions.champion_effects.bouncy",
        "scripts_toybox.misc.champions.champion_effects.drowned",
        "scripts_toybox.misc.champions.champion_effects.fear",

    --TINTED ROOMS
    "scripts_toybox.misc.tinted_rooms.enums",
    "scripts_toybox.misc.tinted_rooms.tinted_room_logic",
    "scripts_toybox.misc.tinted_rooms.minimap_logic",
}
for _, path in ipairs(t) do
    include(path)
end