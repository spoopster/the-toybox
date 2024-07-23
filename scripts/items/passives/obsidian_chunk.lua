local mod = MilcomMOD

local NUM_PEBBLE_TEARS = 20
local PEBBLE_DMG = 1
local PEBBLE_SPREAD = 40
local PEBBLE_SPEED = 9

local CHUNK_DMGMULT = 2

local OBSIDIAN_CHANCE = 0.05
local OBSIDIAN_CHANCEMAX = 0.35
local MAXLUCK = 25

local CHUNK_TEARCOLOR = Color(0.9,0.8,0.9,1)
CHUNK_TEARCOLOR:SetColorize(0.6,0.49,0.72,1)
local CHUNK_ROCKCOLOR = Color(0.9,0.8,0.9,1)
CHUNK_ROCKCOLOR:SetColorize(0.6,0.49,0.72,0.4)

local function getTriggerChance(luckval, chancemult)
    return mod:getLuckAffectedChance(luckval, OBSIDIAN_CHANCE*chancemult, MAXLUCK/chancemult, OBSIDIAN_CHANCEMAX)
end

local function firePebbleTear(pos, vel, spawner, rng)
    local pebble = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.ROCK, 0, pos, vel, spawner):ToTear()
    pebble.CollisionDamage = PEBBLE_DMG
    pebble.Scale = 0.5
    pebble.SpriteScale = pebble.SpriteScale*(1/pebble.Scale)

    pebble.FallingAcceleration = pebble.FallingAcceleration+(rng:RandomFloat()-0.5)*0.3+1.5
    pebble.FallingSpeed = pebble.FallingSpeed-18-(rng:RandomFloat()-0.5)*4

    mod:setEntityData(pebble, "OBSIDIAN_SHARD_TEAR", true)
    pebble:AddTearFlags(TearFlags.TEAR_PIERCING)

    pebble.Color = CHUNK_TEARCOLOR

    return pebble
end

--#region --! TEARS

---@param tear EntityTear
---@param player EntityPlayer
local function chunkFireTear(_, tear, player, isLudo)
    if(not player:HasCollectible(mod.COLLECTIBLE_OBSIDIAN_CHUNK)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_CHUNK)

    if(rng:RandomFloat()>=getTriggerChance(player.Luck, (isLudo and 0.75 or 1))) then return end

    if(not isLudo) then
        tear:ChangeVariant(TearVariant.ROCK)
        tear.Color = CHUNK_TEARCOLOR
    end
    tear.CollisionDamage = tear.CollisionDamage*CHUNK_DMGMULT

    local angle = {Min=tear.Velocity:GetAngleDegrees()-PEBBLE_SPREAD/2, Max=tear.Velocity:GetAngleDegrees()+PEBBLE_SPREAD/2}
    if(isLudo) then angle = {Min=0, Max=360} end

    local numTears = math.floor(NUM_PEBBLE_TEARS/mod:getTps(player))
    for i=1, numTears do
        local v = Vector.FromAngle(mod:lerp(angle.Min, angle.Max, rng:RandomFloat()))*PEBBLE_SPEED*player.ShotSpeed
        v = v:Resized(v:Length()+rng:RandomFloat()*5-4)

        local pebble = firePebbleTear(tear.Position, v, player, rng)
    end

    mod:setEntityData(tear, "OBSIDIAN_CHUNK_TEAR", true)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, chunkFireTear)

--#endregion

--#region --! BOMBS

---@param bomb EntityBomb
---@param player EntityPlayer
local function chunkFireBomb(_, bomb, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_OBSIDIAN_CHUNK)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_CHUNK)

    if(rng:RandomFloat()>=getTriggerChance(player.Luck, 1.5)) then return end

    bomb.ExplosionDamage = bomb.ExplosionDamage*CHUNK_DMGMULT
    bomb.Color = CHUNK_TEARCOLOR

    mod:setEntityData(bomb, "OBSIDIAN_CHUNK_TEAR", true)
    mod:setEntityData(bomb, "OBCHUNK_INIT_FIRE_DIR", bomb.Velocity:Normalized())
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, chunkFireBomb)

---@param bomb EntityBomb
---@param player EntityPlayer
local function chunkBombExplode(_, bomb, player, isIncubus)
    if(not mod:getEntityData(bomb, "OBSIDIAN_CHUNK_TEAR")) then return end

    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_CHUNK)

    local dir = mod:getEntityData(bomb, "OBCHUNK_INIT_FIRE_DIR")
    local angle = {Min=0, Max=360}
    local isScatter = mod:getEntityData(bomb, "IS_SCATTER_BOMB")

    local numTears = math.floor((isScatter and 0.2 or 1)*1.5*NUM_PEBBLE_TEARS/mod:getTps(player))
    for i=1, numTears do
        local v = Vector.FromAngle(mod:lerp(angle.Min, angle.Max, rng:RandomFloat()))*PEBBLE_SPEED*1.3*player.ShotSpeed
        v = v:Resized(v:Length()+rng:RandomFloat()*5-4)

        local pebble = firePebbleTear(bomb.Position, v, player, rng)
        pebble.CollisionDamage = pebble.CollisionDamage*2.5
        mod:setEntityData(pebble, "OBCHUNK_IGNORE_BOMBS", true)
    end

    local spawnData = {
        SpawnType = "CIRCLE",
        SpawnData = {EntityType.ENTITY_EFFECT,EffectVariant.ROCK_EXPLOSION,0},
        SpawnerEntity = player,
        Position = bomb.Position,
        Damage = PEBBLE_DMG*3,
        PlayerFriendly = true,
        AngleVariation = 20,
        Radius = Vector(35,35),
        RadiusCount = 7,
        DamageCooldown = 10,
        Color = CHUNK_ROCKCOLOR,
    }
    if(mod:getTps(player)>3 or isScatter) then
        spawnData.SpawnType = "SINGLE"
    end

    mod:spawnCustomObjects(spawnData)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_BOMB_DETONATE, chunkBombExplode)

