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
    "scripts.items.passives.malicious_brain",
    "scripts.items.passives.obsidian_shard",
    "scripts.items.passives.obsidian_chunk",
    "scripts.items.passives.sigil_of_greed",
    "scripts.items.passives.dads_prescription",
    "scripts.items.passives.horse_tranquilizer",
    "scripts.items.passives.silk_bag",
    "scripts.items.passives.rock_candy",
    "scripts.items.passives.missing_page_3",
    "scripts.items.passives.glass_vessel",
    "scripts.items.passives.bone_boy",
    "scripts.items.passives.steel_soul",
    "scripts.items.passives.bobs_heart",
    "scripts.items.passives.clown_phd",
    "scripts.items.passives.giant_capsule",
    "scripts.items.passives.jonas_mask",

    "scripts.items.passives.the_elder_scroll", -- just the shader fo now

    --ACTIVES
    -- "scripts.items.actives.",
    "scripts.items.actives.pliers",
    "scripts.items.actives.blood_ritual",
    "scripts.items.actives.toy_gun",
    "scripts.items.actives.golden_tweezers",
    "scripts.items.actives.bronze_bull",
    "scripts.items.actives.ascension",
    "scripts.items.actives.gilded_apple",
    "scripts.items.actives.drill",
    "scripts.items.actives.d",
    "scripts.items.actives.pez_dispenser",
    "scripts.items.actives.alphabet_box",

    --TRINKETS
    -- "scripts.items.trinkets.",
    "scripts.items.trinkets.plasma_globe",
    "scripts.items.trinkets.foam_bullet",
    "scripts.items.trinkets.limit_break",
    "scripts.items.trinkets.wonder_drug",
    "scripts.items.trinkets.antibiotics",
    "scripts.items.trinkets.amber_fossil",
    "scripts.items.trinkets.sine_worm",
    "scripts.items.trinkets.big_blind",
    "scripts.items.trinkets.jonas_lock",

    --UNUSED
    --"scripts.items.actives.btrain",
    --"scripts.items.unused.laser_pointer",
    --"scripts.items.unused.scattered_tome",
}
for _, path in ipairs(t) do
    include(path)
end