local t = {
    --ATLAS A
    -- [[
    "scripts.players.atlas.a.atlas",
    "scripts.players.atlas.a.stats",
    "scripts.players.atlas.a.character_helpers",
    "scripts.players.atlas.a.achievements",
    "scripts.players.atlas.a.mantle_logic",
    "scripts.players.atlas.a.mantle_spawn_logic",
    "scripts.players.atlas.a.mantle_devildeal_logic",
    "scripts.players.atlas.a.mantle_healing_logic",
        "scripts.players.atlas.a.chapi.mantle_healing_logic",
    "scripts.players.atlas.a.render_health",
    "scripts.players.atlas.a.horn_costumes",
    --"scripts.players.atlas.a.effect_reworks",
    --]]

    -- [[
    "scripts.players.atlas.a.mantles.tar",
    "scripts.players.atlas.a.mantles.rock",
    "scripts.players.atlas.a.mantles.poop",
    "scripts.players.atlas.a.mantles.bone",
    "scripts.players.atlas.a.mantles.dark",
    "scripts.players.atlas.a.mantles.holy",
    "scripts.players.atlas.a.mantles.salt",
    "scripts.players.atlas.a.mantles.glass",
    "scripts.players.atlas.a.mantles.metal",
    "scripts.players.atlas.a.mantles.gold",
    --]]

    --ATLAS B
    "scripts.players.atlas.b.atlas",
    "scripts.players.atlas.b.closet_unlock",
}
for _, path in ipairs(t) do
    include(path)
end