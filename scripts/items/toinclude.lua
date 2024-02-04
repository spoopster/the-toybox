local t = {
    --PASSIVES
    -- "scripts.items.passives.",
    "scripts.items.passives.slickwater",
    "scripts.items.passives.goat_milk",
    "scripts.items.passives.condensed_milk",
    "scripts.items.passives.nose_candy",
    "scripts.items.passives.lion_skull",
    "scripts.items.passives.caramel_apple",

    --ACTIVES
    -- "scripts.items.actives.",
    "scripts.items.actives.bloody_needle",
    "scripts.items.actives.blood_ritual",

    --TRINKETS
    -- "scripts.items.trinkets.",

}
for _, path in ipairs(t) do
    include(path)
end