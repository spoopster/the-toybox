local t = {
    --MILCOM A
    "scripts.players.milcom.a.milcom",
    "scripts.players.milcom.a.stats",
    "scripts.players.milcom.a.character_helpers",
    "scripts.players.milcom.a.hopping_logic",
    "scripts.players.milcom.a.ink_pickup",
    "scripts.players.milcom.a.pickup_logic",
    "scripts.players.milcom.a.ink_champion_drop",
    "scripts.players.milcom.a.hud_replacement",
    "scripts.players.milcom.a.champion_chance",
    "scripts.players.milcom.a.new_champions",
        "scripts.players.milcom.a.champions.drowned",
        "scripts.players.milcom.a.champions.fear",
        "scripts.players.milcom.a.champions.bouncy",

    --MILCOM B
    "scripts.players.milcom.b.milcom",
    "scripts.players.milcom.b.stats",
    "scripts.players.milcom.b.closet_unlock",
}
for _, path in ipairs(t) do
    include(path)
end