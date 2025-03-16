local mod = ToyboxMod

local POOPS_WITH_DROPS = {
    [GridPoopVariant.NORMAL] = 1,
    [GridPoopVariant.CHUNKY] = 1,
    [GridPoopVariant.HOLY] = 1,
}

---@param poop GridEntityPoop
local function checkPoopPickup(_, poop, poopVar)
    if(POOPS_WITH_DROPS[poopVar]~=1) then return end

    local data = mod:getGridEntityDataTable(poop)

    local selPickup
    for _, pickup in ipairs(Isaac.FindByType(5)) do
        if(pickup.Position:Distance(poop.Position)<2) then
            if(pickup.FrameCount==1) then
                selPickup = pickup:ToPickup()
                break
            end
        end
    end

    local pickupSpawnData = Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POOP_SPAWN_DROP, selPickup, poop)

    if(type(pickupSpawnData)=="userdata") then
        if(selPickup) then
            selPickup:Remove()
        end
        selPickup = pickupSpawnData.NewPickup
    elseif(type(pickupSpawnData)=="table") then
        if(not selPickup) then
            selPickup = Isaac.Spawn(pickupSpawnData.Type, pickupSpawnData.Variant, pickupSpawnData.SubType, poop.Position, Vector.Zero, nil)
        else
            selPickup:Morph((pickupSpawnData.Type or selPickup.Type), (pickupSpawnData.Variant or 0), (pickupSpawnData.SubType or 0))
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_POOP_DESTROY, checkPoopPickup)