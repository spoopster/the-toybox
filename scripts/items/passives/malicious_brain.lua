local mod = MilcomMOD
local sfx = SFXManager()
--! this is the worst code ive written for this mod
--* add overlay for adrenaline
--* add sfx pleas

local RAGE_THRESHOLD = 10000

local RAGE_DURATION = 30*8
local RAGE_LASERRADIUS = 60
local RAGE_LASERROTATESPEED = 5
local RAGE_MAXLASERANGLEROT = 20
local RAGE_NUMLASERS = 3
local RAGE_DAMAGE = 4/RAGE_NUMLASERS
local STRESS_DAMAGE = 10

local ADRENALE_DURATION = 30*12
local ADRENEL_DMGMULT = 1.5

local RAGE_CHARGE_DISTMAX = 40*4
local RAGE_CHARGE_DISTMIN = 40*2
local RAGE_CHARGE_MAXINCREASE = 2 /30
local RAGE_CHARGE_MININCREASE = 1.2 /30

local ANGLE_SPEED = 1.5
local ANGLE_SPEED_MAX = 3.7

local ORBIT_DIST = Vector(50,40)

---@param shift number
local function hueShift(shift)
    local sCos = math.cos(shift*math.pi/180)
    local sSin = math.sin(shift*math.pi/180)
    return Color((sCos+(1-sCos)/3), ((1-sCos)/3+sSin*(0.577)), ((1-sCos)/3-sSin*(0.577)))
end

---@param player EntityPlayer
local function checkFamiliars(_, player, cacheFlag)
    player:CheckFamiliar(
        mod.FAMILIAR_HYPNOS,
        (player:HasCollectible(mod.COLLECTIBLE_MALICIOUS_BRAIN) and 1 or 0),
        player:GetCollectibleRNG(mod.COLLECTIBLE_MALICIOUS_BRAIN),
        Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_MALICIOUS_BRAIN)
    )
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, checkFamiliars, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function postHypnosInit(_, familiar)
    local sprite = familiar:GetSprite()
    sprite:Play("Idle", true)
    sprite.Offset = Vector(0, -22)
    sprite:GetLayer("goozma"):SetCustomShader("spriteshaders/goozmashader")

    local data = mod:getEntityDataTable(familiar)
    data.BRAIN_ANGLE = 0
    data.BRAIN_ANGLE_OFFSET = 0
    data.BRAIN_RAGECOUNTER = 0
    data.BRAIN_ADRENALINECOUNTER = 0
    data.BRAIN_STRESSACTIVE = false
    data.BRAIN_ACTIVERAGELASER = nil
    data.STUPID_POS = false
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, postHypnosInit, mod.FAMILIAR_HYPNOS)

