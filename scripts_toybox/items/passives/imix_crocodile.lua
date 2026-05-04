local sfx = SFXManager()

local DECAY_DURATION = 60*30*1.5
local DECAY_FREQ = 30

local KILL_EFF_REFRESH = 30

local EFF_SPEED = 0.2
local EFF_TEARS = 1
local EFF_RANGE = 1
local EFF_SHOTSPEED = 0.16

---@param pl EntityPlayer
---@param isInitFinished boolean
local function setAllStats(_, pl, _, isInitFinished)
    if(pl.FrameCount==0) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_IMIX_CROCODILE)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.IMIX_STAT_BASELINE = (data.IMIX_STAT_BASELINE or 0)+math.ceil((data.IMIX_STAT_COUNTER or 0)/DECAY_FREQ)*DECAY_FREQ
    data.IMIX_STAT_COUNTER = DECAY_DURATION

    pl:AddCacheFlags(CacheFlag.CACHE_ALL)
    pl:EvaluateItems()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, setAllStats)

---@param pl EntityPlayer
local function makeStatsPermanent(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_IMIX_CROCODILE)) then return end
    if(Game():GetRoom():GetType()~=RoomType.ROOM_BOSS) then return end
    if(not Game():GetRoom():IsCurrentRoomLastBoss()) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    if((data.IMIX_STAT_COUNTER or 0)>0) then
        data.IMIX_STAT_BASELINE = (data.IMIX_STAT_BASELINE or 0)+math.ceil((data.IMIX_STAT_COUNTER or 0)/DECAY_FREQ)*DECAY_FREQ
        data.IMIX_STAT_COUNTER = 0

        pl:AddCacheFlags(CacheFlag.CACHE_ALL)
        pl:EvaluateItems()

        sfx:Play(ToyboxMod.SFX_EVIL)
        pl:SetColor(Color(0.2,0.2,0.2,1,0.1,0.1),15,0,true,false)
        Isaac.CreateTimer(function()
            if(pl) then
                pl:CreateAfterimage(10, pl.Position)
            end
        end, 3, 4, false)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, makeStatsPermanent)

---@param pl EntityPlayer
local function postPeffectUpdate(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_IMIX_CROCODILE)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    if((data.IMIX_STAT_COUNTER or 0)<=0) then return end

    data.IMIX_STAT_COUNTER = data.IMIX_STAT_COUNTER-1
    if(data.IMIX_STAT_COUNTER % DECAY_FREQ == 0) then
        pl:AddCacheFlags(CacheFlag.CACHE_ALL)
        pl:EvaluateItems()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)

---@param npc EntityNPC
local function restoreEffect(_, npc)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_IMIX_CROCODILE)) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_IMIX_CROCODILE)) then
            local data = ToyboxMod:getEntityDataTable(pl)
            if((data.IMIX_STAT_COUNTER or 0)>0) then
                data.IMIX_STAT_COUNTER = math.min(DECAY_DURATION, (data.IMIX_STAT_COUNTER or 0)+KILL_EFF_REFRESH)

                pl:AddCacheFlags(CacheFlag.CACHE_ALL)
                pl:EvaluateItems()
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, restoreEffect)

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_IMIX_CROCODILE)) then return end
    if(flag & (CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED) == 0) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    local statVal = (data.IMIX_STAT_COUNTER or 0)+(data.IMIX_STAT_BASELINE or 0)
    if(statVal==0) then return end

    if(flag==CacheFlag.CACHE_SPEED) then
        pl.MoveSpeed = pl.MoveSpeed + EFF_SPEED*(statVal/DECAY_DURATION)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        pl.TearRange = pl.TearRange + 40*EFF_RANGE*(statVal/DECAY_DURATION)
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        pl.ShotSpeed = pl.ShotSpeed + EFF_SHOTSPEED*(statVal/DECAY_DURATION)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_IMIX_CROCODILE)) then return end
    --if(not (stat==EvaluateStatStage.TEARS_UP)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    local statVal = (data.IMIX_STAT_COUNTER or 0)+(data.IMIX_STAT_BASELINE or 0)
    if(statVal==0) then return end

    --if(stat==EvaluateStatStage.TEARS_UP) then
        return val+EFF_TEARS*(statVal/DECAY_DURATION)
    --end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.TEARS_UP)