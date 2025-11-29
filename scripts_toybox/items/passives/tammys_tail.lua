local sfx = SFXManager()

local CLEAR_RETRIGGERS = 1
local RETRIGGER_DELAY = 3

local CANCEL_RETRIGGER = false

local INVALID_ROOMTYPES = {
    [RoomType.ROOM_BOSS] = true,
    [RoomType.ROOM_BOSSRUSH] = true,
}

local function retriggerClear(_, _)
    if(CANCEL_RETRIGGER) then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_TAMMYS_TAIL)) then return end

    sfx:Play(ToyboxMod.SOUND_EFFECT.MEOW)

    local numRetriggers = CLEAR_RETRIGGERS*PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_TAMMYS_TAIL)
    local room = Game():GetRoom()

    Isaac.CreateTimer(
        function(_)
            CANCEL_RETRIGGER = true

            if(not INVALID_ROOMTYPES[room:GetType()]) then
                room:TriggerClear(true)
            end

            CANCEL_RETRIGGER = false
        end,
        RETRIGGER_DELAY,
        numRetriggers,
        false
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_TRIGGER_CLEAR, retriggerClear)

local function playerRetriggerClear(_, pl)
    if(CANCEL_RETRIGGER) then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_TAMMYS_TAIL)) then return end

    sfx:Play(ToyboxMod.SOUND_EFFECT.MEOW)

    local numRetriggers = CLEAR_RETRIGGERS*PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_TAMMYS_TAIL)

    Isaac.CreateTimer(
        function(_)
            CANCEL_RETRIGGER = true

            if(INVALID_ROOMTYPES[room:GetType()]) then
                pl:TriggerRoomClear()
            end

            CANCEL_RETRIGGER = false
        end,
        RETRIGGER_DELAY,
        numRetriggers,
        false
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, playerRetriggerClear)