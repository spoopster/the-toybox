local t = {
    --SHYGALS
    "scripts_toybox.bosses.shygal.shygal_logic",

    --RED MEGALODON
    "scripts_toybox.bosses.red megalodon.red_megalodon_logic",

    "scripts_toybox.bosses.stageapi"
}
for _, path in ipairs(t) do
    include(path)
end