---@param familiar EntityFamiliar
local function postHypnosUpdate(_, familiar)
    local data = mod:getEntityDataTable(familiar)
    local player = (familiar.Player or Isaac.GetPlayer()):ToPlayer()
    local sprite = familiar:GetSprite()

    local hasBffs = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    local hasSpin2Win = player:GetEffects():GetNullEffectNum(NullItemID.ID_SPIN_TO_WIN)>0

    if(sprite:IsFinished("RageEnd")) then sprite:Play("Idle", true) end
    if(sprite:IsFinished("RageStart")) then sprite:Play("IdleRage", true) end

    --! ORBIT UPDATE
    if(hasSpin2Win) then
        local shouldTint = (math.sin(math.rad(familiar.FrameCount*40))+1)/2
        local tint = 0.4*shouldTint
        familiar:SetColor(Color(1,1,1,1,tint,tint,tint),2,1,false,false)
    end

    if(hasBffs) then familiar.SpriteScale = familiar.SpriteScale*0.8 end

    data.BRAIN_RAGECOUNTER = data.BRAIN_RAGECOUNTER or 0
    if(data.STUPID_POS) then
        familiar.Velocity = Vector.Zero
        familiar.Position = Vector.FromAngle(data.BRAIN_ANGLE+(data.BRAIN_ANGLE_OFFSET or 0))*ORBIT_DIST+player.Position+player.Velocity
        data.STUPID_POS = false
    else
        data.BRAIN_ANGLE = (data.BRAIN_ANGLE or 0)+mod:lerp(ANGLE_SPEED,ANGLE_SPEED_MAX,(data.BRAIN_RAGECOUNTER<0 and 1 or math.min(1,data.BRAIN_RAGECOUNTER/RAGE_THRESHOLD)))*(hasSpin2Win and 5 or 1)
        local pos = Vector.FromAngle(data.BRAIN_ANGLE+(data.BRAIN_ANGLE_OFFSET or 0))*ORBIT_DIST+player.Position+player.Velocity
        familiar.Velocity = mod:lerp(familiar.Velocity, pos-familiar.Position, 0.75)
    end

    --! RAGE COUNTER UPDATE
    if(data.BRAIN_RAGECOUNTER<0) then
        if(data.BRAIN_RAGECOUNTER~=-9999) then
            data.BRAIN_RAGECOUNTER = data.BRAIN_RAGECOUNTER+(mod:isRoomClear() and 0.25 or 1)
            if(not (data.BRAIN_ACTIVERAGELASER and data.BRAIN_ACTIVERAGELASER:Exists())) then
                local tPos = familiar.Position
                local cl = mod:closestEnemy(familiar.Position)
                if(cl) then tPos = cl.Position end
                mod:setEntityData(familiar, "TTARGETPOSiton", tPos)

                if(data.BRAIN_STRESSACTIVE) then
                    local laser = Isaac.Spawn(7,LaserVariant.GIANT_RED,0,familiar.Position,familiar.Velocity,familiar):ToLaser()
                    laser.CollisionDamage = STRESS_DAMAGE
                    laser.Parent = familiar
                    laser.DisableFollowParent = false
                    laser.Timeout = 9999
                    laser.Mass = 0

                    local ag = (tPos-laser.Position):GetAngleDegrees()
                    local agDif = mod:angleDifference(laser.AngleDegrees, ag)
                    laser:SetActiveRotation(0, agDif, agDif, false)
                    
                    mod:setEntityData(laser, "MALICIOUS_BRAIN_LASER", -2)
                    mod:setEntityData(laser, "STRESSED_OUT", true)
                    data.BRAIN_ACTIVERAGELASER = laser
                else
                    for i=0, RAGE_NUMLASERS-1 do
                        local laser = Isaac.Spawn(7,2,0,familiar.Position,familiar.Velocity,familiar):ToLaser()
                        laser.CollisionDamage = RAGE_DAMAGE
                        laser.Parent = familiar
                        laser.DisableFollowParent = true
                        laser.Timeout = 9999

                        local ag = (tPos-laser.Position):GetAngleDegrees()
                        local agDif = mod:angleDifference(laser.AngleDegrees, ag)
                        laser:SetActiveRotation(0, agDif, agDif, false)
                        laser:SetMaxDistance(laser.Position:Distance(tPos)+3)
                        
                        mod:setEntityData(laser, "MALICIOUS_BRAIN_LASER", i)
                        if(data.BRAIN_STRESSACTIVE) then mod:setEntityData(laser, "STRESSED_OUT", true) end
                    end

                    local circleLaser = Isaac.Spawn(7,2,3,familiar.Position,familiar.Velocity,familiar):ToLaser()
                    circleLaser.Radius = RAGE_LASERRADIUS
                    circleLaser.CollisionDamage = 0
                    circleLaser.Parent = familiar
                    circleLaser.DisableFollowParent = false
                    circleLaser.Timeout = 9999
                    mod:setEntityData(circleLaser, "MALICIOUS_BRAIN_LASER", -1)
                    if(data.BRAIN_STRESSACTIVE) then mod:setEntityData(circleLaser, "STRESSED_OUT", true) end

                    data.BRAIN_ACTIVERAGELASER = circleLaser
                end
            end
            if(data.BRAIN_RAGECOUNTER>=0) then
                data.BRAIN_STRESSACTIVE = false
                sprite.Color:SetColorize(1,1,1,0)

                sprite:Play("RageEnd", true)
            end
        elseif(sprite:IsEventTriggered("ModeStart")) then
            data.BRAIN_RAGECOUNTER = -RAGE_DURATION
            if(hasBffs) then data.BRAIN_STRESSACTIVE = true end
        end
    elseif(not mod:isRoomClear()) then
        local closest = mod:closestEnemy(player.Position)
        local fl = 1
        if(closest~=nil) then
            local dist = player.Position:Distance(closest.Position)
            fl = mod:clamp( (dist-RAGE_CHARGE_DISTMIN)/(RAGE_CHARGE_DISTMAX-RAGE_CHARGE_DISTMIN), 0, 1)
        end
        data.BRAIN_RAGECOUNTER = math.min(RAGE_THRESHOLD, data.BRAIN_RAGECOUNTER+RAGE_THRESHOLD*0.01*mod:lerp(RAGE_CHARGE_MAXINCREASE,RAGE_CHARGE_MININCREASE,fl))
    end

    --! RAGE COUNTER UPDATE
    data.BRAIN_ADRENALINECOUNTER = data.BRAIN_ADRENALINECOUNTER or 0
    if(Game():GetRoom():GetType()==RoomType.ROOM_BOSS and not mod:isRoomClear()) then
        data.BRAIN_ADRENALINECOUNTER = Game():GetRoom():GetFrameCount()
        if((data.BRAIN_ADRENALINECOUNTER%4==0 and data.BRAIN_ADRENALINECOUNTER<=ADRENALE_DURATION) or data.BRAIN_ADRENALINECOUNTER==ADRENALE_DURATION) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE,true)
        end
    else
        if(data.BRAIN_ADRENALINECOUNTER>0) then
            data.BRAIN_ADRENALINECOUNTER = 0
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE,true)
        end
    end

    if(data.BRAIN_RAGECOUNTER>=0 and string.find(sprite:GetAnimation(),"Idle",1,true)~=nil) then
        local anim = "Idle"
        if(data.BRAIN_RAGECOUNTER>=RAGE_THRESHOLD) then anim="IdleAngry" end

        if(sprite:GetAnimation()~=anim) then sprite:SetAnimation(anim, false) end
    end

    if(data.BRAIN_STRESSACTIVE) then
        local scaledframe = familiar.FrameCount/45
        familiar:GetSprite().Color:SetColorize(1,1,1,scaledframe-math.floor(scaledframe))
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, postHypnosUpdate, mod.FAMILIAR_HYPNOS)

