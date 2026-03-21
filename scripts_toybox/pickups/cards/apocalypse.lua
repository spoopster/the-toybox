local sfx = SFXManager()

local ENTRY_ROOMBOUND = 40*10
local EXIT_ROOMBOUND = 40*20

local HORSEMAN_COLLDMG = 7
local HORSEMAN_COLLFREQ = 3

local FAMINE_COLLDMG = 11
local PESTILENCE_POISONDUR = 30*3
local PESTILENCE_POISONDMG = 4
local DEATH_SLOWDUR = 30*3
local DEATH_SLOWVAL = 0.7

---@param pl EntityPlayer
---@param flags UseFlag
local function useApocalypse(_, _, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    for i=0, ((flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) and 1 or 0) do
        local horseman = Isaac.Spawn(1000,ToyboxMod.EFFECT_APOCALYPSE_HELPER,i,Vector.Zero,Vector.Zero,pl):ToEffect()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useApocalypse, ToyboxMod.CARD_APOCALYPSE)



---@param effect EntityEffect
local function horsemanInit(_, effect)
    local rng = effect:GetDropRNG()
    local room = Game():GetRoom()
    local pos = Vector(-ENTRY_ROOMBOUND, rng:RandomInt(room:GetTopLeftPos().Y+40, room:GetBottomRightPos().Y-40))

    effect.Position = pos
    effect.Velocity = Vector(15,0)
    effect.CollisionDamage = HORSEMAN_COLLDMG

    effect.MinRadius = rng:RandomInt(-3,0)

    local sp = effect:GetSprite()
    if(effect.SubType==0) then -- famine
        sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A)
    
        sp:Load("gfx/063.000_famine.anm2", true)
        sp:Play("AttackDash", true)

        effect.CollisionDamage = FAMINE_COLLDMG
        effect.Velocity = effect.Velocity*1.05
    elseif(effect.SubType==1) then
        sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A)

        sp:Load("gfx/064.000_pestilence.anm2", true)
        sp:Play("Walk", true)

        effect.MaxRadius = 9
        effect.Velocity = effect.Velocity*0.97
    elseif(effect.SubType==2) then
        sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A)

        sp:Load("gfx/065.000_war.anm2", true)
        sp:Play("Dash", true)

        effect.MaxRadius = 8
        effect.Velocity = effect.Velocity*1.02
    elseif(effect.SubType==3) then
        sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A)

        sp:Load("gfx/066.000_death.anm2", true)
        sp:Play("Walk", true)

        effect.MaxRadius = 6
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, horsemanInit, ToyboxMod.EFFECT_APOCALYPSE_HELPER)

