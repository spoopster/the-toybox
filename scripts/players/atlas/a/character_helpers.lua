local mod = MilcomMOD
local sfx = SFXManager()

--#region DATA

---@param player EntityPlayer
function mod:getAtlasATable(player)
    local tb = mod:getEntityDataTable(player).ATLAS_A_DATA
    if(type(tb)~="table") then
	mod:setEntityData(player, "ATLAS_A_DATA", mod:cloneTable(mod.ATLAS_A_BASEDATA))
    end

    return mod:getEntityDataTable(player).ATLAS_A_DATA or {}
end
---@param player EntityPlayer
---@param key string
function mod:getAtlasAData(player, key)
    return mod:getAtlasATable(player)[key]
end
---@param player EntityPlayer
---@param key string
function mod:setAtlasAData(player, key, val)
    mod:getAtlasATable(player)[key] = val
end

--#endregion
function mod:isAtlasA(player)
    local pt = player:GetPlayerType()
    return (pt==mod.PLAYER_TYPE.ATLAS_A or pt==mod.PLAYER_TYPE.ATLAS_A_TAR)
end
function mod:isAnyPlayerAtlasA()
    for i=0, Game():GetNumPlayers()-1 do
        if(mod:isAtlasA(Isaac.GetPlayer(i))) then
            return true
        end
    end
    return false
end

function mod:getAllAtlasA()
    local t = {}
    for i=0, Game():GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(i):ToPlayer()
        if(mod:isAtlasA(p)) then t[#t+1] = p end
    end

    return t
end

function mod:atlasHasTransformation(player, transformation)
    return (mod:getAtlasAData(player, "TRANSFORMATION")==transformation or mod:getAtlasAData(player, "BIRTHRIGHT_TRANSFORMATION")==transformation)
end

function mod:getRightmostMantleIdx(player)
    local mantles = mod:getAtlasAData(player, "MANTLES")

    for i=mod:getAtlasAData(player, "HP_CAP"), 1, -1 do
        if(mantles[i].TYPE~=mod.MANTLE_DATA.NONE.ID) then return i end
    end

    return 0
end

function mod:getCurrentTransformationType(player)
    local mantles = mod:getAtlasAData(player, "MANTLES")

    local isSameMantle = true
    for i=1, mod:getAtlasAData(player, "HP_CAP") do
        if(mantles[i].TYPE~=mantles[1].TYPE) then
            isSameMantle = false
        end
    end

    if(isSameMantle) then
        if(mantles[1].TYPE==mod.MANTLE_DATA.NONE.ID) then return mod.MANTLE_DATA.TAR.ID end
        return mantles[1].TYPE
    end
    return mod.MANTLE_DATA.DEFAULT.ID
end

function mod:setMantleType(player, idx, hpOverride, mtype)
    local data = mod:getAtlasATable(player)

    mtype = mtype or mod.MANTLE_DATA.DEFAULT.ID
    local mHp = mod.MANTLE_DATA[mod:getMantleKeyFromId(mtype)].HP or mod.MANTLE_DATA.DEFAULT.HP

    local oldD = data.MANTLES[math.min(idx, data.HP_CAP)]
    data.MANTLES[math.min(idx, data.HP_CAP)] = {
        TYPE = mtype,
        HP = hpOverride or mHp,
        MAXHP = mHp,
        COLOR = oldD.COLOR or Color(1,1,1,1),
        DATA = {},
    }
    Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_ATLAS_ADD_MANTLE, mtype, idx, mtype, player)

    mod:updateMantles(player)
end

---@return boolean hpChanged Returns true if the mantle HP changed
function mod:addMantleHp(player, hpToAdd)
    local data = mod:getAtlasATable(player)

    local oldMantles = mod:cloneTable(data.MANTLES)

    if(hpToAdd<0 and Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0) then
        local rIdx = mod:getRightmostMantleIdx(player)
        data.MANTLES[rIdx].HP = data.MANTLES[rIdx].HP+hpToAdd
        mod:spawnShardsForMantle(player, rIdx, 5)
    elseif(hpToAdd>0) then
        data.MANTLES[1].HP = data.MANTLES[1].HP+hpToAdd
    end

    mod:updateMantles(player)

    for key,val in ipairs(oldMantles) do
        if(not (val.TYPE==data.MANTLES[key].TYPE and val.HP==data.MANTLES[key].HP and val.MAXHP==data.MANTLES[key].MAXHP)) then return true end
    end
    return false
