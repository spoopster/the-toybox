
local sfx = SFXManager()

--#region DATA

---@param player EntityPlayer
function ToyboxMod:getAtlasATable(player)
    local tb = ToyboxMod:getEntityDataTable(player).ATLAS_A_DATA
    if(type(tb)~="table") then
	ToyboxMod:setEntityData(player, "ATLAS_A_DATA", ToyboxMod:cloneTable(ToyboxMod.ATLAS_A_BASEDATA))
    end

    return ToyboxMod:getEntityDataTable(player).ATLAS_A_DATA or {}
end
---@param player EntityPlayer
---@param key string
function ToyboxMod:getAtlasAData(player, key)
    return ToyboxMod:getAtlasATable(player)[key]
end
---@param player EntityPlayer
---@param key string
function ToyboxMod:setAtlasAData(player, key, val)
    ToyboxMod:getAtlasATable(player)[key] = val
end

--#endregion
function ToyboxMod:isAtlasA(player)
    local pt = player:GetPlayerType()
    return (pt==ToyboxMod.PLAYER_ATLAS_A or pt==ToyboxMod.PLAYER_ATLAS_A_TAR)
end
function ToyboxMod:isAnyPlayerAtlasA()
    for i=0, Game():GetNumPlayers()-1 do
        if(ToyboxMod:isAtlasA(Isaac.GetPlayer(i))) then
            return true
        end
    end
    return false
end

function ToyboxMod:getAllAtlasA()
    local t = {}
    for i=0, Game():GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(i):ToPlayer()
        if(ToyboxMod:isAtlasA(p)) then t[#t+1] = p end
    end

    return t
end

function ToyboxMod:areAllPlayersAtlasA()
    return #ToyboxMod:getAllAtlasA()==Game():GetNumPlayers()
end

function ToyboxMod:atlasHasTransformation(player, transformation)
    return (ToyboxMod:getAtlasAData(player, "TRANSFORMATION")==transformation or ToyboxMod:getAtlasAData(player, "BIRTHRIGHT_TRANSFORMATION")==transformation)
end

function ToyboxMod:getRightmostMantleIdx(player)
    local mantles = ToyboxMod:getAtlasAData(player, "MANTLES")

    for i=ToyboxMod:getAtlasAData(player, "HP_CAP"), 1, -1 do
        if(mantles[i].TYPE~=ToyboxMod.MANTLE_DATA.NONE.ID) then return i end
    end

    return 0
end

function ToyboxMod:getCurrentTransformationType(player)
    local mantles = ToyboxMod:getAtlasAData(player, "MANTLES")

    local isSameMantle = true
    for i=1, ToyboxMod:getAtlasAData(player, "HP_CAP") do
        if(mantles[i].TYPE~=mantles[1].TYPE) then
            isSameMantle = false
        end
    end

    if(isSameMantle) then
        if(mantles[1].TYPE==ToyboxMod.MANTLE_DATA.NONE.ID) then return ToyboxMod.MANTLE_DATA.TAR.ID end
        return mantles[1].TYPE
    end
    return ToyboxMod.MANTLE_DATA.DEFAULT.ID
end

function ToyboxMod:setMantleType(player, idx, hpOverride, mtype)
    local data = ToyboxMod:getAtlasATable(player)

    mtype = mtype or ToyboxMod.MANTLE_DATA.DEFAULT.ID
    local mHp = ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(mtype)].HP or ToyboxMod.MANTLE_DATA.DEFAULT.HP

    local oldD = data.MANTLES[math.min(idx, data.HP_CAP)]
    data.MANTLES[math.min(idx, data.HP_CAP)] = {
        TYPE = mtype,
        HP = hpOverride or mHp,
        MAXHP = mHp,
        COLOR = oldD.COLOR or Color(1,1,1,1),
        DATA = {},
    }
    Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_ATLAS_ADD_MANTLE, mtype, idx, mtype, player)

    ToyboxMod:updateMantles(player)
end

---@return boolean hpChanged Returns true if the mantle HP changed
function ToyboxMod:addMantleHp(player, hpToAdd)
    local data = ToyboxMod:getAtlasATable(player)

    local oldMantles = ToyboxMod:cloneTable(data.MANTLES)

    if(hpToAdd<0 and Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0) then
        local rIdx = ToyboxMod:getRightmostMantleIdx(player)
        data.MANTLES[rIdx].HP = data.MANTLES[rIdx].HP+hpToAdd
        ToyboxMod:spawnShardsForMantle(player, rIdx, 5)
    elseif(hpToAdd>0) then
        data.MANTLES[1].HP = data.MANTLES[1].HP+hpToAdd
    end

    ToyboxMod:updateMantles(player)

    for key,val in ipairs(oldMantles) do
        if(not (val.TYPE==data.MANTLES[key].TYPE and val.HP==data.MANTLES[key].HP and val.MAXHP==data.MANTLES[key].MAXHP)) then return true end
    end
    return false
