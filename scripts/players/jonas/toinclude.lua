local t = {
    --JONAS A
    -- [[
    "scripts.players.jonas.a.jonas",
    "scripts.players.jonas.a.stats",
    "scripts.players.jonas.a.character_helpers",
    "scripts.players.jonas.a.achievements",
    "scripts.players.jonas.a.custom_pillpool",
    "scripts.players.jonas.a.pill_bonus_logic",
    "scripts.players.jonas.a.monster_pilldrop",
    --]]

    --JONAS B
    --"scripts.players.jonas.b.jonas",
    --"scripts.players.jonas.b.closet_unlock",
}
for _, path in ipairs(t) do
    include(path)
end