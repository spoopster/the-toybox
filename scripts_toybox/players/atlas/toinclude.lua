local t = {
    --ATLAS A
    -- [[
    "scripts_toybox.players.atlas.a.atlas",
    --"scripts_toybox.players.atlas.a.stats",
    "scripts_toybox.players.atlas.a.character_helpers",
    "scripts_toybox.players.atlas.a.achievements",
    "scripts_toybox.players.atlas.a.mantle_logic",
    "scripts_toybox.players.atlas.a.mantle_spawn_logic",
    "scripts_toybox.players.atlas.a.mantle_devildeal_logic",
    "scripts_toybox.players.atlas.a.mantle_healing_logic",
    "scripts_toybox.players.atlas.a.mantle_descriptions",
    "scripts_toybox.players.atlas.a.render_health",

    "scripts_toybox.players.atlas.a.horn_costumes",
    --"scripts_toybox.players.atlas.a.effect_reworks",
    --]]

    -- [[
    "scripts_toybox.players.atlas.a.mantles.tar",
    "scripts_toybox.players.atlas.a.mantles.rock",
    "scripts_toybox.players.atlas.a.mantles.poop",
    "scripts_toybox.players.atlas.a.mantles.bone",
    "scripts_toybox.players.atlas.a.mantles.dark",
    "scripts_toybox.players.atlas.a.mantles.holy",
    "scripts_toybox.players.atlas.a.mantles.salt",
    "scripts_toybox.players.atlas.a.mantles.glass",
    "scripts_toybox.players.atlas.a.mantles.metal",
    "scripts_toybox.players.atlas.a.mantles.gold",
    --]]

    --ATLAS B
    "scripts_toybox.players.atlas.b.atlas",
    "scripts_toybox.players.atlas.b.closet_unlock",
}
for _, path in ipairs(t) do
    include(path)
end