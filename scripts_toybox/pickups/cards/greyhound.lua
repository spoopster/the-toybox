local RESPAWN_CHANCE = 0.66

local ROOM_HIERARCHY = {
    RoomType.ROOM_SUPERSECRET,
    RoomType.ROOM_SHOP,
    RoomType.ROOM_TREASURE,
    RoomType.ROOM_SACRIFICE,
    RoomType.ROOM_DICE,
    RoomType.ROOM_LIBRARY,
    "GRAVEYARD_ROOM",
    RoomType.ROOM_CURSE,
    "TEMPLE_ROOM",
    RoomType.ROOM_MINIBOSS,
    RoomType.ROOM_CHALLENGE,
    RoomType.ROOM_BARREN,
    RoomType.ROOM_ISAACS,
    RoomType.ROOM_ARCADE,
    RoomType.ROOM_CHEST,
    RoomType.ROOM_PLANETARIUM,
    RoomType.ROOM_SECRET,
    --RoomType.ROOM_ERROR,
}

---@param id Card
---@param pl EntityPlayer
---@param flags UseFlag
local function useGreyhound(_, id, pl, flags)
    local foundRoom = nil

    local rng = pl:GetCardRNG(id)
    local level = ToyboxMod.GAME:GetLevel()
    for _, roomType in ipairs(ROOM_HIERARCHY) do
        if(foundRoom) then break end

        foundRoom = ToyboxMod:getRandomSpecialRoom(roomType, rng, nil, false)
    end

    if(not foundRoom) then
        foundRoom = GridRooms.ROOM_ERROR_IDX
    end

    ToyboxMod.GAME:StartRoomTransition(foundRoom, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, pl)
    if((flags & UseFlag.USE_OWNED == UseFlag.USE_OWNED) and (flags & UseFlag.USE_MIMIC == 0)) then
        if(rng:RandomFloat()<RESPAWN_CHANCE) then
            Isaac.CreateTimer(
                function()
                    local pos = ToyboxMod.GAME:GetRoom():FindFreePickupSpawnPosition(pl.Position, 50)
                    local card = Isaac.Spawn(5,PickupVariant.PICKUP_TAROTCARD,ToyboxMod.CARD_GREYHOUND,pos,Vector.Zero,nil)
                end,
                1, 1, true
            )
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useGreyhound, ToyboxMod.CARD_GREYHOUND)