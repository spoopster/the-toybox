local mod = MilcomMOD

function mod:playerHasLimitBreak(player)
    return player:HasTrinket(mod.TRINKET.LIMIT_BREAK)
end
function mod:anyPlayerHasLimitBreak()
    for i=0, Game():GetNumPlayers()-1 do
        if(mod:playerHasLimitBreak(Isaac.GetPlayer(i))) then return true end
    end
    return false
end

local t = {
    "scripts.items.trinkets.limit_break.the_wiz",
    "scripts.items.trinkets.limit_break.little_chad",
    "scripts.items.trinkets.limit_break.cott_cookbook", --* Curse of the Tower + Anarchist Cookbook
    "scripts.items.trinkets.limit_break.boom",
    "scripts.items.trinkets.limit_break.kamikaze",
    "scripts.items.trinkets.limit_break.shade",
    "scripts.items.trinkets.limit_break.the_jar",
    "scripts.items.trinkets.limit_break.obsessed_fan",
    "scripts.items.trinkets.limit_break.missing_page_2",
    "scripts.items.trinkets.limit_break.bum_friend",
    "scripts.items.trinkets.limit_break.bumbo",
    "scripts.items.trinkets.limit_break.portable_slot",
    "scripts.items.trinkets.limit_break.the_bean",
    "scripts.items.trinkets.limit_break.battery_pack",
    "scripts.items.trinkets.limit_break.brown_nugget",
    "scripts.items.trinkets.limit_break.moms_pad",
    "scripts.items.trinkets.limit_break.key_bum",
    "scripts.items.trinkets.limit_break.abel",
    "scripts.items.trinkets.limit_break.blood_rights",
    "scripts.items.trinkets.limit_break.linger_bean",
    "scripts.items.trinkets.limit_break.the_poop",
    "scripts.items.trinkets.limit_break.box",
    "scripts.items.trinkets.limit_break.magic_fingers",
    "scripts.items.trinkets.limit_break.pageant_boy",
    "scripts.items.trinkets.limit_break.a_quarter",
}
for _, path in ipairs(t) do
    include(path)
end