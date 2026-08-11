---@param pl EntityPlayer
---@param id Card
local function useTheIdol(_, id, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    local rng = pl:GetCardRNG(id)
    local destIdx = ToyboxMod:getRandomSpecialRoom("TEMPLE_ROOM", rng)
    if(not destIdx) then
        destIdx = ToyboxMod:getRandomSpecialRoom(RoomType.ROOM_CURSE, rng)
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
        ToyboxMod.GAME:MoveToRandomRoom(false, rng:Next(), pl)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheIdol, ToyboxMod.CARD_THE_IDOL)