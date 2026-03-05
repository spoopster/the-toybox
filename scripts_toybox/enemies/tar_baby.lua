local sfx = SFXManager()

local MOVESPEED = 1
local SEEK_PIT_SPEED = 2.5

local PROJ_COOLDOWN = 30*1.5
local PROJ_TARGETRANGE = 40*5

local JUMP_PROJCOOLDOWN = 30
local JUMP_MINDIST = 40*4

local TARCREEP_TIMEOUT = 30*5

local function isPositionPit(pos)
    local room = Game():GetRoom()
    local ent = room:GetGridEntityFromPos(pos)
    if(ent and ent:GetType()==GridEntityType.GRID_PIT) then
        return true
    else
        for _, creep in ipairs(Isaac.FindByType(1000,EffectVariant.CREEP_BLACK)) do
            if(creep.Position:Distance(pos)<creep.SpriteScale.X*15) then
                return true
            end
        end
    end

    return false
end

---@param npc EntityNPC
local function tarBabyInit(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_TAR_BABY)) then return end

    npc.State = NpcState.STATE_INIT
    npc.ProjectileCooldown = JUMP_PROJCOOLDOWN
    npc.I1 = 0
    npc.I2 = -1

    if(npc.SubType==1) then
        local room = Game():GetRoom()
        local idx = room:GetGridIndex(npc.Position)

        room:RemoveGridEntityImmediate(idx, 0, false)
        Isaac.ExecuteCommand("gridspawn 3000 "..tostring(idx))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, tarBabyInit, ToyboxMod.NPC_ENEMY)

