local mod = MilcomMOD
local sfx = SFXManager()

local TRUE_SUBTYPE = 0
local CLONE_SUBTYPE = 1
local MASK_SUBTYPE = 10000

local NUM_CLONES = 2
local MASK_ANGLESPEED = 7
local MASK_ORBITSPEED = 12
local MASK_ORBITRADIUS = Vector(20,16)

local WALKSPEED = 4
local MOVE_COOLDOWN = {60, 150}
local MOVE_RADIUS = 40*5
local MIN_MOVE_RAD = 40*2

local ATTACK_COOLDOWN = {90,180}

local SPIT_PROJSPEED = 12
local SPIT_PROJNUM = 2
local SPIT_PROJNUM_ANGER = 4
local SPIT_PROJSPREAD = 12
local SPIT_PROJSPREAD_ANGER = 25
local SPIT_ANGERTHRESHOLD = 30*40

local CHASE_RUNSPEED = 15
local CHASE_DURATION = 150
local CHASE_ENDLAG = 30
local CHASE_CLONECREEPTHRESHOLD = 30*30
local CHASE_WALLSLAMPROJNUM = 8
local CHASE_WALLSLAMPROJSPEED = 9

local function changeStates(npc, state)
    local data = mod:getEntityDataTable(npc)

    data.SHYGAL_STATE = state
    data.SHYGAL_STATEFRAME = 0
end
local function pickAttack(npc)
    local rng = npc:GetDropRNG()

    if(npc.SubType==TRUE_SUBTYPE and mod:getEntityData(npc, "SHYGAL_MASKS") and #mod:getEntityData(npc,"SHYGAL_MASKS")>0) then
        if(rng:RandomFloat()<0.5) then return "REVIVE" end
    end

    local randFloat = rng:RandomFloat()
    if(randFloat<2/3) then return "SPIT"
    else return "CHASE" end
end
local function pickMovementPos(npc)
    local newPos
    local failsafe=100
    repeat
        newPos = mod:getRandomFreePos()
        failsafe = failsafe-1
    until(failsafe<=0 or (newPos and newPos:DistanceSquared(npc.Position)<=MOVE_RADIUS*MOVE_RADIUS and newPos:DistanceSquared(npc.Position)>=MIN_MOVE_RAD*MIN_MOVE_RAD))

    return newPos
end
local function getDistributedRandomPos(centerpos, amount)
    local room = Game():GetRoom()
    local positions = {}

    local newPos
    local failsafe=100
    repeat
        newPos = mod:getRandomFreePos()
        failsafe = failsafe-1
    until(failsafe<=0 or (newPos and newPos:DistanceSquared(centerpos)<=MOVE_RADIUS*MOVE_RADIUS and newPos:DistanceSquared(centerpos)>=MIN_MOVE_RAD*MIN_MOVE_RAD))
    table.insert(positions, newPos)

    local normalizedRoomSizes = Vector((room:GetGridWidth()-2)/(room:GetGridHeight()-2), 1)
    local relCenterPos = (newPos-room:GetCenterPos())/normalizedRoomSizes

    for i=1, amount-1 do table.insert(positions, room:GetCenterPos()+relCenterPos:Rotated(360*i/amount)*normalizedRoomSizes) end

    return positions
end
local function calcAngerValue(npc, start, final, anger)
    return math.floor(mod:lerp(start, final, math.min(1,mod:getEntityData(npc, "SHYGAL_AGGRESSION")/anger)))
end

---@param npc EntityNPC
local function movementLogic(npc, speed, targetpos, movementLerp, failMoveFriction, minTargetDist, walkAnimSpeedmult)
    local sprite = npc:GetSprite()
    local data = mod:getEntityDataTable(npc)

    if(npc.Target==nil) then npc.Target = npc:GetPlayerTarget() end

    local posToMove = targetpos or npc.Position
    local forceMove
    if(mod:isScared(npc)) then
        posToMove = npc.Position+(npc.Position-npc.Target.Position):Resized(10)
        forceMove = true
    elseif(mod:isConfused(npc) and npc.FrameCount%20==0) then
        posToMove = Game():GetRoom():GetRandomPosition(10)
        forceMove = true
    end

    local vel = npc.Velocity*(failMoveFriction or 0.66)
    if(npc.Position:DistanceSquared(posToMove)>(minTargetDist or 1)*(minTargetDist or 1) and (npc.Pathfinder:HasPathToPos(posToMove,false) or forceMove)) then
        if(sprite:GetAnimation()=="Idle") then
            sprite:Play("Walk", true)
        end

        if(npc:CollidesWithGrid() or data.SHYGAL_GRIDCOLLCOOLDOWN>0) then
            npc.Pathfinder:FindGridPath(posToMove, speed*0.15, 1, false)
            vel = npc.Velocity

            if(data.SHYGAL_GRIDCOLLCOOLDOWN<=0) then
                data.SHYGAL_GRIDCOLLCOOLDOWN=20
            else
                data.SHYGAL_GRIDCOLLCOOLDOWN = data.SHYGAL_GRIDCOLLCOOLDOWN-1
            end
        else
            vel = mod:lerp(npc.Velocity, (posToMove-npc.Position):Resized(speed), (movementLerp or 0.05))
        end
        sprite.PlaybackSpeed = mod:getWalkAnimPlaybackSpeed(npc, speed/(walkAnimSpeedmult or 1), true)
    else
        if(sprite:GetAnimation()=="Walk") then sprite:Play("Idle", true) end
    end

    return vel
end

---@param npc EntityNPC
local function shygalsInit(_, npc)
    if(npc.Variant~=mod.BOSS_SHYGALS) then return end

    local data = mod:getEntityDataTable(npc)

    local bits = npc.SubType
    if(npc.SubType~=MASK_SUBTYPE) then npc.SubType = npc.SubType & 1 end

    if(npc.SubType==TRUE_SUBTYPE or npc.SubType==CLONE_SUBTYPE) then
        changeStates(npc, "IDLE")
        data.SHYGAL_AGGRESSION = 0
        data.SHYGAL_NEXTATTACK_COOLDOWN = npc:GetDropRNG():RandomInt(ATTACK_COOLDOWN[2]-ATTACK_COOLDOWN[1])+ATTACK_COOLDOWN[1]
        data.SHYGAL_NEXTMOVE_COOLDOWN = npc:GetDropRNG():RandomInt(MOVE_COOLDOWN[2]-MOVE_COOLDOWN[1])+MOVE_COOLDOWN[1]
        data.SHYGAL_GRIDCOLLCOOLDOWN = 0
        data.SHYGAL_HASMASK = (bits>>1 & 1 == 1) or npc.SubType==CLONE_SUBTYPE
        if(not data.SHYGAL_HASMASK) then npc:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/shygals/shygal_tainted.png", true) end
    end
    if(npc.SubType==TRUE_SUBTYPE) then
        local numClones = (bits>>2) & 7

        local p = getDistributedRandomPos(npc.Position, numClones+1)
        data.MOVEMENT_POS = p[1]

        --npc.Color = Color(1,1,1,1,0.5,0,0.5)
        local clones = {}
        for i=1, numClones do
            local clone = Isaac.Spawn(mod.NPC_MAIN, mod.BOSS_SHYGALS, CLONE_SUBTYPE, npc.Position, Vector.Zero, npc):ToNPC()
            mod:setEntityData(clone, "MOVEMENT_POS", p[i+1])
            table.insert(clones, clone)
        end
        data.SHYGAL_CLONES = clones
        data.SHYGAL_MASKS = {}
    end

    if(npc.SubType==MASK_SUBTYPE) then
        npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, shygalsInit, mod.NPC_MAIN)