end

function ToyboxMod:hasMaxMantleHp(player)
    local data = ToyboxMod:getAtlasATable(player)

    for _,val in ipairs(data.MANTLES) do
        if(val.HP~=val.MAXHP) then return false end
    end

    return true
end

function ToyboxMod:getHeldMantle(player)
    local card = player:GetCard(0)
    for _, dt in pairs(ToyboxMod.MANTLE_DATA) do
        if(dt.ID>0 and dt.ID<1000 and dt.CONSUMABLE_SUBTYPE==card) then
            return dt.ID
        end
    end
    return ToyboxMod.MANTLE_DATA.NONE.ID
end

function ToyboxMod:getSelMantleIdToDestroy(player, type)
    if(type==ToyboxMod.MANTLE_DATA.NONE.ID) then return 0 end
    local data = ToyboxMod:getAtlasATable(player)
    local rIdx = ToyboxMod:getRightmostMantleIdx(player)

    if(rIdx~=data.HP_CAP) then return rIdx+1 end

    for i=1, rIdx do
        if(data.MANTLES[i].TYPE~=type) then return i end
    end

    return 1
end

function ToyboxMod:giveMantle(player, type)
    local heartburnMode = ToyboxMod:getEntityData(player, "HEARTBURN_MODE")
    if(heartburnMode~=2) then
        local rIdx = ToyboxMod:getRightmostMantleIdx(player)
        local data = ToyboxMod:getAtlasATable(player)

        if(type==nil or type==ToyboxMod.MANTLE_DATA.NONE.ID) then
            type = ToyboxMod:getHeldMantle(player)
        end

        if(rIdx==data.HP_CAP) then
            local idx = ToyboxMod:getSelMantleIdToDestroy(player, type)
            if(type==ToyboxMod.MANTLE_DATA.NONE.ID) then idx=1 end
            local selMType = data.MANTLES[idx].TYPE
            
            ToyboxMod:spawnShardsForMantle(player, idx, 10)
            sfx:Play(ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(selMType) or "DEFAULT"].BREAK_SFX)

            for i=idx+1, rIdx do
                data.MANTLES[i-1] = ToyboxMod:cloneTable(data.MANTLES[i])
            end

            rIdx=rIdx-1
        end

        ToyboxMod:setMantleType(player, rIdx+1, nil, type)
        if(heartburnMode==1) then
            data.MANTLES[rIdx+1].HP = math.max(0,data.MANTLES[rIdx+1].HP-1)
        end
        
        data.MANTLES[rIdx+1].COLOR = Color(1,1,1,1,1,0,0)

        ToyboxMod:updateMantles(player)
    end
    --sfx:Play(ToyboxMod.SFX_ATLASA_ROCKBREAK, 0.3)
end

function ToyboxMod:isBadMantle(mantle)
    if(mantle==ToyboxMod.MANTLE_DATA.DEFAULT.ID) then return true end
    if(mantle==ToyboxMod.MANTLE_DATA.NONE.ID) then return true end
    if(mantle==ToyboxMod.MANTLE_DATA.TAR.ID) then return true end

    return false
end

local function getBiasWeight(f)
    f = f or 0
    if(f>=3) then return ToyboxMod.SAME_MANTLE_BIAS[3] end
    if(f<=0) then return ToyboxMod.SAME_MANTLE_BIAS[0] end

    return ToyboxMod:lerp(ToyboxMod.SAME_MANTLE_BIAS[math.floor(f)], ToyboxMod.SAME_MANTLE_BIAS[math.floor(f)+1], f-math.floor(f))
end

