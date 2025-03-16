local mod = ToyboxMod

local t = {
    "scripts.players.atlas.a.reimp.guppys_paw",
    "scripts.players.atlas.a.reimp.converter",
    "scripts.players.atlas.a.reimp.ossification",
    "scripts.players.atlas.a.reimp.satanic_bible",
    "scripts.players.atlas.a.reimp.gilded_apple",
    "scripts.players.atlas.a.reimp.yuck_heart",
    "scripts.players.atlas.a.reimp.yum_heart",
    "scripts.players.atlas.a.reimp.book_of_rev",
    "scripts.players.atlas.a.reimp.the_nail",
    "scripts.players.atlas.a.reimp.prayer_card",
    "scripts.players.atlas.a.reimp.steel_soul",
}
for _, path in ipairs(t) do
    include(path)
end