end

function mod:hasMaxMantleHp(player)
    local data = mod:getAtlasATable(player)

    for _,val in ipairs(data.MANTLES) do
        if(val.HP~=val.MAXHP) then return false end
    end

    return true
end

function mod:getHeldMantle(player)
    local card = player:GetCard(0)
    for _, dt in pairs(mod.MANTLE_DATA) do
        if(dt.ID>0 and dt.ID<1000 and dt.CONSUMABLE_SUBTYPE==card) then
            return dt.ID
        end
    end
    return mod.MANTLE_DATA.NONE.ID
end

function mod:getSelMantleIdToDestroy(player, type)
    if(type==mod.MANTLE_DATA.NONE.ID) then return 0 end
    local data = mod:getAtlasATable(player)
    local rIdx = mod:getRightmostMantleIdx(player)

    if(rIdx~=data.HP_CAP) then return rIdx+1 end

    for i=1, rIdx do
        if(data.MANTLES[i].TYPE~=type) then return i end
    end

    return 1
end

function mod:giveMantle(player, type)
    local heartburnMode = mod:getEntityData(player, "HEARTBURN_MODE")
    if(heartburnMode~=2) then
        local rIdx = mod:getRightmostMantleIdx(player)
        local data = mod:getAtlasATable(player)

        if(type==nil or type==mod.MANTLE_DATA.NONE.ID) then
            type = mod:getHeldMantle(player)
        end

        if(rIdx==data.HP_CAP) then
            local idx = mod:getSelMantleIdToDestroy(player, type)
            if(type==mod.MANTLE_DATA.NONE.ID) then idx=1 end
            local selMType = data.MANTLES[idx].TYPE
            
            mod:spawnShardsForMantle(player, idx, 10)
            sfx:Play(mod.MANTLE_DATA[mod:getMantleKeyFromId(selMType) or "DEFAULT"].BREAK_SFX)

            for i=idx+1, rIdx do
                data.MANTLES[i-1] = mod:cloneTable(data.MANTLES[i])
            end

            rIdx=rIdx-1
        end

        mod:setMantleType(player, rIdx+1, nil, type)
        if(heartburnMode==1) then
            data.MANTLES[rIdx+1].HP = math.max(0,data.MANTLES[rIdx+1].HP-1)
        end
        
        data.MANTLES[rIdx+1].COLOR = Color(1,1,1,1,1,0,0)

        mod:updateMantles(player)
    end
    --sfx:Play(mod.SOUND_EFFECT.ATLASA_ROCKBREAK, 0.3)
end

function mod:isBadMantle(mantle)
    if(mantle==mod.MANTLE_DATA.DEFAULT.ID) then return true end
    if(mantle==mod.MANTLE_DATA.NONE.ID) then return true end
    if(mantle==mod.MANTLE_DATA.TAR.ID) then return true end

    return false
end

local function getBiasWeight(f)
    f = f or 0
    if(f>=3) then return mod.SAME_MANTLE_BIAS[3] end
    if(f<=0) then return mod.SAME_MANTLE_BIAS[0] end

    return mod:lerp(mod.SAME_MANTLE_BIAS[math.floor(f)], mod.SAME_MANTLE_BIAS[math.floor(f)+1], f-math.floor(f))
end

function mod:getRandomMantle(rng, ignoreBias)
    local ownedMantles = {}
    if(ignoreBias~=true) then
        for _, val in pairs(mod.MANTLE_DATA) do
            ownedMantles[val.ID] = 0
        end
        local atlases = mod:getAllAtlasA()
        for _, p in ipairs(atlases) do
            local data = mod:getAtlasATable(p:ToPlayer())
            local transf = data.TRANSFORMATION
            ownedMantles[transf] = (ownedMantles[transf] or 0)+data.HP_CAP
            for _, mantle in ipairs(data.MANTLES) do
                if(mantle.TYPE~=transf) then ownedMantles[mantle.TYPE] = (ownedMantles[mantle.TYPE] or 0)+1 end
            end
        end
        local numAtlasA = #atlases
        for _, val in pairs(mod.MANTLE_DATA) do
            ownedMantles[val.ID] = ownedMantles[val.ID]/numAtlasA
        end
    end

    local maxWeight = 0
    for _, mData in ipairs(mod.MANTLE_PICKER) do
        local outcome = mData.OUTCOME or mod.MANTLE_DATA.DEFAULT.ID

        if(ignoreBias~=true and not mod:isBadMantle(outcome)) then
            maxWeight = maxWeight+mData.WEIGHT*(getBiasWeight(ownedMantles[outcome]))
        else
            maxWeight = maxWeight+mData.WEIGHT
        end
    end

    rng = (rng or mod:generateRng())
    local selWeight = rng:RandomFloat()*maxWeight
    local curWeight = 0

    for _, mData in ipairs(mod.MANTLE_PICKER) do
        local outcome = mData.OUTCOME or mod.MANTLE_DATA.DEFAULT.ID

        if(ignoreBias~=true and not mod:isBadMantle(outcome)) then
            curWeight = curWeight+mData.WEIGHT*(getBiasWeight(ownedMantles[mData.OUTCOME or mod.MANTLE_DATA.DEFAULT.ID]))
        else
            curWeight = curWeight+mData.WEIGHT
        end

        if(selWeight<curWeight) then
            return mData.OUTCOME
        end
    end

    return mod.MANTLE_DATA.DEFAULT.ID
end

function mod:getNumMantlesByType(player, type)
    local data = mod:getAtlasATable(player)
    local s = 0
    for i=1, mod:getRightmostMantleIdx(player) do
        s = s+(data.MANTLES[i].TYPE==type and 1 or 0)
    end
    return s
end

function mod:anyAtlasAHasTransformation(type, isReal)
    for _, player in ipairs(mod:getAllAtlasA()) do
        player = player:ToPlayer()

        if(mod:getAtlasAData(player, "TRANSFORMATION")==type) then return true end
        if(isReal~=true and mod:getAtlasAData(player, "BIRTHRIGHT_TRANSFORMATION")==type) then return true end
    end

    return false
end

function mod:spawnShardsForMantle(player, idx, amount)
    local data = mod:getAtlasATable(player)

    local selMType = data.MANTLES[idx].TYPE
    local rng = player:GetCardRNG(mod.MANTLE_DATA.DEFAULT.ID)
    local pos = mod:getMantleHeartPosition(player, idx)
    local c = mod.MANTLE_DATA[mod:getMantleKeyFromId(selMType)].SHARD_COLOR or mod.MANTLE_DATA.DEFAULT.SHARD_COLOR
    data.MANTLES[idx].COLOR = Color(1,1,1,1,1)

    for _=1, amount do
        local v = Vector(rng:RandomFloat()*2+3, 0):Rotated(-90+(rng:RandomFloat()-0.5)*180)
        local p = pos+Vector(rng:RandomFloat()-0.5, rng:RandomFloat()-0.5)*7

        mod:spawnShard(player, p, v, nil, nil, c)
    end
end

function mod:spawnShard(player, pos, vel, lifespan, rotation, color, frame)
    if(frame==nil) then frame=player:GetCardRNG(mod.MANTLE_DATA.DEFAULT.ID):RandomInt(4) end
    if(lifespan==nil) then lifespan=60 end
    if(color==nil) then color = Color(1,1,1,1) end
    if(rotation==nil) then rotation=0 end

    local data = mod:getAtlasATable(player)

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

function mod:getMantleHeartPosition(player, idx)
    local pNum = mod:getTruePlayerNumFromPlayerEnt(player)
    if(pNum==-1 or pNum>=4) then return Vector(-1000, -1000) end

    return mod:getHeartHudPosition(pNum)+Vector(14,4)+(idx-1)*Vector(18,0)
end

function mod:getMantleKeyFromId(idx)
    return mod.MANTLE_ID_TO_NAME[idx] or "DEFAULT"
end

function mod:getMantleHeartData(pl, idx, key)
    local data = mod:getAtlasATable(pl)
    data.MANTLES[idx].DATA = data.MANTLES[idx].DATA or {}

    return data.MANTLES[idx].DATA[key]
end
function mod:setMantleHeartData(pl, idx, key, val)
    local data = mod:getAtlasATable(pl)
    data.MANTLES[idx].DATA = data.MANTLES[idx].DATA or {}
    data.MANTLES[idx].DATA[key] = val
end