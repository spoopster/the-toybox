

local ROOMS_REQ = 6
local BFFS_REQ = 4
local FIRST_SPAWN_REQ = 3
local YANNY_SPAWN_CHANCE = 0.001--0.5

---@param player EntityPlayer
local function checkFamiliars(_, player, cacheFlag)
    player:CheckFamiliar(
        ToyboxMod.FAMILIAR_VARIANT.SILK_BAG,
        player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SILK_BAG),
        player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_SILK_BAG),
        Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_SILK_BAG)
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, checkFamiliars, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function silkBagInit(_, familiar)
    familiar:AddToFollowers()
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, silkBagInit, ToyboxMod.FAMILIAR_VARIANT.SILK_BAG)

---@param familiar EntityFamiliar
local function silkBagUpdate(_, familiar)
    local sprite = familiar:GetSprite()
    if(sprite:IsFinished(sprite:GetAnimation())) then sprite:Play("FloatDown", true) end

    familiar:FollowParent()
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, silkBagUpdate, ToyboxMod.FAMILIAR_VARIANT.SILK_BAG)

local function postRoomClear(_, waves)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_VARIANT.SILK_BAG)) do
        fam = fam:ToFamiliar()
        local pl = (fam.Player or Isaac.GetPlayer())
        if(fam.RoomClearCount%(pl:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and BFFS_REQ or ROOMS_REQ)==FIRST_SPAWN_REQ) then
            fam:GetSprite():Play("Spawn", true)
            local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_SILK_BAG)
            if(rng:RandomFloat()<YANNY_SPAWN_CHANCE) then
                local yanny = Isaac.Spawn(5, 300, ToyboxMod.CONSUMABLE.YANNY,Game():GetRoom():FindFreePickupSpawnPosition(fam.Position),Vector.Zero,fam):ToPickup()
            else
                local laurel = Isaac.Spawn(5, 300, ToyboxMod.CONSUMABLE.LAUREL,Game():GetRoom():FindFreePickupSpawnPosition(fam.Position),Vector.Zero,fam):ToPickup()
            end
        end
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ROOM_CLEAR, postRoomClear)