---@param effect EntityEffect
local function horsemanUpdate(_, effect)
    local sp = effect:GetSprite()
    local rng = effect:GetDropRNG()
    local room = Game():GetRoom()

    if(effect.Position.X>=room:GetBottomRightPos().X+EXIT_ROOMBOUND) then
        local neweff = Isaac.Spawn(effect.Type, effect.Variant, (effect.SubType+1)%4, Vector.Zero, Vector.Zero, effect.SpawnerEntity):ToEffect()
        effect:Remove()
    else
        if((effect.FrameCount+effect.MinRadius)%HORSEMAN_COLLFREQ==0) then
            local effRef = EntityRef(effect)
            local plRef = effRef
            if(effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()) then
                plRef = EntityRef(effect.SpawnerEntity:ToPlayer())
            end

            for _, ent in ipairs(Isaac.FindInRadius(effect.Position,20,EntityPartition.ENEMY | EntityPartition.PLAYER)) do
                if(ent:ToPlayer() or ToyboxMod:isValidEnemy(ent)) then
                    if(ent:ToPlayer()) then
                        ent:TakeDamage(2, 0, effRef, 0)
                    else
                        ent:TakeDamage(effect.CollisionDamage, 0, effRef, 0)
                        if(effect.SubType==1) then
                            ent:AddPoison(plRef, -PESTILENCE_POISONDUR, PESTILENCE_POISONDMG)
                        elseif(effect.SubType==3) then
                            ent:AddSlowing(plRef, -DEATH_SLOWDUR, DEATH_SLOWVAL, Color(1,1,1.3,1,0.16,0.16,0.16))
                        end
                    end
                    
                    ent:AddVelocity((ent.Position-effect.Position):Resized(10))
                end
            end
        end

        if(effect.SubType==1 and room:IsPositionInRoom(effect.Position, 0) and effect.FrameCount%3==0) then
            local creep = Isaac.Spawn(1000,EffectVariant.CREEP_GREEN,0,effect.Position,Vector.Zero,effect):ToEffect()
            creep.SpriteScale = Vector(1,1)*1.5
            creep:SetTimeout(30*3)
        end

        if(not room:IsPositionInRoom(effect.Position,20)) then
            if(effect.SubType==1) then
                if(not room:IsPositionInRoom(effect.Position+effect.Velocity*12, 20) and room:IsPositionInRoom(effect.Position+effect.Velocity*13, 20)) then
                    sp:Play("Attack1", true)
                end

                if(sp:IsFinished()) then
                    sp:Play("Walk")
                end
            elseif(effect.SubType==3) then
                if(not room:IsPositionInRoom(effect.Position+effect.Velocity*14, 20) and room:IsPositionInRoom(effect.Position+effect.Velocity*15, 20)) then
                    sp:Play("Attack01", true)
                end

                if(sp:IsFinished()) then
                    sp:Play("Walk")
                end
            end

            return
        end

        --print(effect.SubType, "|", effect.State, effect.MinRadius, effect.MaxRadius, (effect.State+effect.MinRadius+effect.MaxRadius)%effect.MaxRadius)
        if(effect.SubType==1 and (effect.State+effect.MinRadius+effect.MaxRadius)%effect.MaxRadius==0) then
            local idx = (((effect.State+effect.MinRadius+effect.MaxRadius)//effect.MaxRadius)%2)*2-1

            sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_0)

            sp:SetFrame("Attack1",14)
            sp:Continue()

            local vel = Vector.FromAngle(rng:RandomInt(360))*2.5
            local proj = Isaac.Spawn(9,0,0,effect.Position,vel,effect):ToProjectile()
            proj:AddProjectileFlags(ProjectileFlags.EXPLODE | ProjectileFlags.HIT_ENEMIES)
            proj.Color = Color.ProjectileIpecac
            proj.Scale = 2

            proj.FallingAccel = 1
            proj.FallingSpeed = -20
        end
        if(effect.SubType==2 and (effect.State+effect.MinRadius+effect.MaxRadius)%effect.MaxRadius==0) then
            local vel = Vector.FromAngle(rng:RandomInt(360))*1.5
            local bomb = Isaac.Spawn(4,BombVariant.BOMB_TROLL,0,effect.Position,vel,effect):ToBomb()
        end
        if(effect.SubType==3 and (effect.State+effect.MinRadius+effect.MaxRadius)%effect.MaxRadius==0) then
            local idx = (((effect.State+effect.MinRadius+effect.MaxRadius)//effect.MaxRadius)%2)*2-1

            if(idx==1) then
                sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_5)

                sp:SetFrame("Attack01",16)
                sp:Continue()
            end

            local scythe = Isaac.Spawn(9,0,0,effect.Position,Vector.Zero,effect.SpawnerEntity):ToProjectile()
            ToyboxMod:setEntityData(scythe, "APOCALYPSE_DEATH_SCYTHE", idx)
            scythe:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
            scythe.FallingAccel = -0.1
            scythe:SetSize(scythe.Size, scythe.SizeMulti*2.5, 12)

            scythe.CollisionDamage = 2

            local scSp = scythe:GetSprite()
            scSp:Load("gfx/066.010_death scythe.anm2", true)
            scSp:Play("Appear", true)
        end

        effect.State = effect.State+1
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, horsemanUpdate, ToyboxMod.EFFECT_APOCALYPSE_HELPER)



---@param proj EntityProjectile
local function projectileUpdate(_, proj)
    local pidx = ToyboxMod:getEntityData(proj, "APOCALYPSE_DEATH_SCYTHE")
    if(not pidx) then return end

    proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    local sp = proj:GetSprite()
    
    local startmove = 20
    if(proj.FrameCount==startmove) then
        sp:Play("Throw", true)
    end

    if(proj.FrameCount>=startmove) then
        proj:AddVelocity(Vector(0,0.5)*pidx)

        sp.PlaybackSpeed = math.min(proj.Velocity:Length()/5, 1)

        if(proj.Position:Distance(Game():GetRoom():GetClampedPosition(proj.Position,0))>300) then
            proj:Die()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, projectileUpdate)

---@param proj EntityProjectile
local function projectileDeath(_, proj)
    local pidx = ToyboxMod:getEntityData(proj, "APOCALYPSE_DEATH_SCYTHE")
    if(not pidx) then return end

end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, projectileDeath)