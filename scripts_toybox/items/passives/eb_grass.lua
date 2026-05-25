local sfx = SFXManager()

local DONATE_REQ = 3

local HEAL_CHANCE = 1

local STAT_INCREASES = {
    SPEED = 0.1,
    TEARS = 0.5,
    DAMAGE = 0.5,
    RANGE = 1,
}

---@param pl EntityPlayer
local function increaseLowestStat(pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    data.EB_GRASS_STATS = data.EB_GRASS_STATS or {}

    local possibleStats = {}

    local speedStat = pl.MoveSpeed*4.5-2
    local tearsStat = ((30/(pl.MaxFireDelay+1))^0.75)*(4.5*(11/30)^0.75)-2
    local damageStat = (pl.Damage^0.56)*(4.5/3.5^0.56)-2
    local rangeStat = (pl.TearRange-230)/60+2

    local min = math.min(speedStat, tearsStat, damageStat, rangeStat)
    if(speedStat==min) then table.insert(possibleStats, "SPEED") end
    if(tearsStat==min) then table.insert(possibleStats, "TEARS") end
    if(damageStat==min) then table.insert(possibleStats, "DAMAGE") end
    if(rangeStat==min) then table.insert(possibleStats, "RANGE") end

    local res = (#possibleStats>1 and possibleStats[pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_EB_GRASS):RandomInt(1, #possibleStats)] or possibleStats[1])
    data.EB_GRASS_STATS[res] = (data.EB_GRASS_STATS[res] or 0)+STAT_INCREASES[res]
    pl:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE, true)
end

local function removeStateFlags(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_EB_GRASS)) then return end

    Game():SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_BROKEN, false)
    Game():SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_JAMMED, false)
    Game():SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_BLOWN, false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, removeStateFlags)

local function spawnDonoIfNone()
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_EB_GRASS)) then return end
    local room = Game():GetRoom()

    if(room:IsFirstVisit() and room:GetType()==RoomType.ROOM_SECRET) then
        local hasShop = false
        local rooms = Game():GetLevel():GetRooms()
        for i = 0, rooms.Size-1 do
            local levelroom = rooms:Get(i)
            if(levelroom.Data and levelroom.Data.Type==RoomType.ROOM_SHOP) then
                hasShop = true
            end
        end
        if(not hasShop) then
            local nearest
            local nearestDist = 2^32

            for _, ent in ipairs(Isaac.FindByType(17)) do
                local dist = ent.Position:DistanceSquared(room:GetCenterPos())
                if(dist<nearestDist) then
                    nearest = ent
                    nearestDist = dist
                end
            end

            local pos = (nearest and nearest.Position or room:FindFreePickupSpawnPosition(room:GetCenterPos()))

            if(nearest) then nearest:Remove() end

            local slot = Isaac.Spawn(6,SlotVariant.DONATION_MACHINE,0,pos,Vector.Zero,nil)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, spawnDonoIfNone)

---@param slot EntitySlot
local function slotUpdate(_, slot)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_EB_GRASS)) then return end

    if(slot:GetState()==SlotState.DESTROYED) then
        slot:SetState(SlotState.IDLE)

        local sp = slot:GetSprite()
        sp:Play("Prize", true)
        sp:Stop()

        local value = Isaac.GetPersistentGameData():GetEventCounter(EventCounter.DONATION_MACHINE_COUNTER)
        sp:SetLayerFrame(3, value%10)
        sp:SetLayerFrame(2, (value//10)%10)
        sp:SetLayerFrame(1, (value//100)%10)
    end

    local data = ToyboxMod:getEntityDataTable(slot)

    if((data.EB_EXTRA_FRAME or 0)>0) then
        data.EB_EXTRA_FRAME = math.max(0, (data.EB_EXTRA_FRAME or 0)-3)
    end

    local edata = ToyboxMod:getExtraDataTable()

    local val = Isaac.GetPersistentGameData():GetEventCounter(EventCounter.DONATION_MACHINE_COUNTER)
    local prevVal = edata.EB_GRASS_PREV_DONO or val

    local dif = val-prevVal
    if(dif>0) then
        edata.EB_GRASS_DONATION_COUNTER = (edata.EB_GRASS_DONATION_COUNTER or 0)+dif

        while(edata.EB_GRASS_DONATION_COUNTER>=DONATE_REQ) do
            edata.EB_GRASS_DONATION_COUNTER = edata.EB_GRASS_DONATION_COUNTER-DONATE_REQ

            for i=0, Game():GetNumPlayers()-1 do
                local pl = Isaac.GetPlayer(i)
                if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_EB_GRASS)) then
                    increaseLowestStat(pl)
                    if(HEAL_CHANCE>=1 or pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_EB_GRASS):RandomFloat()<HEAL_CHANCE) then
                        pl:AddHearts(1)
                    end

                    --pl:AnimateHappy()
                end
            end

            data.EB_EXTRA_FRAME = 60
            sfx:Play(SoundEffect.SOUND_THUMBSUP, 0.9, nil, nil, 0.95+math.random()*0.1)
        end
    end

    edata.EB_GRASS_PREV_DONO = val
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, slotUpdate, SlotVariant.DONATION_MACHINE)

local CANCEL_RENDER = false

---@param slot EntitySlot
---@param offs Vector
local function slotPreRender(_, slot, offs)
    if(CANCEL_RENDER) then return end

    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_EB_GRASS)) then return end

    if(slot:GetState()==SlotState.DESTROYED) then
        slot:Update()
    end

    local data = ToyboxMod:getEntityDataTable(slot)
    if((data.EB_EXTRA_FRAME or 0)<=0) then return end

    local frame = data.EB_EXTRA_FRAME or 0

    local sp = slot:GetSprite()
    local ogColor = Color.Lerp(sp.Color, sp.Color, 0)
    local ogScale = Vector(sp.Scale.X, sp.Scale.Y)

    sp.Color = Color(0,0,0,math.min(frame/60, 1)*0.35,255/255,200/255,63/255)
    sp.Scale = ogScale*(1+math.min(frame/30, 1)*0.075)

    CANCEL_RENDER = true

    slot:Render(offs)

    CANCEL_RENDER = nil

    sp.Color = ogColor
    sp.Scale = ogScale
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_SLOT_RENDER, CallbackPriority.LATE, slotPreRender, SlotVariant.DONATION_MACHINE)

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(flag & (CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE) == 0) then return end

    local data = ToyboxMod:getEntityData(pl, "EB_GRASS_STATS") or {}
    if(flag==CacheFlag.CACHE_SPEED and (data.SPEED or 0)>0) then
        pl.MoveSpeed = pl.MoveSpeed + data.SPEED
    elseif(flag==CacheFlag.CACHE_RANGE and (data.RANGE or 0)>0) then
        pl.TearRange = pl.TearRange + 40*data.RANGE
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not (stat==EvaluateStatStage.FLAT_TEARS or stat==EvaluateStatStage.FLAT_DAMAGE)) then return end

    local data = ToyboxMod:getEntityData(pl, "EB_GRASS_STATS") or {}
    if(stat==EvaluateStatStage.FLAT_TEARS and (data.TEARS or 0)>0) then
        return val+data.TEARS
    elseif(stat==EvaluateStatStage.FLAT_DAMAGE and (data.DAMAGE or 0)>0) then
        return val+data.DAMAGE
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat)