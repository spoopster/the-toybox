local t = {
    --MILCOM A
    "scripts_toybox.players.milcom.a.milcom",
    "scripts_toybox.players.milcom.a.stats",
    "scripts_toybox.players.milcom.a.character_helpers",
    "scripts_toybox.players.milcom.a.hopping_logic",
    "scripts_toybox.players.milcom.a.ink_pickup",
    "scripts_toybox.players.milcom.a.pickup_logic",
    "scripts_toybox.players.milcom.a.ink_champion_drop",
    "scripts_toybox.players.milcom.a.hud_replacement",
    "scripts_toybox.players.milcom.a.champion_chance",
    "scripts_toybox.players.milcom.a.new_champions",
        "scripts_toybox.players.milcom.a.champions.drowned",
        "scripts_toybox.players.milcom.a.champions.fear",
        "scripts_toybox.players.milcom.a.champions.bouncy",

    --MILCOM B
    "scripts_toybox.players.milcom.b.milcom",
    "scripts_toybox.players.milcom.b.stats",
    "scripts_toybox.players.milcom.b.closet_unlock",
}
for _, path in ipairs(t) do
    include(path)
end