---@param pl EntityPlayer
---@param id Card
local function useTheCrypt(_, id, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    local rng = pl:GetCardRNG(id)
    local destIdx = ToyboxMod:getRandomSpecialRoom("GRAVEYARD_ROOM", rng)
    if(not destIdx) then
        destIdx = ToyboxMod:getRandomSpecialRoom(RoomType.ROOM_SUPERSECRET, rng)
    end
    if(destIdx) then
        ToyboxMod.GAME:StartRoomTransition(destIdx, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, pl)

        if(flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) then
            Isaac.CreateTimer(function()
                local room = ToyboxMod.GAME:GetRoom()
                if(room:GetType()==RoomType.ROOM_SUPERSECRET and room:IsFirstVisit()) then
                    local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
                    local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, 0, pos, Vector.Zero, nil):ToPickup()
                end
            end, 1,1,true)
        end
    else
        ToyboxMod.GAME:MoveToRandomRoom(false, rng:Next(), pl)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheCrypt, ToyboxMod.CARD_THE_CRYPT)