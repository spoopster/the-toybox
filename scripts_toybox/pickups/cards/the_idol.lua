---@param pl EntityPlayer
local function useTheIdol(_, _, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    local level = ToyboxMod.GAME:GetLevel()
    local desiredIdx
    for i=0, 168 do
        local room = level:GetRoomByIdx(i)
        if(ToyboxMod:isCustomSpecialRoom(room, "TEMPLE_ROOM")) then
            desiredIdx = room.SafeGridIndex
            break
        end
    end
    if(not desiredIdx) then
        for i=0, 168 do
            local room = level:GetRoomByIdx(i)
            if(room.Data and room.Data.Type==RoomType.ROOM_CURSE) then
                desiredIdx = room.SafeGridIndex
                break
            end
        end
    end
    if(desiredIdx) then
        ToyboxMod.GAME:StartRoomTransition(desiredIdx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, pl)

        if(flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) then
            Isaac.CreateTimer(function()
                local room = ToyboxMod.GAME:GetRoom()
                if(room:GetType()==RoomType.ROOM_CURSE and room:IsFirstVisit()) then
                    for i=1, 5 do
                        local var = (i==1 and PickupVariant.PICKUP_COIN or 0)
                        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
                        local pickup = Isaac.Spawn(5,var,0,pos,Vector.Zero,nil)
                    end
                end
            end, 1,1,true)
        end
    else
        pl:UseActiveItem(CollectibleType.COLLECTIBLE_TELEPORT, UseFlag.USE_NOANIM, -1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheIdol, ToyboxMod.CARD_THE_IDOL)