local function pebbleIgnoreBombs(_, tear, coll, low)
    if(mod:getEntityData(tear, "OBCHUNK_IGNORE_BOMBS") and coll:ToBomb()) then return true end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, pebbleIgnoreBombs)

---@param bomb EntityBomb
---@param ogbomb EntityBomb
local function chunkCopyScatterData(_, bomb, ogbomb)
    mod:setEntityData(bomb, "OBSIDIAN_CHUNK_TEAR", mod:getEntityData(ogbomb, "OBSIDIAN_CHUNK_TEAR"))
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.COPY_SCATTER_BOMB_DATA, chunkCopyScatterData)

--#endregion

--#region --! ROCKETS

---@param rocket EntityEffect
---@param player EntityPlayer
local function chunkFireRocket(_, rocket, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_OBSIDIAN_CHUNK)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_CHUNK)

    if(rng:RandomFloat()>=getTriggerChance(player.Luck, 1.5)) then return end

    mod:setEntityData(rocket, "OBSIDIAN_CHUNK_TEAR", true)
    mod:setEntityData(rocket, "EXPLOSION_COLOR", CHUNK_TEARCOLOR)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_ROCKET, chunkFireRocket)
---@param rocket EntityEffect
---@param target EntityEffect
local function chunkCopyTargetData(_, rocket, target)
    mod:setEntityData(rocket, "OBSIDIAN_CHUNK_TEAR", mod:getEntityData(target, "OBSIDIAN_CHUNK_TEAR"))
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.ROCKET_COPY_TARGET_DATA, chunkCopyTargetData)

---@param rocket EntityEffect
---@param player EntityPlayer
local function chunkRocketExplode(_, rocket, expl, player)
    if(not mod:getEntityData(rocket, "OBSIDIAN_CHUNK_TEAR")) then return end
    if(not (rocket.Position:Distance(expl.Position)<0.01)) then return end

    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_CHUNK)

    local dir = mod:getEntityData(rocket, "OBCHUNK_INIT_FIRE_DIR")
    local angle = {Min=0, Max=360}

    local numTears = math.floor(1.5*NUM_PEBBLE_TEARS)
    for i=1, numTears do
        local v = Vector.FromAngle(mod:lerp(angle.Min, angle.Max, rng:RandomFloat()))*PEBBLE_SPEED*1.3*player.ShotSpeed
        v = v:Resized(v:Length()+rng:RandomFloat()*5-4)

        local pebble = firePebbleTear(expl.Position, v, player, rng)
        pebble.CollisionDamage = pebble.CollisionDamage*4
    end

    local spawnData = {
        SpawnType = "CIRCLELINE",
        SpawnData = {EntityType.ENTITY_EFFECT,EffectVariant.ROCK_EXPLOSION,0},
        SpawnerEntity = player,
        Position = expl.Position,
        Amount = 2,
        Damage = PEBBLE_DMG*4,
        PlayerFriendly = true,
        TimerExtraFunction = function(timer)
            local data = mod:getEntityDataTable(timer).COBJ_DATA
            data.RadiusCount = data.RadiusCount+3
        end,
        Distance = Vector(20,20),
        Delay = 5,
        AngleVariation = 0,
        Radius = Vector(20,20),
        RadiusCount = 4,
        DamageCooldown = 10,
    }
    mod:spawnCustomObjects(spawnData)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ROCKET_EXPLODE, chunkRocketExplode)

--#endregion

--#region --! LASER

---@param player EntityPlayer
---@param ent Entity
local function postLaserDamage(_, dmgtype, player, ent)
    if(not (dmgtype==mod.DAMAGE_TYPE.LASER or dmgtype==mod.DAMAGE_TYPE.KNIFE)) then return end

    if(not player:HasCollectible(mod.COLLECTIBLE_OBSIDIAN_CHUNK)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE_OBSIDIAN_CHUNK)
    if(rng:RandomFloat()>=getTriggerChance(player.Luck, 0.8)) then return end

    local angle = {Min=0, Max=360}

    local numTears = math.floor(0.75*NUM_PEBBLE_TEARS/mod:getTps(player))
    for i=1, numTears do
        local v = Vector.FromAngle(mod:lerp(angle.Min, angle.Max, rng:RandomFloat()))*PEBBLE_SPEED*0.75*player.ShotSpeed
        v = v:Resized(v:Length()+rng:RandomFloat()*5-4)

        local pebble = firePebbleTear(ent.Position, v, player, rng)
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_EXTRA_DMG, postLaserDamage)

--#endregion