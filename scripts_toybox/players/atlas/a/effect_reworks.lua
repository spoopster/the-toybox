local mod = ToyboxMod

local t = {
    --[[
    "scripts_toybox.players.atlas.a.reimp.guppys_paw",
    "scripts_toybox.players.atlas.a.reimp.converter",
    "scripts_toybox.players.atlas.a.reimp.ossification",
    "scripts_toybox.players.atlas.a.reimp.satanic_bible",
    "scripts_toybox.players.atlas.a.reimp.gilded_apple",
    "scripts_toybox.players.atlas.a.reimp.yuck_heart",
    "scripts_toybox.players.atlas.a.reimp.yum_heart",
    "scripts_toybox.players.atlas.a.reimp.book_of_rev",
    "scripts_toybox.players.atlas.a.reimp.the_nail",
    "scripts_toybox.players.atlas.a.reimp.prayer_card",
    "scripts_toybox.players.atlas.a.reimp.steel_soul",
    --]]
    --"scripts.scripts_toybox.atlas.a.reimp.adrenaline",
    "scripts_toybox.players.atlas.a.reimp.blood_oath",
}
for _, path in ipairs(t) do
    include(path)
end
