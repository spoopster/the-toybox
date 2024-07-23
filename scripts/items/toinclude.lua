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
    "scripts.items.passives.eyestrain",
    "scripts.items.passives.4_4",
    "scripts.items.passives.scattered_tome",
    "scripts.items.passives.malicious_brain",
    "scripts.items.passives.obsidian_shard",
    "scripts.items.passives.obsidian_chunk",
    "scripts.items.passives.sigil_of_greed",

    "scripts.items.passives.the_elder_scroll", -- just the shader fo now

    --ACTIVES
    -- "scripts.items.actives.",
    "scripts.items.actives.pliers",
    "scripts.items.actives.blood_ritual",
    "scripts.items.actives.silk_bag",
    "scripts.items.actives.toy_gun",
    "scripts.items.actives.golden_tweezers",
    "scripts.items.actives.bronze_bull",

    --TRINKETS
    -- "scripts.items.trinkets.",
    "scripts.items.trinkets.plasma_globe",
    "scripts.items.trinkets.foam_bullet",
    "scripts.items.trinkets.limit_break",

    --UNUSED
    --"scripts.items.unused.laser_pointer",
}
for _, path in ipairs(t) do
    include(path)
end