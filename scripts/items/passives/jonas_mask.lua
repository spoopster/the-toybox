local mod = MilcomMOD
local sfx = SFXManager()

--#region MASK

local NUM_TOSPAWN = 1

---@param pl EntityPlayer
local function evalCache(_, pl)
    local numFamiliers = {[0]=0, [1]=0, [2]=0}

    local numCollectibles = pl:GetCollectibleNum(mod.COLLECTIBLE_JONAS_MASK)+pl:GetEffects():GetCollectibleEffectNum(mod.COLLECTIBLE_JONAS_MASK)
    local rng = mod:generateRng(Game():GetLevel():GetDungeonPlacementSeed()+pl:GetPlayerIndex())
    for _=1, numCollectibles do
        local idx = rng:RandomInt(3)
        numFamiliers[idx] = numFamiliers[idx]+1
    end

    local plrng = pl:GetCollectibleRNG(mod.COLLECTIBLE_JONAS_MASK)
    for i=0, 2 do
        pl:CheckFamiliar(
            mod.FAMILIAR_MASK_SHADOW,
            numFamiliers[i],
            plrng,
            Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_JONAS_MASK),
            i
        )
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FAMILIARS)
--#endregion

--#region FLY FAMILIAR

local FLY_COLL_DAMAGE = 1

local SCREAM_TRYFREQ = 15
local SCREAM_CHANCE = 0.2
local SCREAM_TRYRADIUS = 40*1.8

local SCREAM_COOLDOWN = 30*4
local SCREAM_DAMAGE = 10
local SCREAM_CONFUSE_DURATION = 30*3.5
local SCREAM_RADIUS = 40*2.25

local DIAG_SPEED = 1.2

---@param fam EntityFamiliar
local function shadowFlyInit(fam)
    fam.State = 0
    fam.CollisionDamage = FLY_COLL_DAMAGE

    local layer = fam:GetSprite():GetLayer(2)
    layer:SetRenderFlags(layer:GetRenderFlags() | AnimRenderFlags.ENABLE_LAYER_LIGHTING)
end

---@param fam EntityFamiliar
local function shadowFlyUpdate(fam)
    local sp = fam:GetSprite()
    local rng = fam:GetDropRNG()

    if(fam.State==0) then
        if(fam.FireCooldown<=0 and fam.FrameCount%SCREAM_TRYFREQ==0) then
            local enemyNum = 0
            for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, SCREAM_TRYRADIUS, EntityPartition.ENEMY)) do
                if(mod:isValidEnemy(enemy)) then
                    enemyNum = enemyNum+1
                end
            end

            if(enemyNum>0 and rng:RandomFloat()<math.sqrt(enemyNum)*SCREAM_CHANCE) then
                fam.State = 1
            end
        end

        fam.FireCooldown = math.max(0, fam.FireCooldown-1)
        fam:MoveDiagonally(DIAG_SPEED)
    elseif(fam.State==1) then
        if(sp:IsFinished("Scream")) then
            sp:Play("Idle", true)
            fam.State = 0
            fam.FireCooldown = SCREAM_COOLDOWN
        elseif(not sp:IsPlaying("Scream")) then
            sp:Play("Scream", true)
        end

        if(sp:IsEventTriggered("Scream")) then
            local poof = Isaac.Spawn(1000,144,1,fam.Position,Vector.Zero,fam):ToEffect()
            sfx:Play(SoundEffect.SOUND_DEMON_HIT)
            --sfx:Play(mod.SFX_SHADOW_SCREAM, 1, 0, false, 0.95+rng:RandomFloat()*0.1)

            local screamShockwave = Isaac.Spawn(1000, EffectVariant.SIREN_RING, 0, fam.Position, Vector.Zero, fam):ToEffect()
            screamShockwave.SpriteScale = Vector(1,1)*0.6
            screamShockwave.Color = Color(0,0,0,1,0.5)
            screamShockwave:GetSprite().PlaybackSpeed = 1.65
        end

        if(sp:IsEventTriggered("ScreamHurt")) then
            for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, SCREAM_RADIUS, EntityPartition.ENEMY)) do
                enemy:TakeDamage(SCREAM_DAMAGE, 0, EntityRef(fam), 0)
                enemy:AddConfusion(EntityRef(fam), SCREAM_CONFUSE_DURATION, false)
            end
        end

        fam.Velocity = fam.Velocity*0.75
    end