local function fuckYouStupidBitch(_)
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_HYPNOS)) do
        mod:setEntityData(ent, "STUPID_POS", true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, fuckYouStupidBitch)

---@param player EntityPlayer
local function triggerHypnosEffects(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_MALICIOUS_BRAIN)) then return end

    local pPtr = GetPtrHash(player)
    for _, brain in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_HYPNOS)) do
        if(GetPtrHash(brain:ToFamiliar().Player)==pPtr) then
            local sprite = brain:GetSprite()
            local data = mod:getEntityDataTable(brain)
            if((data.BRAIN_RAGECOUNTER or 0)>=RAGE_THRESHOLD) then
                data.BRAIN_RAGECOUNTER = -9999
                sprite:Play("RageStart", true)
                if(player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                    sprite:GetLayer(1):SetVisible(true)
                    sprite:GetLayer(2):SetVisible(true)
                else
                    sprite:GetLayer(1):SetVisible(false)
                    sprite:GetLayer(2):SetVisible(false)
                end
            end
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_DOUBLE_TAP, triggerHypnosEffects)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_MALICIOUS_BRAIN)) then return end

    if(flag==CacheFlag.CACHE_DAMAGE) then
        local dmgMult = 1
        local pPtr = GetPtrHash(player)
        for _, brain in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_HYPNOS)) do
            local adrCnt = (mod:getEntityData(brain, "BRAIN_ADRENALINECOUNTER") or 0)
            if(GetPtrHash(brain:ToFamiliar().Player)==pPtr and adrCnt>0) then
                dmgMult = dmgMult*mod:lerp(ADRENEL_DMGMULT, 1, math.min(adrCnt/ADRENALE_DURATION, 1))
            end
        end

        player.Damage = player.Damage*dmgMult
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

