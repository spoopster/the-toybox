

local ROOM_FREQ = 10

local CHEST_PICKER = WeightedOutcomePicker()
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_CHEST,        1)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_LOCKEDCHEST,  1)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_REDCHEST,     0.5)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_BOMBCHEST,    0.5)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_ETERNALCHEST, 0.1)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_SPIKEDCHEST,  0.1)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_MIMICCHEST,   0.1)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_WOODENCHEST,  0.5)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_MEGACHEST,    0.01)
CHEST_PICKER:AddOutcomeFloat(PickupVariant.PICKUP_HAUNTEDCHEST, 0.1)

---@param pl EntityPlayer
local function evalCache(_, pl)
    pl:CheckFamiliar(
        ToyboxMod.FAMILIAR_VARIANT.SACK_OF_CHESTS,
        pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SACK_OF_CHESTS),
        pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_SACK_OF_CHESTS),
        Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_SACK_OF_CHESTS)
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FAMILIARS)

---@param fam EntityFamiliar
local function familiarInit(_, fam)
    fam:AddToFollowers()
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarInit, ToyboxMod.FAMILIAR_VARIANT.SACK_OF_CHESTS)

---@param fam EntityFamiliar
local function familiarUpdate(_, fam)
    local sp = fam:GetSprite()
    fam:FollowParent()
    sp:Play("FloatDown")

    if(fam.RoomClearCount==ROOM_FREQ) then
        local rng = fam:GetDropRNG()

        local picked = CHEST_PICKER:PickOutcome(fam:GetDropRNG())
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(fam.Position)
        local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP,picked,0,pos,Vector.Zero,nil):ToPickup()

        fam.RoomClearCount = rng:RandomInt(2)
        sp:Play("Spawn", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiarUpdate, ToyboxMod.FAMILIAR_VARIANT.SACK_OF_CHESTS)