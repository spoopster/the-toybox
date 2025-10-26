local RANGE_UP = 1.5
local ROOMS_REVEALED = 5

local INVALID_TYPES = {
    [RoomType.ROOM_ULTRASECRET] = true,
}

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_CURIOUS_CARROT)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_CURIOUS_CARROT)
    if(flag==CacheFlag.CACHE_RANGE) then
        pl.TearRange = pl.TearRange+RANGE_UP*mult*40
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
local function revealRooms(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_CURIOUS_CARROT)) then return end

    local numToReveal = ROOMS_REVEALED*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_CURIOUS_CARROT)

    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CURIOUS_CARROT)

    local level = Game():GetLevel()
    local rooms = level:GetRooms()
    local roomsNotVisible = {}

    for i = 0, #rooms-1 do
        local room = rooms:Get(i)

        if(room.Data and room.DisplayFlags == RoomDescriptor.DISPLAY_NONE) then
            if(not INVALID_TYPES[room.Data.Type]) then
                table.insert(roomsNotVisible, room)
            end
        end
    end

    local numRoomsTotal = #roomsNotVisible
    for _ = 1, numToReveal do
        local pickedIdx = rng:RandomInt(1, numRoomsTotal)
        roomsNotVisible[pickedIdx].DisplayFlags = RoomDescriptor.DISPLAY_ALL

        table.remove(roomsNotVisible, pickedIdx)
        numRoomsTotal = numRoomsTotal-1

        if(numRoomsTotal==0) then
            break
        end
    end

    level:UpdateVisibility()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, revealRooms)