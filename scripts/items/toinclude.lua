local t = {
    --PASSIVES
    -- "scripts.items.passives.",
    "scripts.items.passives.coconut_oil",
    "scripts.items.passives.goat_milk",
    "scripts.items.passives.condensed_milk",
    "scripts.items.passives.nose_candy",
    "scripts.items.passives.lion_skull",
    "scripts.items.passives.caramel_apple",
    "scripts.items.passives.painkillers",
    "scripts.items.passives.tech_ix",
    "scripts.items.passives.mammons_offering",
    --"scripts.items.passives.paint_bucket",
    "scripts.items.passives.fatal_signal",
    "scripts.items.passives.pepper_x",
    "scripts.items.passives.meteor_shower",
    "scripts.items.passives.blessed_ring",

    "scripts.items.passives.the_elder_scroll", -- just the shader fo now

    --ACTIVES
    -- "scripts.items.actives.",
    "scripts.items.actives.bloody_needle",
    "scripts.items.actives.blood_ritual",
    "scripts.items.actives.silk_bag",
    "scripts.items.actives.toy_gun",

    --TRINKETS
    -- "scripts.items.trinkets.",
    "scripts.items.trinkets.plasma_globe",
    "scripts.items.trinkets.foam_bullet",

    --UNUSED
    -- "scripts.items.unused.laser_pointer",
}
for _, path in ipairs(t) do
    include(path)
end