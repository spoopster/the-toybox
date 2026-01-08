local sfx = SFXManager()

local INIT_COOLDOWN = 30*1
local SHOOT_COOLDOWN = 30*2

local MIN_COOLDOWN_ATTACKED = 30*2
local MAX_COOLDOWN = 30*6
local BOMB_ANIM_MIN_COOLDOWN = 30*2.5

local DISTANCE_MAX = 40*6

---@param npc EntityNPC
local function kingHostInit(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_KING_HOST)) then return end

    npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, kingHostInit, ToyboxMod.NPC_ENEMY)

---@param npc EntityNPC
local function kingHostUpdate(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_KING_HOST)) then return end

    local sp = npc:GetSprite()

    if(npc.State==NpcState.STATE_INIT) then
        npc.State = NpcState.STATE_IDLE
        npc.ProjectileCooldown = INIT_COOLDOWN
        npc.I2 = 0
    end

    if(npc.State==NpcState.STATE_IDLE) then
        npc.I2 = 0
        if(sp:IsFinished()) then
            sp:Play("Idle", true)
        end

        local anim = "Idle"
        if(npc.ProjectileCooldown>=BOMB_ANIM_MIN_COOLDOWN) then
            anim = "Bombed"
        end
        local curanim = sp:GetAnimation()
        if(curanim=="Idle" or curanim=="Bombed" and curanim~=anim) then
            sp:Play(anim, true)
        end

        if(npc.ProjectileCooldown==0) then
            local target = npc:GetPlayerTarget()
            if(target and target.Position:Distance(npc.Position)<DISTANCE_MAX) then
                if(Game():GetRoom():CheckLine(npc.Position, target.Position, LineCheckMode.PROJECTILE)) then
                    npc.State = NpcState.STATE_ATTACK
                    npc.StateFrame = 0
                end
            end
        end
    elseif(npc.State==NpcState.STATE_ATTACK) then
        if(npc.StateFrame==1) then
            sp:Play("Shoot2", true)

            npc.I1 = 0
        end

        if(sp:GetAnimation()~="Shoot2") then sp:Play("Shoot2", true) end

        if(sp:IsFinished()) then
            npc.State = NpcState.STATE_IDLE
            npc.StateFrame = 0
            npc.ProjectileCooldown = SHOOT_COOLDOWN
        end

        if(sp:IsEventTriggered("Open")) then
            npc.I2 = 1

            sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
        end
        if(sp:IsEventTriggered("Close")) then
            npc.I2 = 0

            Game():ShakeScreen(15)
            sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS)
        end
        if(sp:IsEventTriggered("Windup")) then
            sfx:Play(SoundEffect.SOUND_GRROOWL)
        end
        if(sp:IsEventTriggered("Shoot")) then
            local params = ProjectileParams()
            params.CircleAngle = npc.I1*25
            params.Scale = 2-npc.I1*0.2
            npc:FireProjectiles(npc.Position, Vector(16,24), ProjectileMode.CIRCLE_CUSTOM, params)

            npc.I1 = npc.I1+1
            sfx:Play(SoundEffect.SOUND_BLOODSHOOT)
        end
    end

    npc.ProjectileCooldown = math.max(npc.ProjectileCooldown-1, 0)
    npc.Velocity = npc.Velocity*0.3
    npc.StateFrame = npc.StateFrame+1
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, kingHostUpdate, ToyboxMod.NPC_ENEMY)

---@param ent Entity
local function kingHostTakeDmg(_, ent, dmg)
    if(ent.Variant==ToyboxMod.NPC_KING_HOST) then
        local npc = ent:ToNPC()
        if(npc.I2==0) then
            npc.ProjectileCooldown = math.max(MIN_COOLDOWN_ATTACKED, math.min(MAX_COOLDOWN, npc.ProjectileCooldown+(dmg*1.5)//1))
            return false
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, kingHostTakeDmg, ToyboxMod.NPC_ENEMY)