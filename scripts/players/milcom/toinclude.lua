local t = {
    --MILCOM A
    "scripts.players.milcom.a.milcom",
    "scripts.players.milcom.a.stats",
    "scripts.players.milcom.a.character_helpers",
    "scripts.players.milcom.a.hopping_logic",
    "scripts.players.milcom.a.pickups_logic",
    "scripts.players.milcom.a.crafting_menu",

    --"scripts.players.milcom.a.craftables.",
    "scripts.players.milcom.a.craftables.makeshift_bomb",
    "scripts.players.milcom.a.craftables.makeshift_key",
    "scripts.players.milcom.a.craftables.credit_cardboard",
    
    "scripts.players.milcom.a.craftables.nailgun",
    "scripts.players.milcom.a.craftables.nailrifle",

    --MILCOM B
    "scripts.players.milcom.b.milcom",
    "scripts.players.milcom.b.stats",
    "scripts.players.milcom.b.closet_unlock",
}
for _, path in ipairs(t) do
    include(path)
end