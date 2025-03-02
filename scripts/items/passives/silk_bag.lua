local mod = MilcomMOD

local ROOMS_REQ = 6
local BFFS_REQ = 4
local FIRST_SPAWN_REQ = 3
local YANNY_SPAWN_CHANCE = 0.001--0.5

---@param player EntityPlayer
local function checkFamiliars(_, player, cacheFlag)
    player:CheckFamiliar(
        mod.FAMILIAR_VARIANT.SILK_BAG,
        player:GetCollectibleNum(mod.COLLECTIBLE.SILK_BAG),
        player:GetCollectibleRNG(mod.COLLECTIBLE.SILK_BAG),
        Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE.SILK_BAG)
    )
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, checkFamiliars, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function silkBagInit(_, familiar)
    familiar:AddToFollowers()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, silkBagInit, mod.FAMILIAR_VARIANT.SILK_BAG)

---@param familiar EntityFamiliar
local function silkBagUpdate(_, familiar)
    local sprite = familiar:GetSprite()
    if(sprite:IsFinished(sprite:GetAnimation())) then sprite:Play("FloatDown", true) end

    familiar:FollowParent()
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, silkBagUpdate, mod.FAMILIAR_VARIANT.SILK_BAG)

local function postRoomClear(_, waves)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_VARIANT.SILK_BAG)) do
        fam = fam:ToFamiliar()
        local pl = (fam.Player or Isaac.GetPlayer())
        if(fam.RoomClearCount%(pl:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and BFFS_REQ or ROOMS_REQ)==FIRST_SPAWN_REQ) then
            fam:GetSprite():Play("Spawn", true)
            local rng = pl:GetCollectibleRNG(mod.COLLECTIBLE.SILK_BAG)
            if(rng:RandomFloat()<YANNY_SPAWN_CHANCE) then
                local yanny = Isaac.Spawn(5, 300, mod.CONSUMABLE.YANNY,Game():GetRoom():FindFreePickupSpawnPosition(fam.Position),Vector.Zero,fam):ToPickup()
            else
                local laurel = Isaac.Spawn(5, 300, mod.CONSUMABLE.LAUREL,Game():GetRoom():FindFreePickupSpawnPosition(fam.Position),Vector.Zero,fam):ToPickup()
            end
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ROOM_CLEAR, postRoomClear)