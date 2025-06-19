

function ToyboxMod:playerHasLimitBreak(player)
    return true
end
function ToyboxMod:anyPlayerHasLimitBreak()
    return true
end
ToyboxMod.TRINKET_LIMIT_BREAK = 1

local t = {
    "scripts_toybox.items.trinkets.limit_break.the_wiz",
    "scripts_toybox.items.trinkets.limit_break.little_chad",
    "scripts_toybox.items.trinkets.limit_break.cott_cookbook", --* Curse of the Tower + Anarchist Cookbook
    "scripts_toybox.items.trinkets.limit_break.boom",
    "scripts_toybox.items.trinkets.limit_break.kamikaze",
    "scripts_toybox.items.trinkets.limit_break.shade",
    "scripts_toybox.items.trinkets.limit_break.the_jar",
    "scripts_toybox.items.trinkets.limit_break.obsessed_fan",
    "scripts_toybox.items.trinkets.limit_break.missing_page_2",
    "scripts_toybox.items.trinkets.limit_break.bum_friend",
    "scripts_toybox.items.trinkets.limit_break.bumbo",
    "scripts_toybox.items.trinkets.limit_break.portable_slot",
    "scripts_toybox.items.trinkets.limit_break.the_bean",
    "scripts_toybox.items.trinkets.limit_break.battery_pack",
    "scripts_toybox.items.trinkets.limit_break.brown_nugget",
    "scripts_toybox.items.trinkets.limit_break.moms_pad",
    "scripts_toybox.items.trinkets.limit_break.key_bum",
    "scripts_toybox.items.trinkets.limit_break.abel",
    "scripts_toybox.items.trinkets.limit_break.blood_rights",
    "scripts_toybox.items.trinkets.limit_break.linger_bean",
    "scripts_toybox.items.trinkets.limit_break.the_poop",
    "scripts_toybox.items.trinkets.limit_break.box",
    "scripts_toybox.items.trinkets.limit_break.magic_fingers",
    "scripts_toybox.items.trinkets.limit_break.pageant_boy",
    "scripts_toybox.items.trinkets.limit_break.a_quarter",
}
for _, path in ipairs(t) do
    include(path)
end