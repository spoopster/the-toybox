
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

---@param vec Vector
local function vectorToDir(vec)
    local a = vec:GetAngleDegrees()
    return math.floor((a+225)%360/90)
end
---@param dir Direction
local function dirToVector(dir)
    local angle = 90
    if(dir==Direction.RIGHT) then angle = 0
    elseif(dir==Direction.LEFT) then angle = 180
    elseif(dir==Direction.UP) then angle = 270 end

    return Vector.FromAngle(angle)
end

---@param npc EntityNPC
local function tonsilInit(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_TONSIL)) then return end

    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
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

    if(npc.FrameCount>1 and math.abs(npc.V1:Normalized():Dot(npc.Velocity:Normalized()))<=0.5) then
        sfx:Play(905, 0.5, 2, false, 0.8+math.random()*0.2)
    end

    local dirVec = dirToVector(vectorToDir(npc.Velocity:Rotated(45)))
    dirVec = dirVec:Rotated(-45)
    npc.Velocity = ToyboxMod:lerp(npc.Velocity, dirVec:Resized(5), 0.2)
    npc.V1 = npc.Velocity

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

    sfx:Play(905, 0.5, 2, false, 0.8+math.random()*0.2)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_COLLISION, postTonsilCollision, ToyboxMod.NPC_ENEMY)