--! fix the weird thing
---@param laser EntityLaser
local function brainLaserUpdate(_, laser)
    local data = mod:getEntityDataTable(laser)
    if(data.MALICIOUS_BRAIN_LASER==nil) then return end

    local sp = laser.SpawnerEntity
    if(not sp) then return end

    if((mod:getEntityData(sp, "BRAIN_RAGECOUNTER") or 0)>=0 and laser:GetTimeout()>1) then
        laser:SetTimeout(1)
        return
    end

    if(mod:getEntityData(laser, "STRESSED_OUT")) then
        local shiColor = hueShift((laser.FrameCount*15)%360)
        laser.Color = Color(0,0,0,1,shiColor.R,shiColor.G,shiColor.B)
    end

    if(data.MALICIOUS_BRAIN_LASER>=0) then -- rotating normal laser
        local newLaserPos = sp.Position + Vector.FromAngle(laser.FrameCount*RAGE_LASERROTATESPEED+360*data.MALICIOUS_BRAIN_LASER/RAGE_NUMLASERS):Resized(RAGE_LASERRADIUS-13)
        laser.Velocity = (newLaserPos-laser.Position)/2
        laser.Position = newLaserPos

        local oldPos = mod:getEntityData(sp, "TTARGETPOSiton") or sp.Position

        local tPos = sp.Position
        local closest = mod:closestEnemy(sp.Position)
        if(closest) then tPos = closest.Position end
        if(oldPos:Distance(tPos)>=RAGE_MAXLASERANGLEROT) then tPos = mod:lerp(oldPos, tPos, 0.5) end
        mod:setEntityData(sp, "TTARGETPOSiton", tPos)

        local ag = (tPos-laser.Position):GetAngleDegrees()
        local agDif = mod:angleDifference(laser.AngleDegrees, ag)
        laser:SetActiveRotation(0, agDif, math.min(agDif, RAGE_MAXLASERANGLEROT), false)
        laser:SetMaxDistance(laser.Position:Distance(tPos)-16)
    elseif(data.MALICIOUS_BRAIN_LASER==-2) then -- giga stress laser
        local oldPos = mod:getEntityData(sp, "TTARGETPOSiton") or sp.Position

        local tPos = sp.Position
        local closest = mod:closestEnemy(sp.Position)
        if(closest) then tPos = closest.Position end
        if(oldPos:Distance(tPos)>=RAGE_MAXLASERANGLEROT) then tPos = mod:lerp(oldPos, tPos, 0.5) end
        mod:setEntityData(sp, "TTARGETPOSiton", tPos)

        local ag = (tPos-laser.Position):GetAngleDegrees()
        local agDif = mod:angleDifference(laser.AngleDegrees, ag)
        laser:SetActiveRotation(0, agDif, math.min(agDif, RAGE_MAXLASERANGLEROT), false)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, brainLaserUpdate)

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

---@param familiar EntityFamiliar
local function hypnoRender(_, familiar)
    local data = mod:getEntityDataTable(familiar)
    local player = (familiar.Player or Isaac.GetPlayer()):ToPlayer()
    local sprite = familiar:GetSprite()

    local pos = Isaac.WorldToScreen(familiar.Position)
    local cnt = data.BRAIN_RAGECOUNTER or 0
    local perc, time, pColor, tColor
    if(cnt<0) then
        perc, pColor=0, KColor(0.5,0.5,0.5,0.5)
        if(cnt==-9999) then time=RAGE_DURATION/30
        else time = -cnt/30 end
        time = math.floor(time*10)/10
        tColor = KColor(1,1,1,0.5)
    else
        perc, pColor = math.floor(10000*cnt/RAGE_THRESHOLD)/100, KColor(1,1,1,0.5)
        time, tColor = 0, KColor(0.5,0.5,0.5,0.5)
    end

    f:DrawStringScaled(tostring(perc).."%", pos.X-200,pos.Y,1,1,pColor,400, true)
    f:DrawStringScaled(tostring(time).."s", pos.X-200,pos.Y+10,1,1,tColor,400, true)
    f:DrawStringScaled(tostring(familiar.CollisionDamage), pos.X-200, pos.Y+20,1,1,pColor,400,true)
end
--mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, hypnoRender, mod.FAMILIAR_HYPNOS)