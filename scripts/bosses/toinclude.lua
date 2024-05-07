local t = {
    --SHYGALS
    "scripts.bosses.shygal.shygal_logic",

    "scripts.bosses.stageapi"
}
for _, path in ipairs(t) do
    include(path)
end