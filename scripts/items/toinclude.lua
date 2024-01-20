local t = {
    --PASSIVES
    -- "scripts.items.passives.",
    "scripts.items.passives.slickwater",
    "scripts.items.passives.goat_milk",
    "scripts.items.passives.condensed_milk",
    "scripts.items.passives.nose_candy",
    "scripts.items.passives.lion_skull",

    --ACTIVES
    -- "scripts.items.actives.",
    "scripts.items.actives.bloody_needle",

    --TRINKETS
    -- "scripts.items.trinkets.",

}
for _, path in ipairs(t) do
    include(path)
end