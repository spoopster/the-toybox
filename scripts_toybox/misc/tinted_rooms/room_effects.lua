local RED_DMG = 1.2
local BLUE_TEARS = 1
local GREEN_LUCK = 5
local BROWN_SIZE = 0.5

local CYAN_FLY_INTERVAL = 30*3

local BLACK_RETRIGGERS = 2
local BLACK_CANCEL_RETRIGGER = false
local BLACK_INVALID_ROOMTYPES = {
    [RoomType.ROOM_BOSS] = true,
    [RoomType.ROOM_BOSSRUSH] = true,
}

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    local bits = ToyboxMod:getTintedRoomTint()
    if(flag==CacheFlag.CACHE_DAMAGE and ToyboxMod:hasTintedRoomTint("RED", bits)) then
        ToyboxMod:addBasicDamageUp(pl, RED_DMG)
    elseif(flag==CacheFlag.CACHE_FIREDELAY and ToyboxMod:hasTintedRoomTint("BLUE", bits)) then
        ToyboxMod:addBasicTearsUp(pl, BLUE_TEARS)
    elseif(flag==CacheFlag.CACHE_LUCK and ToyboxMod:hasTintedRoomTint("GREEN", bits)) then
        pl.Luck = pl.Luck+GREEN_LUCK
    elseif(flag==CacheFlag.CACHE_SIZE and ToyboxMod:hasTintedRoomTint("BROWN", bits)) then
        pl.SpriteScale = pl.SpriteScale*BROWN_SIZE
        pl.SizeMulti = pl.SizeMulti*BROWN_SIZE
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function blackRetriggerClear(_, _)
    local room = Game():GetRoom()
    if(not BLACK_CANCEL_RETRIGGER and ToyboxMod:hasTintedRoomTint("BLACK") and not BLACK_INVALID_ROOMTYPES[room:GetType()]) then
        BLACK_CANCEL_RETRIGGER = true
        for _=1, BLACK_RETRIGGERS do
            room:TriggerClear(true)
        end
        BLACK_CANCEL_RETRIGGER = false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_TRIGGER_CLEAR, blackRetriggerClear)

local function blackRetriggerClearPlayer(_, pl)
    if(not BLACK_CANCEL_RETRIGGER and ToyboxMod:hasTintedRoomTint("BLACK") and BLACK_INVALID_ROOMTYPES[Game():GetRoom():GetType()]) then
        BLACK_CANCEL_RETRIGGER = true
        for _=1, BLACK_RETRIGGERS do
            pl:TriggerRoomClear()
        end
        BLACK_CANCEL_RETRIGGER = false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, blackRetriggerClearPlayer)