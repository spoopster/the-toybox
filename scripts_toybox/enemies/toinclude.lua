local t = {
    "scripts_toybox.enemies.stone creep.logic",
    "scripts_toybox.enemies.stumpy.logic",
}
for _, path in ipairs(t) do
    include(path)
end