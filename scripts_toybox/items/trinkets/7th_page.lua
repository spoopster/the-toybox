local sfx = SFXManager()

-- FIX IT DOUBLING DROPPED CONSUMABLES

local PICKUP_DOUBLE_CHANCE = 1/7

local VAR_WHITELIST = {
    [PickupVariant.PICKUP_HEART] = true,
    [PickupVariant.PICKUP_COIN] = true,
    [PickupVariant.PICKUP_BOMB] = true,
    [PickupVariant.PICKUP_KEY] = true,

    [PickupVariant.PICKUP_POOP] = true,

    [PickupVariant.PICKUP_CHEST] = true,
    [PickupVariant.PICKUP_BOMBCHEST] = true,
    [PickupVariant.PICKUP_SPIKEDCHEST] = true,
    [PickupVariant.PICKUP_ETERNALCHEST] = true,
    [PickupVariant.PICKUP_MIMICCHEST] = true,
    [PickupVariant.PICKUP_OLDCHEST] = true,
    [PickupVariant.PICKUP_WOODENCHEST] = true,
    [PickupVariant.PICKUP_MEGACHEST] = true,
    [PickupVariant.PICKUP_HAUNTEDCHEST] = true,
    [PickupVariant.PICKUP_LOCKEDCHEST] = true,
    [PickupVariant.PICKUP_BIGCHEST] = true,
    [PickupVariant.PICKUP_REDCHEST] = true,

    [PickupVariant.PICKUP_GRAB_BAG] = true,
    [PickupVariant.PICKUP_PILL] = true,
    [PickupVariant.PICKUP_LIL_BATTERY] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,

    [ToyboxMod.PICKUP_SMORGASBORD] = true,
    [ToyboxMod.PICKUP_LONELY_KEY] = true,
}

---@param pickup EntityPickup
local function pickupUpdate(_, pickup)
    if(pickup.FrameCount>1) then return end
    if(not VAR_WHITELIST[pickup.Variant]) then return end
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_7TH_PAGE)) then return end
    if(pickup:IsShopItem()) then return end
    if(ToyboxMod:getEntityData(pickup, "ALREADY_DOUBLE_CHECKED")) then return end

    local anim = pickup:GetSprite():GetAnimation()
    if(anim=="Appear" or anim=="AppearFast") then
        if(ToyboxMod:generateRng(pickup.InitSeed):RandomFloat()<PICKUP_DOUBLE_CHANCE) then
            local mult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_7TH_PAGE)
            local offset = Vector(0,-10)

            for i=1, mult do
                local newPos = pickup.Position+offset:Rotated(i*360/(mult+1))
                local newPickup = Isaac.Spawn(pickup.Type, pickup.Variant, pickup.SubType, newPos, pickup.Velocity, pickup.SpawnerEntity):ToPickup()
                newPickup.Wait = pickup.Wait
                newPickup.Timeout = pickup.Timeout
                newPickup.Parent = pickup.Parent
                if(anim=="AppearFast") then
                    newPickup:AppearFast()
                end

                newPickup:SetColor(Color(1,0.5,0.5,1,1,0,0), 30, 0, true, false)
                newPickup:SetDropDelay(pickup:GetDropDelay()+math.random(-2,2))

                ToyboxMod:setEntityData(newPickup, "ALREADY_DOUBLE_CHECKED", true)

                newPickup:Update()
            end
            pickup.Position = pickup.Position+offset

            sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING,1,nil,nil,1.2)
        end
    end

    ToyboxMod:setEntityData(pickup, "ALREADY_DOUBLE_CHECKED", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, pickupUpdate)