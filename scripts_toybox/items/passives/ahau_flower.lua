local UPGRADED_VARIANTS = {
    [RoomType.ROOM_TREASURE] = function(sub, rng)
        if(sub==0) then
            return rng:RandomInt(1,2)
        elseif(sub<3) then
            return 3
        end
    end,
    [RoomType.ROOM_SHOP] = function(sub, rng)
        if(sub>=100) then return end

        if(sub==11) then sub = rng:RandomInt(0,4) end
        if(sub<=4 or sub==10) then
            return sub+100
        end
    end,
    [RoomType.ROOM_CURSE] = 1,
    [RoomType.ROOM_ARCADE] = 1,
    [RoomType.ROOM_DEVIL] = 1,
    [RoomType.ROOM_MINIBOSS] = function(sub, rng)
        if(sub>=0 and sub<7) then
            return sub+7
        end
    end,
    --[RoomType.ROOM_ANGEL] = 1, -- makes angel stairways but idk
}

---@param roomIdx integer
---@param rng RNG
local function getRoomSubtype(roomIdx, rng)
    if((ToyboxMod:getExtraData("AHAU_ROOM_SUBS") or {})[tostring(roomIdx)]) then return end

    local desc = Game():GetLevel():GetRoomByIdx(roomIdx, dim)
    if(not desc.Data) then return end
    if(desc.VisitedCount>0) then return -1 end

    if(UPGRADED_VARIANTS[desc.Data.Type]) then
        local upgrIdx = -1
        if(type(UPGRADED_VARIANTS[desc.Data.Type])=="function") then
            upgrIdx = UPGRADED_VARIANTS[desc.Data.Type](desc.Data.Subtype, rng) or -1
        else
            if(desc.Data.Subtype<UPGRADED_VARIANTS[desc.Data.Type]) then
                upgrIdx = UPGRADED_VARIANTS[desc.Data.Type]
            end
        end

        if(upgrIdx~=-1) then
            local roomset = RoomConfig.GetStage(StbType.SPECIAL_ROOMS):GetRoomSet(desc.Data.Mode)
            for i=0, #roomset-1 do
                local checkroom = roomset:Get(i)
                if(checkroom.Type==desc.Data.Type and checkroom.Subtype==upgrIdx) then
                    if(checkroom.Shape==desc.Data.Shape and (checkroom.Doors & desc.AllowedDoors == desc.AllowedDoors)) then
                        return upgrIdx
                    end
                end
            end
        end
    end

    return -1
end

local function markRoomSubtypes(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end
    if(ToyboxMod:getExtraData("AHAU_LEVEL_CHECK")==Game():GetLevel():GetDungeonPlacementSeed()) then return end

    ToyboxMod:setExtraData("AHAU_TRIGGERED", 0)
    ToyboxMod:setExtraData("AHAU_ROOM_SUBS", {})
    ToyboxMod:setExtraData("AHAU_ROOM_UPGR", {})

    ToyboxMod:setExtraData("AHAU_LEVEL_CHECK", Game():GetLevel():GetDungeonPlacementSeed())
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, markRoomSubtypes)

---@param ent GridEntity
local function tryGetSubtype(_, ent)
    local door = ent:ToDoor()

    local data = ToyboxMod:getExtraDataTable()

    markRoomSubtypes()

    local idx = getRoomSubtype(door.TargetRoomIndex, door:GetRNG())
    if(idx) then
        data.AHAU_ROOM_SUBS = data.AHAU_ROOM_SUBS or {}
        data.AHAU_ROOM_SUBS[tostring(door.TargetRoomIndex)] = idx
    end

    local shouldSpawnFlowers = false
    if((data.AHAU_ROOM_UPGR or {})[tostring(door.TargetRoomIndex)]) then
        shouldSpawnFlowers = true
    else
        local maxNum = PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_AHAU_FLOWER)
        if((data.AHAU_TRIGGERED or 0)<maxNum) then
            if(((data.AHAU_ROOM_SUBS or {})[tostring(door.TargetRoomIndex)] or -1)~=-1) then
                shouldSpawnFlowers = true
            end
        end
    end

    if(shouldSpawnFlowers) then
        local pos = Game():GetRoom():GetClampedPosition(ent.Position, 20)
        local flowers = Isaac.Spawn(1000, ToyboxMod.EFFECT_FLOWER_PATCH, 0, pos, Vector.Zero, nil):ToEffect()
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, tryGetSubtype, GridEntityType.GRID_DOOR)

local function tryUpgradeRoom(_, roomidx, dim)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_AHAU_FLOWER)) then return end

    local data = ToyboxMod:getExtraDataTable()
    local desc = Game():GetLevel():GetRoomByIdx(roomidx, dim)

    local pl = PlayerManager.GetRandomCollectibleOwner(ToyboxMod.COLLECTIBLE_AHAU_FLOWER, desc.SpawnSeed)
    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_AHAU_FLOWER)

    local subData = (desc.AHAU_ROOM_SUBS or {})[tostring(roomidx)] or -1
    if(subData==nil) then
        subData = getRoomSubtype(roomidx, rng)
    end

    if((subData or -1)~=-1) then
        local maxNum = PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_AHAU_FLOWER)
        if(desc.VisitedCount==0 and (desc.AHAU_TRIGGERED or 0)<maxNum) then
            local newRoom = RoomConfig.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, desc.Data.Type, desc.Data.Shape, nil, nil, nil, nil, desc.AllowedDoors, subData)
            if(newRoom) then
                desc.OverrideData = desc.Data
                desc.Data = newRoom
            end

            desc.AHAU_TRIGGERED = (desc.AHAU_TRIGGERED or 0)+1

            desc.AHAU_ROOM_UPGR = desc.AHAU_ROOM_UPGR or {}
            desc.AHAU_ROOM_UPGR[tostring(roomidx)] = true
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, tryUpgradeRoom)

local function spawnFlowersInUpgradedRoom()
    local idx = Game():GetLevel():GetCurrentRoomIndex()
    if((ToyboxMod:getExtraData("AHAU_ROOM_UPGR") or {})[tostring(idx)]) then
        local room = Game():GetRoom()
        local rng = ToyboxMod:generateRng(room:GetDecorationSeed())

        local possibleIndexes = {}
        for i=0, room:GetGridSize()-1 do
            if(not room:GetGridEntity(i)) then
                table.insert(possibleIndexes, i)
            end
        end

        local finalAmount = math.min(10, #possibleIndexes//8)
        while(#possibleIndexes>finalAmount) do
            table.remove(possibleIndexes, rng:RandomInt(1,#possibleIndexes))
        end

        for _, i in ipairs(possibleIndexes) do
            local pos = room:GetGridPosition(i)

            local eff = Isaac.Spawn(1000, ToyboxMod.EFFECT_FLOWER_PATCH, 0, pos, Vector.Zero, nil):ToEffect()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, spawnFlowersInUpgradedRoom)



---@param effect EntityEffect
local function flowerPatchInit(_, effect)
    local sp = effect:GetSprite()

    sp:Play("Idle", true)
    sp:SetFrame(math.random(sp:GetCurrentAnimationData():GetLength())-1)
    sp:Stop()

    effect.DepthOffset = -1000
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, flowerPatchInit, ToyboxMod.EFFECT_FLOWER_PATCH)

---@param effect EntityEffect
local function flowerPatchUpdate(_, effect)
    local room = Game():GetRoom()
    if(room:GetGridEntity(room:GetGridIndex(effect.Position))) then
        effect:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, flowerPatchUpdate, ToyboxMod.EFFECT_FLOWER_PATCH)