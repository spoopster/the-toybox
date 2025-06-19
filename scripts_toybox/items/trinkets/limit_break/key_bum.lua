
--* Chests spawned by Key Bum auto-open after a few frames

local OPEN_FRAMES = 2

local chests = {
    [PickupVariant.PICKUP_CHEST] = 0,
    [PickupVariant.PICKUP_LOCKEDCHEST] = 0,
    [PickupVariant.PICKUP_REDCHEST] = 0,
    [PickupVariant.PICKUP_BOMBCHEST] = 0,
    [PickupVariant.PICKUP_ETERNALCHEST] = 0,
    [PickupVariant.PICKUP_SPIKEDCHEST] = 0,
    [PickupVariant.PICKUP_MIMICCHEST] = 0,
    [PickupVariant.PICKUP_OLDCHEST] = 0,
    [PickupVariant.PICKUP_WOODENCHEST] = 0,
    [PickupVariant.PICKUP_MEGACHEST] = 0,
    [PickupVariant.PICKUP_HAUNTEDCHEST] = 0,
    [PickupVariant.PICKUP_MOMSCHEST] = 0,
}

---@param fam EntityFamiliar
local function postFamUpdate(_, fam)
    if(not (fam.Player and ToyboxMod:playerHasLimitBreak(fam.Player))) then return end

    local sp = fam:GetSprite()
    if(sp:GetAnimation()=="Spawn" and sp:GetFrame()==0) then
        for _, pickup in ipairs(Isaac.FindByType(5)) do
            if(chests[pickup.Variant]==0 and pickup.FrameCount==0) then
                ToyboxMod:setEntityData(pickup, "TIMED_CHEST_OPEN", {OPEN_FRAMES, fam.Player or Isaac.GetPlayer()})
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, postFamUpdate, FamiliarVariant.KEY_BUM)
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, postFamUpdate, FamiliarVariant.SUPER_BUM)

---@param pickup EntityPickup
local function postChestUpdate(_, pickup)
    if(chests[pickup.Variant]~=0) then return end
    local data = ToyboxMod:getEntityDataTable(pickup)

    if(data.TIMED_CHEST_OPEN and data.TIMED_CHEST_OPEN[1]>=0) then
        if(data.TIMED_CHEST_OPEN[1]==0) then
            local opened = pickup:TryOpenChest(data.TIMED_CHEST_OPEN[2])
            if(opened) then data.TIMED_CHEST_OPEN=nil end
        else
            data.TIMED_CHEST_OPEN[1] = data.TIMED_CHEST_OPEN[1]-1
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postChestUpdate)