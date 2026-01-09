
local sfx = SFXManager()

local PROJ_COOLDOWN = 30*2
local PROJ_SPEED = 11
local PROJ_DISTANCE_SHOOT = 40*5

local function isValidForTonsilCollision(pos)
    local room = Game():GetRoom()
    local idx = room:GetGridIndex(pos)
    if(room:GetGridCollision(idx)<GridCollisionClass.COLLISION_OBJECT) then return end

    local ent = room:GetGridEntity(idx)
    if(ent and ToyboxMod:getGridEntityData(ent, "ENEMYONLY_GATE")) then return end

    return true
end

---@param npc EntityNPC
local function tonsilInit(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_TONSIL)) then return end

    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_BULLET
    npc:GetSprite():Play("Idle", true)

    if(npc.SubType==0) then
        npc.SubType = npc:GetDropRNG():RandomInt(1,4)
    end

    npc.V1 = Vector(1,1):Rotated((npc.SubType-1)*90)
    npc.State = NpcState.STATE_IDLE
    npc.ProjectileCooldown = PROJ_COOLDOWN
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, tonsilInit, ToyboxMod.NPC_ENEMY)

---@param npc EntityNPC
local function tonsilUpdate(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_TONSIL)) then return end

    local sp = npc:GetSprite()
    if(sp:IsFinished("Shoot")) then
        npc.State = NpcState.STATE_IDLE
        sp:Play("Idle", true)
    end

    if(isValidForTonsilCollision(npc.Position)) then
        local mult = Vector(1,1)
        local offset = Vector(0,0)

        if(isValidForTonsilCollision(npc.Position-npc.Velocity*Vector(1,0))) then
            mult.Y = -1
            offset.Y = 1
        end
        if(isValidForTonsilCollision(npc.Position-npc.Velocity*Vector(0,1))) then
            mult.X = -1
            offset.X = 1
        end

        npc.Position = npc.Position-npc.Velocity*offset*0.8*(npc.I1*0.3+1)
        npc.Velocity = npc.Velocity*mult*0.8
        npc.V1 = npc.V1*mult
        npc.I1 = npc.I1+1

        sfx:Play(905, 0.5, 2, false, 0.8+math.random()*0.2)
    else
        npc.I1 = 0
    end

    npc:AddVelocity(npc.V1*0.7)
    npc.Velocity = npc.Velocity*0.85

    if(npc.FrameCount%30==0 or not (npc.Target and npc.Target:Exists() and not npc.Target:IsDead())) then
        npc.Target = npc:GetPlayerTarget()
    end

    if(npc.Target and npc.Target:Exists()) then
        if(npc.State==NpcState.STATE_IDLE and npc.ProjectileCooldown==0) then
            local distCheck = (npc.Target.Position:Distance(npc.Position)<=PROJ_DISTANCE_SHOOT)
            local room = Game():GetRoom()
            local lineCheck, vec = room:CheckLine(npc.Position, npc.Target.Position, LineCheckMode.PROJECTILE, 1000)
            if(distCheck and lineCheck) then
                npc.State = NpcState.STATE_ATTACK
                sp:Play("Shoot", true)
            end
        elseif(npc.State==NpcState.STATE_ATTACK and sp:IsEventTriggered("Shoot")) then
            local dir = (npc.Target.Position-npc.Position):Resized(PROJ_SPEED)
            local params = ProjectileParams()
            params.HeightModifier = 10
            
            local poof = Isaac.Spawn(1000,2,5,npc.Position,Vector.Zero,nil):ToEffect()
            poof.Color = Color(2,1,1,0.25)
            poof:GetSprite().PlaybackSpeed = 1.5
            poof.SpriteOffset = Vector(0,-14)
            poof.DepthOffset = 50

            local proj = npc:FireProjectiles(npc.Position, dir, ProjectileMode.SINGLE, params)

            sfx:Play(SoundEffect.SOUND_STONESHOOT)

            npc.ProjectileCooldown = PROJ_COOLDOWN
        end
    end

    if(npc.ProjectileCooldown>0) then
        npc.ProjectileCooldown = npc.ProjectileCooldown-1
    end
    npc.StateFrame = npc.StateFrame+1
    --npc.I1 = 0
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, tonsilUpdate, ToyboxMod.NPC_ENEMY)

---@param npc EntityNPC
---@param coll Entity
local function postTonsilCollision(_, npc, coll, low)
    if(not (npc.Variant==ToyboxMod.NPC_TONSIL)) then return end

    local diff = (coll.Position-npc.Position):Normalized()

    local npcCapsule = (npc:GetCollisionCapsule())
    local collCapsule = (coll:GetCollisionCapsule())

    local normVel = npc.Velocity:Normalized()

    local npcCapOffX = npc:GetCollisionCapsule(-npc.Velocity*Vector(1,0))
    local npcCapOffY = npc:GetCollisionCapsule(-npc.Velocity*Vector(0,1))

    local mult = Vector(1,1)
    local offset = Vector(0,0)
    if(npcCapOffX:Collide(collCapsule,Vector.Zero)) then
        mult.Y = -1
        offset.Y = 1
    end
    if(npcCapOffY:Collide(collCapsule,Vector.Zero)) then
        mult.X = -1
        offset.X = 1
    end

    npc.Position = npc.Position-npc.Velocity*offset*0.7
    npc.Velocity = npc.Velocity*mult*0.9
    npc.V1 = npc.V1*mult
    npc.I1 = 1

    --[ [
    if(coll.Type==ToyboxMod.NPC_ENEMY and coll.Variant==ToyboxMod.NPC_TONSIL and coll:ToNPC().I1==0) then
        coll = coll:ToNPC() ---@cast coll EntityNPC
        
        coll.Position = coll.Position-coll.Velocity*offset*0.7
        coll.Velocity = coll.Velocity*mult*0.9
        coll.V1 = coll.V1*mult
        coll.I1 = 1
    end
    --]]

    sfx:Play(905, 0.5, 2, false, 0.8+math.random()*0.2)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, postTonsilCollision, ToyboxMod.NPC_ENEMY)