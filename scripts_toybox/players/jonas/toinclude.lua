local t = {
    --JONAS A
    -- [[
    "scripts_toybox.players.jonas.a.jonas",
    "scripts_toybox.players.jonas.a.stats",
    "scripts_toybox.players.jonas.a.character_helpers",
    "scripts_toybox.players.jonas.a.custom_pillpool",
    "scripts_toybox.players.jonas.a.pill_bonus_logic",
    "scripts_toybox.players.jonas.a.monster_pilldrop",
    --]]

    --JONAS B
    --"scripts_toybox.players.jonas.b.jonas",
    --"scripts_toybox.players.jonas.b.closet_unlock",
}
for _, path in ipairs(t) do
    include(path)
end