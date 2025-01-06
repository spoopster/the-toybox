local mod = MilcomMOD

local CHASE_SPEED = 21
local CHASE_LERP = 0.05

local PROJ_FREQ = 15
local PROJ_NUM = 8
local PROJ_SPEED = 10

---@param npc EntityNPC
local function redMegalodonInit(_, npc)
    if(not (npc.Variant==mod.BOSS_RED_MEGALODON)) then return end

    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    npc:GetSprite():Play("Idle")
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, redMegalodonInit, mod.NPC_MAIN)

---@param npc EntityNPC
local function redMegalodonUpdate(_, npc)
    if(not (npc.Variant==mod.BOSS_RED_MEGALODON)) then return end

    npc.Target = npc:GetPlayerTarget()

    local velDir = Vector.Zero
    if(npc.Target) then
        velDir = (npc.Target.Position-npc.Position):Normalized()
    end
    npc.Velocity = mod:lerp(npc.Velocity, velDir*CHASE_SPEED, CHASE_LERP)

    if(npc.FrameCount%PROJ_FREQ==0) then
        for i=1,PROJ_NUM do
            local dir = Vector.FromAngle(360*i/PROJ_NUM)*PROJ_SPEED

            local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 0,0,npc.Position,dir,npc):ToProjectile()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, redMegalodonUpdate, mod.NPC_MAIN)