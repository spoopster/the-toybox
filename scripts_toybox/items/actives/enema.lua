local sfx = SFXManager()

local STATUS_DURATION_MIN = 30*5
local STATUS_DURATION_MULT = 2

local PARTICLE_COLOR = Color(0,0,0,1,141/255,145/255,159/255)
local PARTICLE_COLOR_2 = Color(0.7,0.7,0.7,1,141/255,145/255,159/255)

local STAT_BONUSES = {
    SPEED = 0.2,
    TEARS = 1,
    DAMAGE = 1,
    RANGE = 1*40,
    SHOTSPEED = 0.1,
    LUCK = 1,
}
local PICKER_TO_STAT = {"SPEED", "TEARS", "DAMAGE", "RANGE", "SHOTSPEED", "LUCK"}

local CACHEFLAG_KEYS =  {
    [CacheFlag.CACHE_SPEED] = {"SPEED", "MoveSpeed"},
    [CacheFlag.CACHE_RANGE] = {"RANGE", "TearRange"},
    [CacheFlag.CACHE_SHOTSPEED] = {"SHOTSPEED", "ShotSpeed"},
    [CacheFlag.CACHE_LUCK] = {"LUCK", "Luck"},
}
local STATEVAL_KEYS = {
    [EvaluateStatStage.DAMAGE_UP] = "DAMAGE",
    [EvaluateStatStage.TEARS_UP] = "TEARS",
}

local STATUSES = {
    {EntityFlag.FLAG_FREEZE, "GetFreezeCountdown"},
    {EntityFlag.FLAG_POISON, "GetPoisonCountdown"},
    {EntityFlag.FLAG_SLOW, "GetSlowingCountdown"},
    {EntityFlag.FLAG_CHARM, "GetCharmedCountdown"},
    {EntityFlag.FLAG_CONFUSION, "GetConfusionCountdown"},
    {EntityFlag.FLAG_MIDAS_FREEZE, "GetMidasFreezeCountdown"},
    {EntityFlag.FLAG_FEAR, "GetFearCountdown"},
    {EntityFlag.FLAG_BURN, "GetBurnCountdown"},
    {EntityFlag.FLAG_SHRINK, "GetShrinkCountdown"},
    {EntityFlag.FLAG_BLEED_OUT, "GetBleedingCountdown"},
    {EntityFlag.FLAG_MAGNETIZED, "GetMagnetizedCountdown"},
    {EntityFlag.FLAG_BAITED, "GetBaitedCountdown"},
    {EntityFlag.FLAG_WEAKNESS, "GetWeaknessCountdown"},
    {EntityFlag.FLAG_BRIMSTONE_MARKED, "GetBrimstoneMarkCountdown"},
}

---@param rng RNG
---@param player EntityPlayer
local function useEnema(_, _, rng, player, flags)
    local statusQueue = {}
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ToyboxMod:isValidEnemy(ent)) then
            local gaveStatus = false
            for _, sData in ipairs(STATUSES) do
                if(ent:HasEntityFlags(sData[1])) then
                    local duration = ent[sData[2]](ent)
                    if(duration>0) then
                        gaveStatus = true
                        table.insert(statusQueue, STATUS_DURATION_MIN+duration*STATUS_DURATION_MULT)
                    end
                end
            end

            if(gaveStatus) then
                local maxdist = ent.Position:Distance(player.Position)
                local dir = (player.Position-ent.Position):Normalized()
                local pos = ent.Position
                while(pos:Distance(player.Position)>20) do
                    local particle = Isaac.Spawn(1000,111,0,pos,dir*4,nil):ToEffect()
                    particle.SpriteScale = Vector.One*((1-pos:Distance(player.Position)/maxdist)*0.6+0.1)
                    particle.Color = PARTICLE_COLOR

                    pos = pos+dir*20
                end

                ent:RemoveStatusEffects()
            end
        end
    end

    if(#statusQueue>0) then
        local data = ToyboxMod:getEntityDataTable(player)
        data.ENEMA_STATS = data.ENEMA_STATS or {}
        for _, duration in ipairs(statusQueue) do
            local chosenStat = PICKER_TO_STAT[rng:RandomInt(1,#PICKER_TO_STAT)]
            table.insert(data.ENEMA_STATS, {chosenStat, duration})
        end
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)

        player:SetColor(PARTICLE_COLOR_2, 10, 1, true, false)

        sfx:Play(ToyboxMod.SFX_WATER_NOISE, 1, 2, false, 0.95+math.random()*0.1)
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useEnema, ToyboxMod.COLLECTIBLE_ENEMA)

---@param pl EntityPlayer
local function postPeffectUpdate(_, pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    data.ENEMA_STATS = data.ENEMA_STATS or {}
    if(#data.ENEMA_STATS==0) then
        if(data.ENEMA_VFX) then
            if(data.ENEMA_VFX:Exists() and not data.ENEMA_VFX:IsDead()) then
                local ent = data.ENEMA_VFX
                ent:Die()
                ent:SetColor(Color(1,1,1,0),60, 2, false, false)
                ent:SetColor(ent.Color,10,1, true, false)
                Isaac.CreateTimer(function() if(ent and ent:Exists()) then ent:Remove() end end, 10, 1, false)
            end
            data.ENEMA_VFX = nil
        end
        return
    end

    if(not (data.ENEMA_VFX and data.ENEMA_VFX:Exists())) then
        local well = Isaac.Spawn(1000,57,0,pl.Position,pl.Velocity,pl):ToEffect()
        well:FollowParent(pl)
        well.Color = PARTICLE_COLOR_2
        
        data.ENEMA_VFX = well
    end
    data.ENEMA_VFX.Color = PARTICLE_COLOR_2

    local tableCopy = {}
    local updatedTable = false

    for _, statusdata in ipairs(data.ENEMA_STATS) do
        statusdata[2] = statusdata[2]-1
        if(statusdata[2]>0) then
            table.insert(tableCopy, statusdata)
        else
            updatedTable = true
        end
    end
    if(updatedTable) then
        data.ENEMA_STATS = tableCopy
        pl:AddCacheFlags(CacheFlag.CACHE_ALL, true)

        pl:SetColor(Color(0.7,0.7,0.7),5,0,true,false)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not CACHEFLAG_KEYS[flag]) then return end
    local data = ToyboxMod:getEntityData(player, "ENEMA_STATS")
    if(not (data and #data>0)) then return end

    local numUps = 0
    local key = CACHEFLAG_KEYS[flag]
    for _, stat in ipairs(data) do
        if(stat[1]==key[1]) then
            numUps = numUps+1
        end
    end
    if(numUps>0) then
        player[key[2]] = player[key[2]]+numUps*STAT_BONUSES[key[1]]
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not STATEVAL_KEYS[stat]) then return end
    local data = ToyboxMod:getEntityData(pl, "ENEMA_STATS")
    if(not (data and #data>0)) then return end

    local numUps = 0
    local key = STATEVAL_KEYS[stat]
    for _, statdata in ipairs(data) do
        if(statdata[1]==key) then
            numUps = numUps+1
        end
    end
    if(numUps>0) then
        return val+numUps*STAT_BONUSES[key]
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat)