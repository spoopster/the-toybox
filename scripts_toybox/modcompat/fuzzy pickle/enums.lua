local ref = { Actives={}, Passives={}, Trinkets={} }

---@param id CollectibleType
---@param reference string
---@param partial boolean?
function ToyboxMod:addReferenceItem(id, reference, partial)
    local conf = Isaac.GetItemConfig():GetCollectible(id)
    
    if(conf.Type==ItemType.ITEM_ACTIVE) then
        table.insert(ref.Actives, {
            ID = id,
            Reference = reference,
            Partial = partial,
        })
    else
        table.insert(ref.Passives, {
            ID = id,
            Reference = reference,
            Partial = partial,
        })
    end
end

---@param id TrinketType
---@param reference string
---@param partial boolean?
function ToyboxMod:addReferenceTrinket(id, reference, partial)
    table.insert(ref.Trinkets, {
        ID = id,
        Reference = reference,
        Partial = partial,
    })
end



--ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_EVIL_ROCK, "Twitter")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_PLIERS, "Inscryption", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_ODD_ONION, "Slime Rancher")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_SILK_BAG, "Castlevania")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_HOSTILE_TAKEOVER, "Nuclear Throne", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_STEEL_SOUL, "Hollow Knight")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_GIANT_CAPSULE, "Dr. Mario")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_4_4, "Pokémon")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_JONAS_MASK, "Enter the Gungeon", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_DRILL, "PAYDAY 2")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_LOVE_LETTER, "Mario from Hell")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_ATHEISM, "Reddit", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_MAYONAISE, "Doodledude")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_AWESOME_FRUIT, "The Battle Cats")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_CURSED_EULOGY, "Risk of Rain 2")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_BLOODY_WHISTLE, "Creepypastas")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_ART_OF_WAR, "The Art of War")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_BARBED_WIRE, "The Legend of Bum-Bo")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_BIG_BANG, "The Big Bang Theory", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_LAST_BEER, "MF DOOM")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_CHOCOLATE_BAR, "Chocolate Mod")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_EXORCISM_KIT, "The Legend of Bum-Bo")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_RETROFALL, "RETROFALL")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_DELIVERY_BOX, "Amazon™")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_LUCKY_PEBBLES, "Cereal")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_HEMOLYMPH, "Morbius", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_SOLAR_PANEL, "Solar", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_SURPRISE_EGG, "Kinder Eggs", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_COLOSSAL_ORB, "The Battle Cats")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_BABY_SHOES, "Miscarriage")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_PYRAMID_SCHEME, "Insane Monopoly: Pyramid Scheme Expansion")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_GOOD_JUICE, "Juice Galaxy")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_BUTTERFLY_EFFECT, "SwApFell: I Hate You.", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_RED_CLOVER, "Wizard of Legend", true)

ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_CATHARSIS, "DELTATRAVELER", true)
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_GOLDEN_PRAYER_CARD, "Lazy MattPack")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_GOLDEN_SCHOOLBAG, "Lazy MattPack")
ToyboxMod:addReferenceItem(ToyboxMod.COLLECTIBLE_SUPER_HAMBURGER, "Spoop")




ToyboxMod:addReferenceTrinket(ToyboxMod.TRINKET_BIG_BLIND, "Balatro")
ToyboxMod:addReferenceTrinket(ToyboxMod.TRINKET_BATH_WATER, "Edmund McMillen")
ToyboxMod:addReferenceTrinket(ToyboxMod.TRINKET_YELLOW_BELT, "The Legend of Bum-Bo")
ToyboxMod:addReferenceTrinket(ToyboxMod.TRINKET_KILLSCREEN, "PacMan")

return ref