local mod = ToyboxMod
local sfx = SFXManager()

local NUM_RUNES = 3
local SPAWN_SPEED = 3

---@param pl EntityPlayer
local function usePrismstone(_, _, pl, _)
    local pool = Game():GetItemPool()
    local rng = pl:GetCardRNG(mod.CONSUMABLE.PRISMSTONE)

    local angleOffset = rng:RandomInt(math.floor(360/NUM_RUNES))

    local takenOptionGroups = {}
    for _, pickup in ipairs(Isaac.FindByType(5)) do
        takenOptionGroups[pickup:ToPickup().OptionsPickupIndex] = 1
    end
    local nextPickupGroup = #takenOptionGroups+1

    for i=1, NUM_RUNES do
        local dir = Vector.FromAngle(360*i/NUM_RUNES+angleOffset):Resized(SPAWN_SPEED)

        local runeId = pool:GetCard(math.max(1, rng:RandomInt(1<<32-1)), false, true, true)
        local rune = Isaac.Spawn(5,300,runeId,pl.Position,dir,pl):ToPickup()
        rune.OptionsPickupIndex = nextPickupGroup
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, usePrismstone, mod.CONSUMABLE.PRISMSTONE)