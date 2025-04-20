local t = {
    --PICKUPS
    "scripts_toybox.pickups.pickups.black_soul",
    "scripts_toybox.pickups.pickups.blood_soul",

    "scripts_toybox.pickups.pickups.smorgasbord",

    "scripts_toybox.pickups.pickups.eternal_mound",

    --CARDS
    -- "scripts_toybox.pickups.cards.",
    "scripts_toybox.pickups.cards.prismstone",
    "scripts_toybox.pickups.cards.foil_card",
    -- nothing for now

    --OBJECTS
    "scripts_toybox.pickups.objects.mantle_rock",
    "scripts_toybox.pickups.objects.mantle_poop",
    "scripts_toybox.pickups.objects.mantle_bone",
    "scripts_toybox.pickups.objects.mantle_dark",
    "scripts_toybox.pickups.objects.mantle_holy",
    "scripts_toybox.pickups.objects.mantle_salt",
    "scripts_toybox.pickups.objects.mantle_glass",
    "scripts_toybox.pickups.objects.mantle_metal",
    "scripts_toybox.pickups.objects.mantle_gold",
    "scripts_toybox.pickups.objects.laurel",
    "scripts_toybox.pickups.objects.yanny",

    --PILLS
    -- "scripts_toybox.pickups.pills.",
    "scripts_toybox.pickups.pills.i_believe_i_can_fly",
    "scripts_toybox.pickups.pills.dyslexia",
    "scripts_toybox.pickups.pills.dementia",
    "scripts_toybox.pickups.pills.parasite",
    "scripts_toybox.pickups.pills.ossification",
    "scripts_toybox.pickups.pills.your_soul_is_mine",
    "scripts_toybox.pickups.pills.food_poisoning",
    --"scripts_toybox.pickups.pills.bleeegh",
    "scripts_toybox.pickups.pills.capsule",
    "scripts_toybox.pickups.pills.heartburn",
    "scripts_toybox.pickups.pills.coagulant",
    "scripts_toybox.pickups.pills.fent",
    "scripts_toybox.pickups.pills.arthritis",
    "scripts_toybox.pickups.pills.muscle_atrophy",
    "scripts_toybox.pickups.pills.vitamins",
    "scripts_toybox.pickups.pills.damage_up",
    "scripts_toybox.pickups.pills.damage_down",
}
for _, path in ipairs(t) do
    include(path)
end