end
--#endregion

--#region CRAWLER FAMILIAR

local CRAWLER_COLL_DAMAGE = 1.5

local CRAWLER_ACTION_FREQ = 40
local JUMP_CHANCE = 0.25
local JUMP_CHANCE_NOTARGET = 0.1
local MAX_JUMP_TRY_FRAMES = CRAWLER_ACTION_FREQ*6

local CRAWLER_TARGET_DIST = 40*5
local CRAWLER_SPEED = 8.5
local CRAWLER_MOVE_DUR = 15
local CRAWLER_MOVE_RAND_ARC = 10

local CRAWLER_JUMP_FRAMES = 10
local CRAWLER_JUMP_DIST = 40*2

local CRAWLER_EXP_RADIUS = 40*2
local CRAWLER_EXP_DAMAGE = 20
local CRAWLER_EXP_SLOWDUR = 30*2.5

---@param fam EntityFamiliar
local function shadowCrawlerInit(fam)
    fam.State = 0
    fam.CollisionDamage = CRAWLER_COLL_DAMAGE
    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

    fam:GetSprite():Play("Idle", true)

    local layer = fam:GetSprite():GetLayer(1)
    layer:SetRenderFlags(layer:GetRenderFlags() | AnimRenderFlags.ENABLE_LAYER_LIGHTING)
end

