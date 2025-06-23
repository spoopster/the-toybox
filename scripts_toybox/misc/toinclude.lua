--PILL POOL
include("scripts_toybox.misc.pill_pool_library")

--CHAMPIONS
include("scripts_toybox.misc.champions.champion_chances")
include("scripts_toybox.misc.champions.mod_champion_logic")
    include("scripts_toybox.misc.champions.champion_effects.bouncy")
    include("scripts_toybox.misc.champions.champion_effects.drowned")
    include("scripts_toybox.misc.champions.champion_effects.fear")

--TINTED ROOMS
include("scripts_toybox.misc.tinted_rooms.enums")
include("scripts_toybox.misc.tinted_rooms.tinted_room_logic")
include("scripts_toybox.misc.tinted_rooms.minimap_logic")