local mod = MilcomMOD
--* add sfx pleas
--! add stress effect! !!! !

local RAGE_THRESHOLD = 1--25*30*10
local ADR_THRESHOLD = 30*30*10

local RAGE_DURATION = 30*8
local RAGE_LASERRADIUS = 80
local RAGE_LASERSPEED = 8

local ADRENALE_DURATION = 30*8
local ADRENEL_DMGMULT = 2

local RAGE_CHARGE_DISTMAX = 40*6.5
local RAGE_CHARGE_DISTMIN = 40*2

local ANGLE_SPEED = 1.5
local ANGLE_SPEED_MAX = 3.7

local ORBIT_DIST = Vector(60,45)

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

    --! ORBIT UPDATE
    if(hasSpin2Win) then
        local shouldTint = (math.sin(math.rad(familiar.FrameCount*20))+1)/2
        local tint = 0.1+0.2*shouldTint
        familiar.Color = Color(1,1,1,1,tint,tint,tint)
    else
        familiar.Color = Color(1,1,1,1,0,0,0)
    end

    data.BRAIN_RAGECOUNTER = data.BRAIN_RAGECOUNTER or 0
    if(data.STUPID_POS) then
        familiar.Velocity = Vector.Zero
        familiar.Position = Vector.FromAngle(data.BRAIN_ANGLE+(data.BRAIN_ANGLE_OFFSET or 0))*ORBIT_DIST+player.Position+player.Velocity
        data.STUPID_POS = false
    else
        data.BRAIN_ANGLE = (data.BRAIN_ANGLE or 0)+mod:lerp(ANGLE_SPEED,ANGLE_SPEED_MAX,(data.BRAIN_RAGECOUNTER<0 and 1 or math.min(1,data.BRAIN_RAGECOUNTER/RAGE_THRESHOLD)))*(hasSpin2Win and 3 or 1)
        local pos = Vector.FromAngle(data.BRAIN_ANGLE+(data.BRAIN_ANGLE_OFFSET or 0))*ORBIT_DIST+player.Position+player.Velocity
        familiar.Velocity = mod:lerp(familiar.Velocity, pos-familiar.Position, 0.75)
    end

    --! RAGE COUNTER UPDATE
    local closest = mod:closestEnemy(player.Position)
    if(data.BRAIN_RAGECOUNTER<0) then
        data.BRAIN_RAGECOUNTER = data.BRAIN_RAGECOUNTER+1
        if(not (data.BRAIN_ACTIVERAGELASER and data.BRAIN_ACTIVERAGELASER:Exists())) then
            local laser = Isaac.Spawn(7,2,3,familiar.Position,familiar.Velocity,familiar):ToLaser()
            laser.Radius = RAGE_LASERRADIUS
            laser.CollisionDamage = 3
            laser.Parent = familiar
            laser.DisableFollowParent = true
            mod:setEntityData(laser, "MALICIOUS_BRAIN_LASER", true)

            if(data.BRAIN_STRESSACTIVE) then
                mod:setEntityData(laser, "STRESSED_OUT", true)
            end

            data.BRAIN_ACTIVERAGELASER = laser
        end
        if(data.BRAIN_RAGECOUNTER==0) then
            data.BRAIN_ACTIVERAGELASER:Die()
            data.BRAIN_STRESSACTIVE = false
            sprite.Color:SetColorize(1,1,1,1)

            sprite:Play("Idle", true)
        end
    elseif(data.BRAIN_RAGECOUNTER<RAGE_THRESHOLD and closest and player.Position:Distance(closest.Position)<=RAGE_CHARGE_DISTMAX) then
        local dist = player.Position:Distance(closest.Position)
        local fl = math.max(0, (dist-RAGE_CHARGE_DISTMIN)/(RAGE_CHARGE_DISTMAX-RAGE_CHARGE_DISTMIN))
        data.BRAIN_RAGECOUNTER = data.BRAIN_RAGECOUNTER+10*mod:lerp(1,0,math.max(0, (dist-RAGE_CHARGE_DISTMIN)/(RAGE_CHARGE_DISTMAX-RAGE_CHARGE_DISTMIN)))
    elseif(closest==nil or player.Position:Distance(closest.Position)>RAGE_CHARGE_DISTMAX) then
        data.BRAIN_RAGECOUNTER = math.max(0, data.BRAIN_RAGECOUNTER-0.05*RAGE_THRESHOLD)
    end

    local sn = 0
    if(data.BRAIN_RAGECOUNTER>RAGE_THRESHOLD) then
        sn = (math.sin(math.rad(familiar.FrameCount*12))*0.5+0.5)*0.75
    end
    if(data.BRAIN_RAGECOUNTER<0 and not data.BRAIN_STRESSACTIVE) then sn=0.75 end
    familiar.Color = Color(1,1,1,1,sn,0,0)

    --! RAGE COUNTER UPDATE
    data.BRAIN_ADRENALINECOUNTER = data.BRAIN_ADRENALINECOUNTER or 0
    local bossExists = false
    for _, npc in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 500, EntityPartition.ENEMY)) do
        if(mod:isValidEnemy(npc) and npc:ToNPC():IsBoss()) then
            bossExists = true
            break
        end
    end
    if(data.BRAIN_ADRENALINECOUNTER<0) then
        familiar:SetColor(Color(1,1,1,1,0,1,0),2,105,false,false)
        data.BRAIN_ADRENALINECOUNTER = data.BRAIN_ADRENALINECOUNTER+1

        if(data.BRAIN_ADRENALINECOUNTER==0) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE,true)
        end
    elseif(data.BRAIN_ADRENALINECOUNTER<ADR_THRESHOLD and bossExists) then
        data.BRAIN_ADRENALINECOUNTER = data.BRAIN_ADRENALINECOUNTER+10
    elseif(not bossExists and data.BRAIN_ADRENALINECOUNTER>0) then
        data.BRAIN_ADRENALINECOUNTER = math.max(0, data.BRAIN_ADRENALINECOUNTER-0.05*ADR_THRESHOLD)
    end

    if(data.BRAIN_RAGECOUNTER>=0) then
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
                data.BRAIN_RAGECOUNTER = -RAGE_DURATION
                sprite:Play("IdleRage", true)
                if(player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                    data.BRAIN_STRESSACTIVE = true
                    sprite:Play("IdleStress", true)
                end
            end
            if((data.BRAIN_ADRENALINECOUNTER or 0)>=ADR_THRESHOLD) then
                data.BRAIN_ADRENALINECOUNTER = -ADRENALE_DURATION
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE,true)
            end
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_DOUBLE_TAP, triggerHypnosEffects)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_MALICIOUS_BRAIN)) then return end
    local dmgMult = 1
    local pPtr = GetPtrHash(player)
    for _, brain in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, mod.FAMILIAR_HYPNOS)) do
        if(GetPtrHash(brain:ToFamiliar().Player)==pPtr) then
            if((mod:getEntityData(brain, "BRAIN_ADRENALINECOUNTER") or 0)<0) then dmgMult = dmgMult*ADRENEL_DMGMULT end
        end
    end

    if(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*dmgMult
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

--! fix the weird thing
---@param laser EntityLaser
local function brainLaserUpdate(_, laser)
    if(not mod:getEntityData(laser, "MALICIOUS_BRAIN_LASER")) then return end

    local lerpRadius = RAGE_LASERRADIUS
    local lerpPos = (laser.SpawnerEntity or Isaac.GetPlayer()).Position

    local closest = mod:closestEnemy(laser.Position)
    if(closest) then
        lerpRadius = math.min(5, closest.Size-5)
        lerpPos = closest.Position
    end

    --print((1+math.sin(laser.FrameCount*0.01)*0.2))
    laser.Radius = mod:lerp(laser.Radius, lerpRadius*(1+math.sin(laser.FrameCount*0.1)*0.2), 0.1)

    local newVel = (lerpPos-laser.Position)
    if(newVel:LengthSquared()>RAGE_LASERSPEED*RAGE_LASERSPEED) then newVel:Resize(RAGE_LASERSPEED) end

    laser.Velocity = mod:lerp(laser.Velocity, newVel, 0.05)
    laser.Position = lerpPos

    if(mod:getEntityData(laser, "STRESSED_OUT")) then
        local shiColor = hueShift((laser.FrameCount*15)%360)
        laser.Color = Color(0,0,0,1,shiColor.R,shiColor.G,shiColor.B)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, brainLaserUpdate)