---@param fam EntityFamiliar
local function shadowCrawlerUpdate(fam)
    local sp = fam:GetSprite()
    local rng = fam:GetDropRNG()
    local data = mod:getEntityDataTable(fam)

    data.TARGET_POS = data.TARGET_POS or Vector.Zero

    if(fam.State==0) then
        fam.FireCooldown = fam.FireCooldown+1

        if(fam.FireCooldown%CRAWLER_ACTION_FREQ==0) then
            local target = nil
            for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, CRAWLER_TARGET_DIST, EntityPartition.ENEMY)) do
                if(mod:isValidEnemy(enemy) and Game():GetRoom():CheckLine(enemy.Position, fam.Position, LineCheckMode.ENTITY)) then
                    target = enemy
                end
            end
            if(target==nil) then
                if(fam.Player and fam.Player.Position:Distance(fam.Position)<CRAWLER_TARGET_DIST and Game():GetRoom():CheckLine(fam.Player.Position, fam.Position, LineCheckMode.ENTITY)) then
                    target = fam.Player
                end
            end

            if(target) then
                data.TARGET_POS = (target.Position-fam.Position):Rotated(rng:RandomInt(CRAWLER_MOVE_RAND_ARC*2+1)-CRAWLER_MOVE_RAND_ARC)
            else
                data.TARGET_POS = Vector(-1000,-1000)
                while(not Game():GetRoom():IsPositionInRoom(fam.Position+data.TARGET_POS*CRAWLER_SPEED*4, 5)) do
                    data.TARGET_POS = Vector.FromAngle(rng:RandomInt(360))
                end
                data.TARGET_POS = data.TARGET_POS*CRAWLER_JUMP_DIST
            end

            if(fam.FireCooldown>=MAX_JUMP_TRY_FRAMES or rng:RandomFloat()<(target and JUMP_CHANCE or JUMP_CHANCE_NOTARGET)) then
                fam.FireCooldown = 0
                fam.State=1

                data.TARGET_POS = data.TARGET_POS/CRAWLER_JUMP_FRAMES

                sp:Play("Jump", true)
            else
                sp:Play("Walk", true)
            end
        elseif(fam.FireCooldown%CRAWLER_ACTION_FREQ<CRAWLER_MOVE_DUR) then
            fam.Velocity = mod:lerp(fam.Velocity, (data.TARGET_POS or Vector.Zero):Resized(CRAWLER_SPEED), 0.6)
        else
            if(sp:GetAnimation()~="Idle") then
                sp:Play("Idle", true)
            end

            fam.Velocity = fam.Velocity*0.6
        end
    elseif(fam.State==1) then
        fam.FireCooldown = fam.FireCooldown+1

        if(sp:IsEventTriggered("Jump")) then
            fam.FireCooldown = 0
            fam.Velocity = (data.TARGET_POS or Vector.Zero)
        end
        if(sp:IsEventTriggered("Land")) then
            fam.FireCooldown = CRAWLER_JUMP_FRAMES

            if(not mod:isRoomClear()) then
                local poof = Isaac.Spawn(1000,144,1,fam.Position,Vector.Zero,fam):ToEffect()
                sfx:Play(SoundEffect.SOUND_DEMON_HIT)
                local screamShockwave = Isaac.Spawn(1000, EffectVariant.SIREN_RING, 0, fam.Position, Vector.Zero, fam):ToEffect()
                screamShockwave.SpriteScale = Vector(1,1)*0.6
                screamShockwave.Color = Color(0,0,0,1,0.5)
                screamShockwave:GetSprite().PlaybackSpeed = 1.65
                for i=1, 7 do
                    screamShockwave:Update()
                end

                for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, CRAWLER_EXP_RADIUS, EntityPartition.ENEMY)) do
                    if(mod:isValidEnemy(enemy) and Game():GetRoom():CheckLine(enemy.Position, fam.Position, LineCheckMode.EXPLOSION)) then
                        enemy:TakeDamage(CRAWLER_EXP_DAMAGE, DamageFlag.DAMAGE_EXPLOSION, EntityRef(fam), 0)
                        enemy:AddSlowing(EntityRef(fam), CRAWLER_EXP_SLOWDUR, 0.7, Color(1,0.9,0.9,1,0.3,0,0))
                    end
                end
            end
        end

        if(fam.FireCooldown>=CRAWLER_JUMP_FRAMES) then
            fam.Velocity = fam.Velocity*0.7
        end

        if(sp:IsFinished("Jump")) then
            sp:Play("Idle", true)
            fam.State = 0
            fam.FireCooldown = 30
            data.TARGET_POS = Vector.Zero
        end
    end
end
--#endregion

--#region URCHIN FAMILIAR

local URCHIN_COLL_DAMAGE = 7.13

local SPIKES_CHANCE = 0.5
local SPIKES_COOLDOWN = 30
local SPIKES_RADIUS = 40*2.5

local SPIKES_KNOCKBACK_DUR = 15
local SPIKES_KNOCKBACK_PROJSPEED = 12
local SPIKES_KNOCKBACK_ENEMYSPEED = 15

local ORBIT_SPEED = 0.018
local ORBIT_RADIUS = Vector(40,30)
local ORBIT_LAYER = 1713

---@param fam EntityFamiliar
local function shadowUrchinInit(fam)
    fam.State = 0
    fam.CollisionDamage = URCHIN_COLL_DAMAGE

    fam:AddToOrbit(ORBIT_LAYER)

    local layer = fam:GetSprite():GetLayer(1)
    layer:SetRenderFlags(layer:GetRenderFlags() | AnimRenderFlags.ENABLE_LAYER_LIGHTING)
end