---@param npc EntityNPC
local function shygalsLogic(_, npc)
    if(npc.Variant~=mod.BOSS_SHYGALS) then return end

    local data = mod:getEntityDataTable(npc)
    local room = Game():GetRoom()
    local sprite = npc:GetSprite()
    local rng = npc:GetDropRNG()

    if(npc.SubType==TRUE_SUBTYPE or npc.SubType==CLONE_SUBTYPE) then
        sprite.PlaybackSpeed = 1

        if(npc.FrameCount%60==0 or npc.Target==nil or (npc.Target and npc.Target:IsDead() or not npc.Target:Exists())) then
            npc.Target = npc:GetPlayerTarget()
        end

        --! CALCULATE IDLE MOVEPOS
        if(npc.FrameCount==data.SHYGAL_NEXTMOVE_COOLDOWN or data.MOVEMENT_POS==nil) then
            data.MOVEMENT_POS = pickMovementPos(npc)
            data.SHYGAL_NEXTMOVE_COOLDOWN = (data.SHYGAL_NEXTMOVE_COOLDOWN or 0) + npc:GetDropRNG():RandomInt(MOVE_COOLDOWN[2]-MOVE_COOLDOWN[1])+MOVE_COOLDOWN[1]
        end

        --! IDLE PORAMBULATING
        if(data.SHYGAL_STATE=="IDLE") then
            npc.Velocity = movementLogic(npc, WALKSPEED, data.MOVEMENT_POS, 0.75, 0.75, 20)

            if(npc.SubType==CLONE_SUBTYPE) then
                data.SHYGAL_AGGRESSION = data.SHYGAL_AGGRESSION+1
                --npc.Color = Color(1,1,1,1,math.min(1,data.SHYGAL_AGGRESSION/(30*60)),0,0)
            end
            if(data.SHYGAL_STATEFRAME>=(data.SHYGAL_NEXTATTACK_COOLDOWN or 90)) then
                local attack = pickAttack(npc)
                changeStates(npc, attack)
                data.SHYGAL_NEXTATTACK_COOLDOWN = npc:GetDropRNG():RandomInt(ATTACK_COOLDOWN[2]-ATTACK_COOLDOWN[1])+ATTACK_COOLDOWN[1]
            end
        elseif(data.SHYGAL_STATE=="SPIT") then
            npc.Velocity = npc.Velocity*0.5

            if(data.SHYGAL_STATEFRAME==1) then
                sprite:Play("Attack", true)
            end
            
            if(sprite:IsEventTriggered("Attack")) then
                local p = npc.Target or mod:closestPlayer(npc.Position)
                local dir = (p.Position-npc.Position):Resized(SPIT_PROJSPEED)
                local projNum = calcAngerValue(npc, SPIT_PROJNUM, SPIT_PROJNUM_ANGER, SPIT_ANGERTHRESHOLD)
                local spread = calcAngerValue(npc, SPIT_PROJSPREAD, SPIT_PROJSPREAD_ANGER, SPIT_ANGERTHRESHOLD)

                for i = 1, projNum do
                    local proj = Isaac.Spawn(9,0,0, npc.Position, dir:Rotated(spread*(2*i-projNum-1)/(projNum-1)), npc)
                end
            end

            if(sprite:IsFinished("Attack")) then
                sprite:Play("Idle", true)
                changeStates(npc, "IDLE")
            end
        elseif(data.SHYGAL_STATE=="CHASE") then
            if(data.SHYGAL_STATEFRAME==1) then
                npc.I2 = 0
                npc.I1 = 0
            end

            if(npc.I1<=CHASE_DURATION) then
                if(npc.Target==nil) then npc.Target = npc:GetPlayerTarget() end
                npc.Velocity = movementLogic(npc, CHASE_RUNSPEED, npc.Target.Position, 0.05, 0.5, 1, 2.5)

                if(calcAngerValue(npc,0,1,CHASE_CLONECREEPTHRESHOLD)==1 and npc.I1%3==0) then
                    local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
                    creep.Timeout = 5*30
                end

                if(npc:CollidesWithGrid()) then
                    npc.I2 = 1
                    npc.I1 = CHASE_DURATION

                    local creep = Isaac.Spawn(1000,22,0,npc.Position,Vector.Zero,npc):ToEffect()
                    creep.SpriteScale = Vector(5,5)
                    creep:Update()

                    for i=1, CHASE_WALLSLAMPROJNUM do
                        local proj = Isaac.Spawn(9,0,0,npc.Position,Vector.FromAngle(360*i/CHASE_WALLSLAMPROJNUM):Resized(CHASE_WALLSLAMPROJSPEED),npc)
                    end

                    Isaac.Spawn(1000,16,4,npc.Position,Vector.Zero,nil)
                    
                    sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS)
                end

                npc.I1 = npc.I1+1
            elseif(npc.I1<=CHASE_DURATION+CHASE_ENDLAG+1) then
                npc.Velocity = movementLogic(npc, 0, npc.Position, 0.05, 0.85, 10, 1)

                npc.I1 = npc.I1+1
            elseif(npc.I1==CHASE_DURATION+CHASE_ENDLAG+2) then
                changeStates(npc, "IDLE")
            end
        elseif(data.SHYGAL_STATE=="REVIVE") then
            npc.Velocity = npc.Velocity*0.5

            if(data.SHYGAL_STATEFRAME==1) then
                sprite:Play("Attack", true)
            end
            
            if(sprite:IsEventTriggered("Attack")) then
                local numClones = 0
                if(data.SHYGAL_MASKS) then numClones = #data.SHYGAL_MASKS end

                local p = getDistributedRandomPos(npc.Position, numClones+1)
                data.MOVEMENT_POS = p[1]
        
                data.SHYGAL_CLONES = data.SHYGAL_CLONES or {}
                for i=1, numClones do
                    local clone = Isaac.Spawn(mod.NPC_MAIN, mod.BOSS_SHYGALS, CLONE_SUBTYPE, npc.Position, Vector.Zero, npc):ToNPC()
                    mod:setEntityData(clone, "MOVEMENT_POS", p[i+1])
                    table.insert(data.SHYGAL_CLONES, clone)
                end

                data.SHYGAL_MASKS = {}

                Isaac.Spawn(1000,15,3,npc.Position,Vector.Zero,nil)

                data.SHYGAL_HASMASK = true
                npc:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/shygals/shygal.png", true)

                sfx:Play(SoundEffect.SOUND_THUMBSUP, 0.75)
            end

            if(sprite:IsFinished("Attack")) then
                sprite:Play("Idle", true)
                changeStates(npc, "IDLE")
            end
        end

        data.SHYGAL_STATEFRAME = (data.SHYGAL_STATEFRAME or 0)+1
    elseif(npc.SubType==MASK_SUBTYPE) then
        if(not (npc.SpawnerEntity and npc.SpawnerEntity.Type==mod.NPC_MAIN and npc.SpawnerEntity.Variant==mod.BOSS_SHYGALS and npc.SpawnerEntity.SubType==0)) then
            npc:Remove()
            return
        end
        local spawnerTb = mod:getEntityDataTable(npc.SpawnerEntity)
        local idx = 1
        for i, mask in ipairs(spawnerTb.SHYGAL_MASKS or {}) do
            if(GetPtrHash(mask)==GetPtrHash(npc)) then
                idx=i
                break
            end
        end

        local angle = npc.SpawnerEntity.FrameCount*MASK_ANGLESPEED+360*idx/#spawnerTb.SHYGAL_MASKS
        local newPos = npc.SpawnerEntity.Position+MASK_ORBITRADIUS:Rotated(angle)
        local newVel = (newPos-npc.Position)
        if(newVel:Length()>MASK_ORBITSPEED) then newVel:Resize(MASK_ORBITSPEED) end

        npc.Velocity = mod:lerp(npc.Velocity, newVel, 0.35)

        sprite:Play("Idle")
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, shygalsLogic, mod.NPC_MAIN)

