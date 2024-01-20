local t = {
    --ATLAS A
    "scripts.players.atlas.a.atlas",
    "scripts.players.atlas.a.stats",
    "scripts.players.atlas.a.character_helpers",
    "scripts.players.atlas.a.mantle_logic",

    --ATLAS B
}
for _, path in ipairs(t) do
    include(path)
end