---@param fam EntityFamiliar
local function shadowUrchinUpdate(fam)
    local sp = fam:GetSprite()
    local rng = fam:GetDropRNG()
    local pl = fam.Player

    fam.OrbitDistance = ORBIT_RADIUS
    fam.OrbitSpeed = ORBIT_SPEED
    fam.Velocity = mod:lerp(fam.Velocity, (fam:GetOrbitPosition(pl.Position+pl.Velocity)-fam.Position), 0.5)

    if(fam.State==0) then
        local projectiles = Isaac.FindInRadius(fam.Position, fam.Size, EntityPartition.BULLET)
        for _, proj in ipairs(projectiles) do
            proj:Die()
        end

        if(fam.FireCooldown<=0 and rng:RandomFloat()<SPIKES_CHANCE*#projectiles) then
            sp:Play("Spikes", true)
            fam.State = 1
        end

        fam.FireCooldown = math.max(0, fam.FireCooldown-1)
    elseif(fam.State==1) then
        if(sp:IsFinished("Spikes")) then
            sp:Play("Idle", true)
            fam.State = 0
            fam.FireCooldown = SPIKES_COOLDOWN
        elseif(not sp:IsPlaying("Spikes")) then
            sp:Play("Spikes", true)
        end

        if(sp:IsEventTriggered("Attack")) then
            local poof = Isaac.Spawn(1000,144,1,fam.Position,Vector.Zero,fam):ToEffect()
            sfx:Play(SoundEffect.SOUND_DEMON_HIT)

            for _, proj in ipairs(Isaac.FindInRadius(fam.Position, fam.Size+SPIKES_RADIUS, EntityPartition.BULLET)) do
                local dir = (proj.Position-fam.Position):Resized(SPIKES_KNOCKBACK_PROJSPEED)
                proj.Velocity = dir
            end
            for _, enemy in ipairs(Isaac.FindInRadius(fam.Position, fam.Size+SPIKES_RADIUS, EntityPartition.ENEMY)) do
                local dir = (enemy.Position-fam.Position):Resized(SPIKES_KNOCKBACK_ENEMYSPEED)

                enemy:AddKnockback(EntityRef(fam), dir, SPIKES_KNOCKBACK_DUR, true)
            end
        end
    end
end
--#endregion

--#region GENERIC FAMILIAR

local PARTICLE_SPAWNCHANCE = 0.4
local PARTICLE_SPAWNFREQ = 2

---@param fam EntityFamiliar
local function shadowFamiliarInit(_, fam)
    if(fam.SubType==mod.FAMILIAR_MASK_SHADOW_SUBTYPE.FLY) then
        shadowFlyInit(fam)
    elseif(fam.SubType==mod.FAMILIAR_MASK_SHADOW_SUBTYPE.URCHIN) then
        shadowUrchinInit(fam)
    elseif(fam.SubType==mod.FAMILIAR_MASK_SHADOW_SUBTYPE.CRAWLER) then
        shadowCrawlerInit(fam)
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, shadowFamiliarInit, mod.FAMILIAR_MASK_SHADOW)

---@param fam EntityFamiliar
local function shadowFamiliarUpdate(_, fam)
    if(fam.FrameCount%PARTICLE_SPAWNFREQ==0) then
        local rng = fam:GetDropRNG()

        if(rng:RandomFloat()<PARTICLE_SPAWNCHANCE) then
            local vel = Vector.FromAngle(rng:RandomInt(360))*(rng:RandomFloat()*0.4+0.6)*0.1
            local particle = Isaac.Spawn(1000, EffectVariant.HAEMO_TRAIL, 0, fam.Position+Vector(0,-17), vel, fam):ToEffect()
            particle.DepthOffset = -1000
            particle.Color = Color(0,0,0,1)
            particle.SpriteScale = Vector(1,1)*0.5

            if(fam.SubType==mod.FAMILIAR_MASK_SHADOW_SUBTYPE.CRAWLER) then
                particle.SpriteOffset = Vector(0,7)
            end
        end
    end

    if(fam.SubType==mod.FAMILIAR_MASK_SHADOW_SUBTYPE.FLY) then
        shadowFlyUpdate(fam)
    elseif(fam.SubType==mod.FAMILIAR_MASK_SHADOW_SUBTYPE.URCHIN) then
        shadowUrchinUpdate(fam)
    elseif(fam.SubType==mod.FAMILIAR_MASK_SHADOW_SUBTYPE.CRAWLER) then
        shadowCrawlerUpdate(fam)
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, shadowFamiliarUpdate, mod.FAMILIAR_MASK_SHADOW)

--#endregion