local INVALID_ROOMTYPES = {
    [RoomType.ROOM_BOSS] = true,
    [RoomType.ROOM_BOSSRUSH] = true,
}

local function tryGetRewards(_)
    local room = ToyboxMod.GAME:GetRoom()
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

    if(#pickups==0) then
        if(ToyboxMod:getExtraData("MONOCLE_SPAWNS") and PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_MONOCLE)) then
            for _=1, PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_MONOCLE) do
                local inverseOptions = {}
                for _, pickupdata in ipairs(ToyboxMod:getExtraData("MONOCLE_SPAWNS")) do
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
            end

            ToyboxMod.SFX:Play(SoundEffect.SOUND_CASH_REGISTER)
        end
    else
        ToyboxMod:setExtraData("MONOCLE_SPAWNS", pickups)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, tryGetRewards)