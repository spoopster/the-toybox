local t = {
    "scripts.enemies.stone creep.logic",
}
for _, path in ipairs(t) do
    include(path)
end