---@param rng RNG?
---@param ignoreBias boolean?
---@param consumableId boolean?
function ToyboxMod:getRandomMantle(rng, ignoreBias, consumableId)
    local MANTLE_PICKER = WeightedOutcomePicker()

    if(ignoreBias) then
        for _, mData in pairs(ToyboxMod.MANTLE_DATA) do
            if(mData.WEIGHT) then
                local outc = (consumableId and mData.CONSUMABLE_SUBTYPE or mData.ID)
                MANTLE_PICKER:AddOutcomeFloat(outc, mData.WEIGHT)
            end
        end
    else
        local ownedMantles = {}

        local atlases = ToyboxMod:getAllAtlasA()
        local numAtlasA = #atlases
        for _, p in ipairs(atlases) do
            local data = ToyboxMod:getAtlasATable(p:ToPlayer())
            local transf = data.TRANSFORMATION
            ownedMantles[transf] = (ownedMantles[transf] or 0)+data.HP_CAP/numAtlasA
            for _, mantle in ipairs(data.MANTLES) do
                if(mantle.TYPE~=transf) then ownedMantles[mantle.TYPE] = (ownedMantles[mantle.TYPE] or 0)+1/numAtlasA end
            end
        end
        
        for _, mData in pairs(ToyboxMod.MANTLE_DATA) do
            if(mData.WEIGHT) then
                local outc = (consumableId and mData.CONSUMABLE_SUBTYPE or mData.ID)
                local weightmult = 1
                if(not ToyboxMod:isBadMantle(mData.ID)) then
                    weightmult = getBiasWeight(ownedMantles[mData.ID] or 0) or 1
                end
                
                MANTLE_PICKER:AddOutcomeFloat(outc, mData.WEIGHT*weightmult)
            end
        end
    end

    rng = (rng or ToyboxMod:generateRng())
    local outcome = MANTLE_PICKER:PickOutcome(rng)

    return outcome
end

function ToyboxMod:getNumMantlesByType(player, type)
    local data = ToyboxMod:getAtlasATable(player)
    local s = 0
    for i=1, ToyboxMod:getRightmostMantleIdx(player) do
        s = s+(data.MANTLES[i].TYPE==type and 1 or 0)
    end
    return s
end

function ToyboxMod:anyAtlasAHasTransformation(type, isReal)
    for _, player in ipairs(ToyboxMod:getAllAtlasA()) do
        player = player:ToPlayer()

        if(ToyboxMod:getAtlasAData(player, "TRANSFORMATION")==type) then return true end
        if(isReal~=true and ToyboxMod:getAtlasAData(player, "BIRTHRIGHT_TRANSFORMATION")==type) then return true end
    end

    return false
end

function ToyboxMod:spawnShardsForMantle(player, idx, amount)
    local data = ToyboxMod:getAtlasATable(player)

    local selMType = data.MANTLES[idx].TYPE
    local rng = player:GetCardRNG(ToyboxMod.MANTLE_DATA.DEFAULT.ID)
    local pos = ToyboxMod:getMantleHeartPosition(player, idx)
    local c = ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(selMType)].SHARD_COLOR or ToyboxMod.MANTLE_DATA.DEFAULT.SHARD_COLOR
    data.MANTLES[idx].COLOR = Color(1,1,1,1,1)

    for _=1, amount do
        local v = Vector(rng:RandomFloat()*2+3, 0):Rotated(-90+(rng:RandomFloat()-0.5)*180)
        local p = pos+Vector(rng:RandomFloat()-0.5, rng:RandomFloat()-0.5)*7

        ToyboxMod:spawnShard(player, p, v, nil, nil, c)
    end
end

function ToyboxMod:spawnShard(player, pos, vel, lifespan, rotation, color, frame)
    if(frame==nil) then frame=player:GetCardRNG(ToyboxMod.MANTLE_DATA.DEFAULT.ID):RandomInt(4) end
    if(lifespan==nil) then lifespan=60 end
    if(color==nil) then color = Color(1,1,1,1) end
    if(rotation==nil) then rotation=0 end

    local data = ToyboxMod:getAtlasATable(player)

    data.MANTLE_SHARDS[#data.MANTLE_SHARDS+1] = {
        Position = pos,
        Velocity = vel or Vector.Zero,
        Lifespan = lifespan,
        Lifeframes= 0,
        Color = color,
        Frame = frame,
        Rotation = rotation,
    }
end

function ToyboxMod:getMantleHeartPosition(player, idx)
    local pNum = ToyboxMod:getTruePlayerNumFromPlayerEnt(player)
    if(pNum==-1 or pNum>=4) then return Vector(-1000, -1000) end

    return ToyboxMod:getHeartHudPosition(pNum)+Vector(14,4)+(idx-1)*Vector(18,0)
end

function ToyboxMod:getMantleKeyFromId(idx)
    return ToyboxMod.MANTLE_ID_TO_NAME[idx] or "DEFAULT"
end

function ToyboxMod:getMantleHeartData(pl, idx, key)
    local data = ToyboxMod:getAtlasATable(pl)
    data.MANTLES[idx].DATA = data.MANTLES[idx].DATA or {}

    return data.MANTLES[idx].DATA[key]
end
function ToyboxMod:setMantleHeartData(pl, idx, key, val)
    local data = ToyboxMod:getAtlasATable(pl)
    data.MANTLES[idx].DATA = data.MANTLES[idx].DATA or {}
    data.MANTLES[idx].DATA[key] = val
end