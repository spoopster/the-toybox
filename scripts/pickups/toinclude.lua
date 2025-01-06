local t = {
    --PICKUPS
    "scripts.pickups.pickups.black_soul",
    "scripts.pickups.pickups.blood_soul",

    --CARDS
    -- "scripts.pickups.cards.",
    "scripts.pickups.cards.prismstone",
    "scripts.pickups.cards.foil_card",
    -- nothing for now

    --OBJECTS
    "scripts.pickups.objects.mantle_rock",
    "scripts.pickups.objects.mantle_poop",
    "scripts.pickups.objects.mantle_bone",
    "scripts.pickups.objects.mantle_dark",
    "scripts.pickups.objects.mantle_holy",
    "scripts.pickups.objects.mantle_salt",
    "scripts.pickups.objects.mantle_glass",
    "scripts.pickups.objects.mantle_metal",
    "scripts.pickups.objects.mantle_gold",
    "scripts.pickups.objects.laurel",
    "scripts.pickups.objects.yanny",

    --PILLS
    -- "scripts.pickups.pills.",
    "scripts.pickups.pills.i_believe_i_can_fly",
    "scripts.pickups.pills.dyslexia",
    "scripts.pickups.pills.dementia",
    "scripts.pickups.pills.parasite",
    "scripts.pickups.pills.ossification",
    "scripts.pickups.pills.your_soul_is_mine",
    "scripts.pickups.pills.food_poisoning",
    --"scripts.pickups.pills.bleeegh",
    "scripts.pickups.pills.capsule",
    "scripts.pickups.pills.heartburn",
    "scripts.pickups.pills.coagulant",
    "scripts.pickups.pills.fent",
    "scripts.pickups.pills.arthritis",
    "scripts.pickups.pills.muscle_atrophy",
    "scripts.pickups.pills.vitamins",
    "scripts.pickups.pills.damage_up",
    "scripts.pickups.pills.damage_down",
}
for _, path in ipairs(t) do
    include(path)
end