---@param npc EntityNPC
local function tarBabyUpdate(_, npc)
    if(not (npc.Variant==ToyboxMod.NPC_TAR_BABY)) then return end

    local rng = npc:GetDropRNG()
    local room = Game():GetRoom()
    local sp = npc:GetSprite()

    if(npc.State==NpcState.STATE_INIT) then
        npc.State = NpcState.STATE_IDLE
        npc.ProjectileCooldown = JUMP_PROJCOOLDOWN
        npc.I1 = 0
        npc.I2 = -1
    end

    if(npc.ProjectileCooldown==0 and (npc.State==NpcState.STATE_IDLE or npc.State==NpcState.STATE_MOVE)) then
        local target = npc.Target
        if(not (target and target:Exists()) or npc.FrameCount%30==0) then
            npc.Target = npc:GetPlayerTarget()
            target = npc.Target
        end

        if(target and target:Exists()) then
            if(target.Position:Distance(npc.Position)<PROJ_TARGETRANGE) then
                npc.State = NpcState.STATE_ATTACK
                npc.TargetPosition = target.Position
                npc.StateFrame = 0
            elseif(isPositionPit(npc.Position) and ToyboxMod:generateRng(math.abs(rng:GetSeed()+npc.FrameCount//10)):RandomInt(8)==0) then
                npc.State = NpcState.STATE_SPECIAL
                npc.StateFrame = 0
            end
        end
    end

    if(npc.State==NpcState.STATE_IDLE) then
        if(npc.I2==-1 or npc.StateFrame%60==0) then
            local wasBadI2 = (npc.I2==-1)
            local targetPitIdxs = {}
            if(npc.I1==0) then
                for i=-40, 40, 40 do
                    for j=-40, 40, 40 do
                        local idx = room:GetGridIndex(npc.Position+Vector(i,j))
                        local ent = room:GetGridEntity(idx)
                        if(ent and ent:ToPit()) then
                            table.insert(targetPitIdxs, idx)
                        end
                    end
                end
            end
            if(#targetPitIdxs>0) then
                npc.I2 = targetPitIdxs[rng:RandomInt(1,#targetPitIdxs)]
                if(wasBadI2) then
                    npc.TargetPosition = room:GetGridPosition(npc.I2)
                end
            end
        end

        if(npc.I1==0 and npc.I2==-1) then
            npc.State = NpcState.STATE_MOVE
            npc.TargetPosition = Vector(0,0)
            npc.StateFrame = 0
        else
            sp:Play("Idle")

            if(npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) or npc:HasEntityFlags(EntityFlag.FLAG_FEAR)) then
                npc:MultiplyFriction(0.8)
            else
                if(npc.StateFrame%30==1) then
                    if(npc.I2==-1) then
                        local target = npc.Target
                        if(not (target and target:Exists())) then
                            npc.Target = npc:GetPlayerTarget()
                            target = npc.Target
                        end

                        npc.TargetPosition = npc.Position
                        if(target and target:Exists() and target.Position:Distance(npc.Position)>30*3) then
                            npc.TargetPosition = target.Position+(npc.Position-target.Position):Resized(30*4)
                        end
                    else
                        npc.TargetPosition = room:GetGridPosition(npc.I2)+(20-npc.Size)*Vector(rng:RandomFloat()*2-1, rng:RandomFloat()*2-1)
                    end

                    local jumpchance = (npc.StateFrame>30*5 and 3 or 8)
                    if(isPositionPit(npc.Position) and rng:RandomInt(jumpchance)==0) then
                        npc.State = NpcState.STATE_SPECIAL
                        npc.StateFrame = 0
                    end
                end

                npc.Velocity = ToyboxMod:lerp(npc.Velocity, (npc.TargetPosition-npc.Position):Resized(MOVESPEED), 0.1)
            end
        end
    elseif(npc.State==NpcState.STATE_MOVE) then
        sp:Play("Idle")

        local targetgrid = room:GetGridEntityFromPos(npc.TargetPosition)
        if(npc.I1==0 and not (targetgrid and targetgrid:ToPit())) then
            local nearestPit = nil
            for i=0, room:GetGridSize()-1 do
                local ent = room:GetGridEntity(i)
                if(ent and ent:ToPit()) then
                    if(not (nearestPit and npc.Position:Distance(room:GetGridPosition(nearestPit))<npc.Position:Distance(room:GetGridPosition(i)))) then
                        nearestPit = i
                    end
                end
            end
            
            if(nearestPit) then
                npc.TargetPosition = room:GetGridPosition(nearestPit)
                targetgrid = room:GetGridEntity(nearestPit)
            else
                npc.I1 = 1
                npc.State = NpcState.STATE_IDLE
                npc.StateFrame = 0
            end
        end

        local targetdist = npc.Position:Distance(npc.TargetPosition)

        if(npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) or npc:HasEntityFlags(EntityFlag.FLAG_FEAR)) then
            npc:MultiplyFriction(0.8)
        elseif(npc.I1==0) then
            local targetvel = (npc.TargetPosition-npc.Position):Resized(SEEK_PIT_SPEED)
            local reducethreshold = 10
            if(targetdist<SEEK_PIT_SPEED*reducethreshold) then
                targetvel = targetvel*targetdist/(SEEK_PIT_SPEED*reducethreshold)
            end

            npc.Velocity = ToyboxMod:lerp(npc.Velocity, targetvel, 0.1)
        end
        if(npc.I1~=0 or targetdist<SEEK_PIT_SPEED) then
            npc.State = NpcState.STATE_IDLE
            npc.I2 = -1
            npc.StateFrame = 0
        end
    elseif(npc.State==NpcState.STATE_ATTACK) then
        if(npc.StateFrame==1) then
            sp:Play("Attack", true)
        end

        if(sp:IsEventTriggered("Shoot")) then
            local pp = ProjectileParams()
            --pp.BulletFlags = ProjectileFlags.GOO
            pp.FallingAccelModifier = 1.3
            pp.FallingSpeedModifier = -15
            pp.Color = Color.ProjectileTar
            pp.Scale = 2.5
            local proj = npc:FireProjectilesEx(npc.Position,(npc.TargetPosition-npc.Position)*0.05,ProjectileMode.SINGLE,pp)[1]
            ToyboxMod:setEntityData(proj, "TARBABY_BURSTPROJ", true)
            ToyboxMod:setEntityData(proj, "TARBABY_TARPROJ", true)

            sfx:Play(SoundEffect.SOUND_ANGRY_GURGLE, 1.1, 2, false, 1.1)
        end

        if(sp:IsFinished("Attack")) then
            npc.ProjectileCooldown = PROJ_COOLDOWN
            npc.State = NpcState.STATE_IDLE
            npc.I2 = -1
            npc.StateFrame = 0
        end

        npc:MultiplyFriction(0.8)
    elseif(npc.State==NpcState.STATE_SPECIAL) then
        if(npc.StateFrame==1) then
            sp:Play("Vanish", true)
        end

        if(sp:IsFinished("Vanish")) then
            sp:Play("Vanish2", true)

            local positions = {}
            for i=0, room:GetGridSize()-1 do
                local ent = room:GetGridEntity(i)
                if(ent and ent:ToPit()) then
                    if(not (room:GetGridPosition(i):Distance(npc.Position)<JUMP_MINDIST)) then
                        table.insert(positions, {room:GetGridPosition(i), 1})
                    end
                end
            end
            for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_BLACK)) do
                if(not (ent.Position:Distance(npc.Position)<JUMP_MINDIST)) then
                    table.insert(positions, {ent, 2})
                end
            end

            local finalpos = npc.Position
            
            local numtopick = #positions
            if(numtopick>0) then
                local result = positions[rng:RandomInt(1,numtopick)]
                if(result[2]==1) then
                    finalpos = result[1]+(20-npc.Size)*Vector(rng:RandomFloat()*2-1, rng:RandomFloat()*2-1)
                else
                    finalpos = result[1].Position+(result[1].SpriteScale*15)*Vector(rng:RandomFloat()*2-1, rng:RandomFloat()*2-1)
                end
            else
                finalpos = room:GetRandomPosition(30)
            end
            npc.Position = finalpos
        end
        if(sp:IsFinished("Vanish2")) then
            npc.ProjectileCooldown = JUMP_PROJCOOLDOWN
            npc.State = NpcState.STATE_IDLE
            npc.I2 = -1
            npc.StateFrame = 0
        end

        if(sp:IsEventTriggered("Jump")) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            local splash = Isaac.Spawn(1000,132,0,npc.Position,Vector.Zero,nil):ToEffect()
            splash.Color = Color.ProjectileTar
            sfx:Play(SoundEffect.SOUND_BOSS2_DIVE)
        end
        if(sp:IsEventTriggered("Land")) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            local splash = Isaac.Spawn(1000,132,0,npc.Position,Vector.Zero,nil):ToEffect()
            splash.Color = Color.ProjectileTar
            --sfx:Play(SoundEffect.SOUND_BOSS2_WATERTHRASHING)
        end

        npc:MultiplyFriction(0.8)
    end

    npc.ProjectileCooldown = math.max(npc.ProjectileCooldown-1, 0)
    npc.StateFrame = npc.StateFrame+1
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, tarBabyUpdate, ToyboxMod.NPC_ENEMY)

---@param proj EntityProjectile
local function haemoProjDeath(_, proj)
    if(ToyboxMod:getEntityData(proj, "TARBABY_BURSTPROJ")) then
        local sp = proj.SpawnerEntity
        if(sp and sp:ToNPC()) then
            local rng = ToyboxMod:generateRng()

            local numProj = 8+math.random(0,3)
            for i=1, numProj do
                local angle = (i/numProj)*360+(rng:RandomFloat()-0.5)*360/numProj
                local vel = Vector.FromAngle(angle):Resized(3+rng:RandomFloat()*5)

                local pp = ProjectileParams()
                pp.Color = Color.ProjectileTar
                pp.FallingAccelModifier = 1.4+rng:RandomFloat()*0.5
                pp.FallingSpeedModifier = -4-rng:RandomFloat()*3
                pp.Scale = 0.8+rng:RandomFloat()*0.9
                
                local nproj = sp:ToNPC():FireProjectilesEx(proj.Position, vel, ProjectileMode.SINGLE, pp)[1]

                ToyboxMod:setEntityData(nproj, "TARBABY_TARPROJ", true)
            end
        end
    end
    if(ToyboxMod:getEntityData(proj, "TARBABY_TARPROJ")) then
        local tar = Isaac.Spawn(1000,EffectVariant.CREEP_BLACK,0,proj.Position,Vector.Zero,proj.SpawnerEntity):ToEffect()
        tar.SpriteScale = tar.SpriteScale*proj.Scale
        tar:SetTimeout(TARCREEP_TIMEOUT)

        tar:Update()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, haemoProjDeath, ProjectileVariant.PROJECTILE_NORMAL)

---@param npc EntityNPC
local function renderRockOnStumpy(_, npc, offset)
    if(not (npc.Variant==ToyboxMod.NPC_TAR_BABY)) then return end
    
    if(npc.I2~=-1) then
        local i2pos = Game():GetRoom():GetGridPosition(npc.I2)
        i2pos = Isaac.WorldToRenderPosition(i2pos)
        Isaac.RenderText("I2", i2pos.X, i2pos.Y, 1,1,0,1)
    end

    local tgpos = npc.TargetPosition
    tgpos = Isaac.WorldToRenderPosition(tgpos)
    Isaac.RenderText("TG", tgpos.X, tgpos.Y, 1,0,1,1)
end
--ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, renderRockOnStumpy, ToyboxMod.NPC_ENEMY)