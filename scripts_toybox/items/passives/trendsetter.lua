local INVALID_ROOMTYPES = {
    [RoomType.ROOM_BOSS] = true,
    [RoomType.ROOM_BOSSRUSH] = true,
}

local function tryGetRewards(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_TRENDSETTER)) then return end

    local room = Game():GetRoom()
    if(INVALID_ROOMTYPES[room:GetType()]) then return end

    local occupiedIndexes = {}
    local nextindex = 1

    local pickups = {}
    local todel = {}
    for _, ent in ipairs(Isaac.FindByType(5)) do
        local pickup = ent:ToPickup()
        if(ent.FrameCount==0) then
            local idx = 0
            if(pickup and pickup.OptionsPickupIndex~=0) then
                if(occupiedIndexes[pickup.OptionsPickupIndex]) then
                    idx = occupiedIndexes[pickup.OptionsPickupIndex]
                else
                    idx = nextindex
                    occupiedIndexes[pickup.OptionsPickupIndex] = nextindex
                    nextindex = nextindex+1
                end
            end
            table.insert(pickups, {pickup.Type, pickup.Variant, pickup.SubType, idx})
            table.insert(todel, ent)
        end
    end

    if(#pickups==0) then return end

    if(ToyboxMod:getExtraData("TRENDSETTER_ACTIVE")) then
        local list = ToyboxMod:getExtraData("TRENDSETTER_LIST") or {}
        if(#list==0) then return end

        for _, ent in ipairs(todel) do
            ent:Remove()
            ent:Update()
        end

        local inverseOptions = {}
        for _, pickupdata in ipairs(list) do
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
            local ent = Isaac.Spawn(pickupdata[1], pickupdata[2], pickupdata[3], pos, Vector.Zero, nil)

            if(ent.Type==EntityType.ENTITY_PICKUP and pickupdata[4]~=0) then
                ent = ent:ToPickup() ---@type EntityPickup

                local idx = 0
                if(inverseOptions[pickupdata[4]]) then
                    idx = inverseOptions[pickupdata[4]]
                else
                    idx = ent:SetNewOptionsPickupIndex()
                    inverseOptions[pickupdata[4]] = idx
                end
                ent.OptionsPickupIndex = idx
            end
        end
    else
        ToyboxMod:setExtraData("TRENDSETTER_ACTIVE", true)
        ToyboxMod:setExtraData("TRENDSETTER_LIST", pickups)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, tryGetRewards)

local function resetTrendsetter(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end

    ToyboxMod:setExtraData("TRENDSETTER_ACTIVE", false)
    ToyboxMod:setExtraData("TRENDSETTER_LIST", {})
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetTrendsetter)