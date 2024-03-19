local mod = MilcomMOD
local sfx = SFXManager()

--#region DATA

---@param player EntityPlayer
function mod:getAtlasATable(player)
    return mod.ATLAS_A_DATA[player.InitSeed]
end
---@param player EntityPlayer
---@param key string
function mod:getAtlasAData(player, key)
    return mod.ATLAS_A_DATA[player.InitSeed][key]
end
---@param player EntityPlayer
---@param key string
function mod:setAtlasAData(player, key, val)
    mod.ATLAS_A_DATA[player.InitSeed][key] = val
end

--#endregion

function mod:isAnyPlayerAtlasA()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        if(player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A) then return true end
    end
    return false
end

function mod:getFirstAtlasA()
    for _, player in ipairs(Isaac.FindByType(1,0,mod.PLAYER_ATLAS_A)) do
        return player
    end
    return nil
end

function mod:getAllAtlasA()
    local t = {}
    for i=0, Game():GetNumPlayers()-1 do
        local p = Isaac.GetPlayer():ToPlayer()
        if(p:GetPlayerType()==mod.PLAYER_ATLAS_A) then t[#t+1] = p end
    end

    return t
end

function mod:atlasHasTransformation(player, transformation)
    return (mod:getAtlasAData(player, "TRANSFORMATION")==transformation or mod:getAtlasAData(player, "BIRTHRIGHT_TRANSFORMATION")==transformation)
end

function mod:getRightmostMantleIdx(player)
    local mantles = mod:getAtlasAData(player, "MANTLES")

    for i=mod:getAtlasAData(player, "HP_CAP"), 1, -1 do
        if(mantles[i].TYPE~=mod.MANTLES.NONE) then return i end
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
        if(mantles[1].TYPE==mod.MANTLES.NONE) then return mod.MANTLES.TAR end
        return mantles[1].TYPE
    end
    return mod.MANTLES.DEFAULT
end

function mod:getMantleNameFromType(type)
    return mod:getKeyFromVal(mod.MANTLES, type)
end

function mod:setMantleType(player, idx, hpOverride, type)
    local data = mod:getAtlasATable(player)

    local oldD = data.MANTLES[idx]
    data.MANTLES[idx] = {
        TYPE = type or mod.MANTLES["DEFAULT"],
        HP = hpOverride or (mod.MANTLES_HP[mod:getMantleNameFromType(type or 1)] or mod.MANTLES_HP["DEFAULT"]),
        MAXHP = (mod.MANTLES_HP[mod:getMantleNameFromType(type or 1)] or mod.MANTLES_HP["DEFAULT"]),
        COLOR = oldD.COLOR or Color(1,1,1,1),
    }
    mod:updateMantles(player)
end

---@return boolean hpChanged Returns true if the mantle HP changed
function mod:addMantleHp(player, hpToAdd)
    local data = mod:getAtlasATable(player)

    local oldMantles = mod:cloneTable(data.MANTLES)

    if(hpToAdd<0) then
        local rIdx = mod:getRightmostMantleIdx(player)
        data.MANTLES[rIdx].HP = data.MANTLES[rIdx].HP+hpToAdd

        local selMType = data.MANTLES[rIdx].TYPE
        local rng = player:GetCardRNG(mod.MANTLES.DEFAULT)
        local pos = mod:getMantleHeartPosition(player, rIdx)
        local c = mod.MANTLE_TYPE_TO_SHARD_COLOR[selMType] or mod.MANTLE_TYPE_TO_SHARD_COLOR[mod.MANTLES.DEFAULT]

        data.MANTLES[rIdx].COLOR = Color(1,1,1,1,1)

        local shardsToSpawn = 5
        for _=1, shardsToSpawn do
            local v = Vector(rng:RandomFloat()*2+3, 0):Rotated(-90+(rng:RandomFloat()-0.5)*180)
            local p = pos+Vector(rng:RandomFloat()-0.5, rng:RandomFloat()-0.5)*7

            mod:spawnShard(player, p, v, nil, nil, c)
        end
    else
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
    if(mod.SUBTYPE_TO_MANTLE[card]) then return mod.SUBTYPE_TO_MANTLE[card] end
    return mod.MANTLES.NONE
end

function mod:getSelMantleIdToDestroy(player, type)
    if(type==mod.MANTLES.NONE) then return 0 end
    local data = mod:getAtlasATable(player)
    local rIdx = mod:getRightmostMantleIdx(player)

    if(rIdx~=data.HP_CAP) then return rIdx+1 end

    for i=1, rIdx do
        if(data.MANTLES[i].TYPE~=type) then return i end
    end

    return 1
end

function mod:giveMantle(player, type)
    local rIdx = mod:getRightmostMantleIdx(player)
    local data = mod:getAtlasATable(player)

    if(type==nil or type==mod.MANTLES.NONE) then
        type = mod:getHeldMantle(player)
    end

    if(rIdx==data.HP_CAP) then
        local idx = mod:getSelMantleIdToDestroy(player, type)
        if(type==mod.MANTLES.NONE) then idx=1 end
        local selMType = data.MANTLES[idx].TYPE

        local rng = player:GetCardRNG(mod.MANTLES.DEFAULT)
        local pos = mod:getMantleHeartPosition(player, idx)
        local c = mod.MANTLE_TYPE_TO_SHARD_COLOR[selMType] or mod.MANTLE_TYPE_TO_SHARD_COLOR[mod.MANTLES.DEFAULT]

        local shardsToSpawn = 10
        for _=1, shardsToSpawn do
            local v = Vector(rng:RandomFloat()*2+3, 0):Rotated(-90+(rng:RandomFloat()-0.5)*180)
            local p = pos+Vector(rng:RandomFloat()-0.5, rng:RandomFloat()-0.5)*7

            mod:spawnShard(player, p, v, nil, nil, c)
        end

        if(selMType==mod.MANTLES.METAL or selMType==mod.MANTLES.GOLD) then sfx:Play(mod.SFX_ATLASA_METALBREAK, 0.4)
        elseif(selMType==mod.MANTLES.GLASS) then sfx:Play(mod.SFX_ATLASA_GLASSBREAK, 0.4)
        else sfx:Play(mod.SFX_ATLASA_ROCKBREAK, 0.4) end

        for i=idx+1, rIdx do
            data.MANTLES[i-1] = mod:cloneTable(data.MANTLES[i])
        end

        rIdx=rIdx-1
    end

    mod:setMantleType(player, rIdx+1, nil, type)
    
    data.MANTLES[rIdx+1].COLOR = Color(1,1,1,1,1,0,0)

    mod:updateMantles(player)

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK, 0.3)
end

function mod:isBadMantle(mantle)
    if(mantle==mod.MANTLES.DEFAULT) then return true end
    if(mantle==mod.MANTLES.NONE) then return true end
    if(mantle==mod.MANTLES.TAR) then return true end

    return false
end

local function getBiasWeight(f)
    if(f>=3) then return mod.SAME_MANTLE_BIAS[3] end
    if(f<=0) then return mod.SAME_MANTLE_BIAS[0] end

    return mod:lerp(mod.SAME_MANTLE_BIAS[math.floor(f)], mod.SAME_MANTLE_BIAS[math.floor(f)+1], f-math.floor(f))
end

function mod:getRandomMantle(rng)
    local ownedMantles = {}
    for _, val in pairs(mod.MANTLES) do
        ownedMantles[val] = 0
    end
    for _, p in ipairs(Isaac.FindByType(1,0,mod.PLAYER_ATLAS_A)) do
        local data = mod:getAtlasATable(p:ToPlayer())
        local transf = data.TRANSFORMATION
        ownedMantles[transf] = (ownedMantles[transf] or 0)+data.HP_CAP
        for _, mantle in ipairs(data.MANTLES) do
            if(mantle.TYPE~=transf) then ownedMantles[mantle.TYPE] = (ownedMantles[mantle.TYPE] or 0)+1 end
        end
    end
    local numAtlasA = #mod:getAllAtlasA()
    for _, val in pairs(mod.MANTLES) do
        ownedMantles[val] = ownedMantles[val]/numAtlasA
    end

    local maxWeight = 0
    for _, mData in ipairs(mod.MANTLE_PICKER) do
        local outcome = mData.OUTCOME or mod.MANTLES.DEFAULT

        if(not mod:isBadMantle(outcome)) then
            maxWeight = maxWeight+mData.WEIGHT*(getBiasWeight(ownedMantles[outcome]))
        end
    end

    local selWeight = rng:RandomFloat()*maxWeight
    local curWeight = 0

    for _, mData in ipairs(mod.MANTLE_PICKER) do
        local outcome = mData.OUTCOME or mod.MANTLES.DEFAULT

        if(not mod:isBadMantle(outcome)) then
            curWeight = curWeight+mData.WEIGHT*(getBiasWeight(ownedMantles[mData.OUTCOME or mod.MANTLES.DEFAULT]))

            if(selWeight<curWeight) then
                return mData.OUTCOME
            end
        end
    end

    return mod.MANTLES.DEFAULT
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

function mod:spawnShard(player, pos, vel, lifespan, rotation, color, frame)
    if(frame==nil) then frame=player:GetCardRNG(mod.MANTLES.DEFAULT):RandomInt(4) end
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
    if(pNum==-1 or pNum>=4) then return Vector(-100, -100) end

    return mod:getHeartHudPosition(pNum)+(idx-1)*Vector(19,0)
end