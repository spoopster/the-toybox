
local sfx = SFXManager()

local PROJ_SPEED = 15
local ENEMY_SPEED = 12

---@param npc EntityNPC
local function doodleInit(_, npc)
    if(not (npc.Variant==ToyboxMod.VAR_DOODLE)) then return end

    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    npc:GetSprite():Play("Idle", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, doodleInit, ToyboxMod.NPC_MAIN)

---@param npc EntityNPC
local function doodleUpdate(_, npc)
    if(not (npc.Variant==ToyboxMod.VAR_DOODLE)) then return end

    local sp = npc:GetSprite()
    if(sp:IsFinished("AttackShort")) then
        sp:Play("Idle", true)
    end

    local target = npc:GetPlayerTarget()
    if(target) then
        npc.Target = target

        local dir = (target.Position-npc.Position)
        npc.Velocity = ToyboxMod:lerp(npc.Velocity, dir:Resized(ENEMY_SPEED), 0.05)

        if(dir:Length()<40*5 and npc.ProjectileCooldown<=0) then
            sp:Play("AttackShort", true)
            npc.I1 = math.floor(dir:GetAngleDegrees())

            npc.ProjectileCooldown = 30
        end
    else
        npc.Velocity = npc.Velocity*0.1
    end

    if(sp:IsEventTriggered("Shoot")) then
        local dir = Vector.FromAngle(npc.I1)

        local projParam = ProjectileParams()
        projParam.BulletFlags = ProjectileFlags.BOUNCE
        projParam.Scale = 2.8
        projParam.FallingAccelModifier = -0.09
        
        npc:FireProjectiles(npc.Position, dir:Resized(PROJ_SPEED), ProjectileMode.SINGLE, projParam)
        npc:AddVelocity(dir:Resized(-20))

        sfx:Play(ToyboxMod.SOUND_EFFECT.BURP)
    end

    if(npc.ProjectileCooldown>0) then
        npc.ProjectileCooldown = npc.ProjectileCooldown-1
    end
    npc.StateFrame = npc.StateFrame+1
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, doodleUpdate, ToyboxMod.NPC_MAIN)