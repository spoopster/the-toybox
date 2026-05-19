local sfx = SFXManager()

local NOT_COUNTED_ROOMTYPES = {
    [RoomType.ROOM_SECRET] = true,
    [RoomType.ROOM_SUPERSECRET] = true,
    [RoomType.ROOM_ULTRASECRET] = true,
    [RoomType.ROOM_BOSSRUSH] = true,
    [RoomType.ROOM_BOSS] = true,
}

local function checkStageCleared()
    local level = Game():GetLevel()

    local roomQueue = {}
    local visited = {}
    table.insert(roomQueue, level:GetRoomByIdx(level:GetStartingRoomIndex()))

    local idx = 1
    while(idx<=#roomQueue) do
        local curRoom = roomQueue[idx]
        visited[curRoom.SafeGridIndex] = true

        if(curRoom.Data and not NOT_COUNTED_ROOMTYPES[curRoom.Data.Type] and not curRoom.Clear) then
            return false
        end

        for _, neighborRoom in pairs(curRoom:GetNeighboringRooms()) do
            if(not visited[neighborRoom.SafeGridIndex]) then
                visited[neighborRoom.SafeGridIndex] = true
                table.insert(roomQueue, neighborRoom)
            end
        end

        idx = idx+1
    end

    return true
end

---@param delayed boolean
local function fullClearStageEffects(delayed)
    local extraTable = ToyboxMod:getExtraDataTable()
    local justMarkedAsFull = false

    if(not extraTable.MULAC_FULLCLEARED) then
        if(checkStageCleared()) then
            justMarkedAsFull = true
            extraTable.MULAC_FULLCLEARED = true
        end
    end

    if(extraTable.MULAC_FULLCLEARED and justMarkedAsFull) then
        local function triggerAllEffects()
            sfx:Play(SoundEffect.SOUND_HOLY)
            Game():GetHUD():ShowFortuneText("The Gods Smile Upon You!")

            for i=0, Game():GetNumPlayers()-1 do
                local pl = Isaac.GetPlayer(i)
                if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_MULAC_WATER)) then
                    ToyboxMod:addInnateCollectible(pl, CollectibleType.COLLECTIBLE_DEAD_DOVE, 1, "ForLevel_MulacWaterBoss", true)

                    --pl:AnimateHappy()
                end
            end
        end

        if(delayed) then
            ---@param eff EntityEffect
            Isaac.CreateTimer(function(eff)
                if(eff.FrameCount>3) then
                    triggerAllEffects()
                    eff:Remove()
                end
            end, 15, 2, true)
        else
            triggerAllEffects()
        end
    end
end

local function resetClearStatus(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end

    ToyboxMod:setExtraData("MULAC_FULLCLEARED", false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetClearStatus)

local function tryClearMapNewRoom(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_MULAC_WATER)) then return end

    local room = Game():GetRoom()
    if(room:IsClear()) then
        fullClearStageEffects(true)
    end

    if(Game():GetLevel():GetCurrentRoomIndex()==GridRooms.ROOM_DEVIL_IDX) then
        if(ToyboxMod:getExtraData("MULAC_FULLCLEARED")) then
            local owner = PlayerManager.FirstCollectibleOwner(ToyboxMod.COLLECTIBLE_MULAC_WATER) or Isaac.GetPlayer()
            owner:UseCard(Card.CARD_SOUL_ISAAC, UseFlag.USE_NOANIM | UseFlag.USE_NOHUD | UseFlag.USE_NOANNOUNCER)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, tryClearMapNewRoom)

local function tryClearMapRoomClear(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_MULAC_WATER)) then return end

    Isaac.CreateTimer(
        ---@param eff EntityEffect
        function(eff)
            if(eff.FrameCount>1) then
                fullClearStageEffects(false)
            end
        end,
        1,1,false
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_TRIGGER_CLEAR, tryClearMapRoomClear)

local function maxDealChance(_)
    if(ToyboxMod:getExtraData("MULAC_FULLCLEARED")) then
        return 1
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_SPECIAL_ITEMS, maxDealChance)