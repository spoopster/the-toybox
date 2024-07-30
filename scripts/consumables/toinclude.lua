local t = {
    --CARDS
    -- "scripts.consumables.cards.",
    -- nothing for now

    --PILLS
    -- "scripts.consumables.pills.",
    "scripts.consumables.pills.i_believe_i_can_fly",
    "scripts.consumables.pills.dyslexia",
    "scripts.consumables.pills.dementia",
    "scripts.consumables.pills.parasite",
    "scripts.consumables.pills.ossification",
    "scripts.consumables.pills.your_soul_is_mine",
    "scripts.consumables.pills.food_poisoning",
    --"scripts.consumables.pills.bleeegh",
    "scripts.consumables.pills.capsule",
    "scripts.consumables.pills.heartburn",
    "scripts.consumables.pills.coagulant",
    "scripts.consumables.pills.fent",
    "scripts.consumables.pills.arthritis",
    "scripts.consumables.pills.muscle_atrophy",
    "scripts.consumables.pills.vitamins",
    "scripts.consumables.pills.damage_up",
    "scripts.consumables.pills.damage_down",
}
for _, path in ipairs(t) do
    include(path)
end