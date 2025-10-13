local REPLACE_CHANCE = 0.15

---@param firstTime boolean
---@param pl EntityPlayer
local function spawnPillOnPickup(_, _, _, firstTime, _, _, pl)
    if(not firstTime) then return end
    
    local pos = Game():GetRoom():FindFreePickupSpawnPosition(pl.Position, 40)
    local pill = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, pos, Vector.Zero, nil):ToPickup()

    local pool = Game():GetItemPool()
    local colors = ToyboxMod:getPillColorsInRun()
    for _, colData in ipairs(colors) do
        pool:IdentifyPill(colData.COLOR)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, spawnPillOnPickup, ToyboxMod.COLLECTIBLE_READING_GLASSES)

---@param pickup EntityPickup
local function unidentifySpawnedPill(_, pickup)
    if(PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_READING_GLASSES)) then
        Game():GetItemPool():IdentifyPill(pickup.SubType & (~PillColor.PILL_GIANT_FLAG))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, unidentifySpawnedPill, PickupVariant.PICKUP_PILL)

local cancelReplacementRecursion = false

---@param pickup EntityPickup
local function replaceCardWithPill(_, pickup)
    if(cancelReplacementRecursion) then return end

    if(pickup.FrameCount==0) then
        ToyboxMod:setEntityData(pickup, "READING_GLASSES_DROPPED_CARD", true)
    elseif(pickup.FrameCount~=1) then
        return
    end

    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_READING_GLASSES)) then return end
    if(ToyboxMod:getEntityData(pickup, "READING_GLASSES_DROPPED_CARD")) then return end

    if(ToyboxMod:generateRng(pickup.InitSeed):RandomFloat()<REPLACE_CHANCE*PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_READING_GLASSES)) then
        cancelReplacementRecursion = true
        pickup:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,0)
        cancelReplacementRecursion = false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, replaceCardWithPill, PickupVariant.PICKUP_TAROTCARD)

---@param pickup EntityPickup
local function invalidateDroppedCard(_, _, pickup)
    ToyboxMod:setEntityData(pickup, "READING_GLASSES_DROPPED_CARD", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_DROP_CARD, invalidateDroppedCard)