---@param pl EntityPlayer
local function useTheCrypt(_, _, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    local level = Game():GetLevel()
    local secretidx
    for i=0, 168 do
        local room = level:GetRoomByIdx(i)
        if(ToyboxMod:isCustomSpecialRoom(room, "GRAVEYARD_ROOM")) then
            secretidx = room.SafeGridIndex
            break
        end
    end
    if(not secretidx) then
        for i=0, 168 do
            local room = level:GetRoomByIdx(i)
            if(room.Data and room.Data.Type==RoomType.ROOM_SUPERSECRET) then
                secretidx = room.SafeGridIndex
                break
            end
        end
    end
    if(secretidx) then
        Game():StartRoomTransition(secretidx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, pl)

        if(flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) then
            Isaac.CreateTimer(function()
                local room = Game():GetRoom()
                if(room:GetType()==RoomType.ROOM_SUPERSECRET and room:IsFirstVisit()) then
                    local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
                    local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, 0, pos, Vector.Zero, nil):ToPickup()
                end
            end, 1,1,true)
        end
    else
        pl:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, UseFlag.USE_NOANIM, -1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheCrypt, ToyboxMod.CARD_THE_CRYPT)