local function shygalsDead(_, npc)
    if(npc.Variant~=mod.BOSS_SHYGALS) then return end
    npc:GetSprite().PlaybackSpeed = 1

    if(npc.SubType==CLONE_SUBTYPE) then
        if(npc.SpawnerEntity and npc.SpawnerEntity.Type==mod.NPC_MAIN and npc.SpawnerEntity.Variant==mod.BOSS_SHYGALS and npc.SpawnerEntity.SubType==0) then
            local spawnerTb = mod:getEntityDataTable(npc.SpawnerEntity)

            for i, clone in ipairs(spawnerTb.SHYGAL_CLONES) do
                if(GetPtrHash(clone)==GetPtrHash(npc)) then
                    table.remove(spawnerTb.SHYGAL_CLONES, i)
                end
            end

            spawnerTb.SHYGAL_MASKS = spawnerTb.SHYGAL_MASKS or {}
            local mask = Isaac.Spawn(mod.NPC_MAIN, mod.BOSS_SHYGALS, MASK_SUBTYPE, npc.Position, Vector.Zero, npc.SpawnerEntity):ToNPC()
            table.insert(spawnerTb.SHYGAL_MASKS, mask)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, shygalsDead, mod.NPC_MAIN)

local function shygalsCollision(_, npc, coll, low)
    if(npc.Variant~=mod.BOSS_SHYGALS) then return end

    if(coll and coll.Type==mod.NPC_MAIN and coll.Variant==mod.BOSS_SHYGALS) then return true end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, shygalsCollision, mod.NPC_MAIN)

---@param npc EntityNPC
local function shygalsTakeDmg(_, npc, amount, flags, source, frames)
    if(npc.Variant~=mod.BOSS_SHYGALS) then return end
    if(npc.SubType==MASK_SUBTYPE) then return false end
    
    local data = mod:getEntityDataTable(npc)

    data.SHYGAL_AGGRESSION = math.max(0,(data.SHYGAL_AGGRESSION or 0)-30*2)

    if(data.SHYGAL_HASMASK==true and npc.SubType==TRUE_SUBTYPE) then
        npc:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/shygals/shygal_tainted.png", true)

        sfx:Play(mod.SFX_ATLASA_METALBLOCK, 0.65)
        npc:SetColor(Color(1,1,1,1,0.3,0.3,0.5),10,1,true,false)

        data.SHYGAL_HASMASK = false
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, shygalsTakeDmg, mod.NPC_MAIN)