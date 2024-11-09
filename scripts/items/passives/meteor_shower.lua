local mod = MilcomMOD
local sfx = SFXManager()

local METEOR_COOLDOWN = 4*30
local METEOR_COOLDOWN_BIGROOM = 2*30
local METEORS_NUM = 1

local METEOR_SPEED = 30
local METEOR_FALLING_FRAMES = 2*30
local FALLING_FRAME_RANDOMNESS = 15

local METEOR_SCALE_MULT = 2

local function isBigRoom()
    local rType = Game():GetRoom():GetRoomShape()
    if(rType==RoomShape.ROOMSHAPE_2x2) then return true end
    if(rType==RoomShape.ROOMSHAPE_LTL) then return true end
    if(rType==RoomShape.ROOMSHAPE_LTR) then return true end
    if(rType==RoomShape.ROOMSHAPE_LBL) then return true end
    if(rType==RoomShape.ROOMSHAPE_LBR) then return true end

    return false
end

local function postUpdate(_)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_METEOR_SHOWER)) then return end
    if(mod:isRoomClear()) then return end

    local cool = (isBigRoom() and METEOR_COOLDOWN_BIGROOM or METEOR_COOLDOWN)

    if(Game():GetRoom():GetFrameCount()%cool~=1) then return end
    local r = Game():GetRoom()

    sfx:Play(SoundEffect.SOUND_TEARS_FIRE, 0, 3)
    for _, p in ipairs(Isaac.FindByType(1,0)) do
        p = p:ToPlayer()
        for _= 1, p:GetCollectibleNum(mod.COLLECTIBLE_METEOR_SHOWER)*METEORS_NUM do
            local pos = mod:getRandomFreePos()

            local m = Isaac.Spawn(EntityType.ENTITY_TEAR, mod.TEAR_METEOR, 2, pos-Vector(50,0), Vector.Zero, p):ToTear()
            m.CollisionDamage = 0
            m.Scale = mod:lerp(3.5, p.Damage, 0.4)*METEOR_SCALE_MULT/3.5
            m.SpriteScale = m.SpriteScale*(1/m.Scale)

            local cross = Isaac.Spawn(EntityType.ENTITY_EFFECT, 30, 0, pos, Vector.Zero, p):ToEffect()
            cross.Timeout = (mod:getEntityData(m, "METEOR_TEAR_LIFESPAN") or METEOR_FALLING_FRAMES)+2

            local c = Color(1,1,1,1)
            c:SetColorize(1.2,0.7,0,1)
            cross.Color = c
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

---@param tear EntityTear
local function meteorTearInit(_, tear)
    if(tear.SubType~=2) then return end

    tear.FallingAcceleration = -0.1
    tear.FallingSpeed = 0

    local tL = (METEOR_FALLING_FRAMES+2)+tear:GetDropRNG():RandomInt(FALLING_FRAME_RANDOMNESS*2)-FALLING_FRAME_RANDOMNESS
    mod:setEntityData(tear, "METEOR_TEAR_LIFESPAN", tL)

    local dist = tL*METEOR_SPEED
    tear.Position = tear.Position+Vector(-dist, 0)
    tear.Velocity = Vector(METEOR_SPEED,0)
    tear.Height = tear.Height-dist

    tear.FallingAcceleration = METEOR_SPEED*((8/7.3)-1)
    tear.FallingSpeed = METEOR_SPEED

    tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, meteorTearInit, mod.TEAR_METEOR)

--! this shit is stupid
---@param tear EntityTear
local function meteorTearUpdate(_, tear)
    if(tear.SubType~=2) then return end

    tear.Rotation = 45
    tear:GetSprite().Rotation = 45

    if(tear.FrameCount==(mod:getEntityData(tear, "METEOR_TEAR_LIFESPAN") or METEOR_FALLING_FRAMES)+2) then tear:Die() end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, meteorTearUpdate, mod.TEAR_METEOR)

local function spawnOnDeath(_, tear)
    if(Game():IsPaused()) then return end

    if(tear.Variant==mod.TEAR_METEOR and tear.SubType==2) then
        tear = tear:ToTear()
        local p = Isaac.GetPlayer()
        if(tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()) then p = tear.SpawnerEntity:ToPlayer() end

        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.3, 0, false, 0.8)
        local explosion = Isaac.Spawn(1000, mod.EFFECT_METEOR_TEAR_EXPLOSION, 0, tear.Position, Vector.Zero, tear):ToEffect()

        local d = mod:lerp(3.5, p.Damage, 0.5)*2

        for i=1,4 do
            local v = Vector.FromAngle(i*90)*35
            local spawnData = {
                SpawnType = "LINE",
                SpawnData = {EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0},
                SpawnerEntity = player,
                Position = tear.Position+v,
                Damage = d,
                PlayerFriendly = true,
                AngleVariation = 3,
                Color = Color(1,1,0,1,1,0.1,0),
                Distance = v,
                Delay = 4,
                Amount = 2,
            }
            mod:spawnCustomObjects(spawnData)
        end

        local NUM_FIRES = 3
        for i=1,NUM_FIRES do
            local s = math.sqrt(tear.Scale/METEOR_SCALE_MULT)
            local fire = Isaac.Spawn(1000,52,0, tear.Position+Vector.FromAngle(360*i/NUM_FIRES+30):Resized(15), Vector.Zero, p):ToEffect()
            fire.SpriteScale = Vector(1,1)*s
            fire.Scale = s
            fire.CollisionDamage = d
            fire.Timeout = 4*30
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, spawnOnDeath, EntityType.ENTITY_TEAR)

local function explosionUpdate(_, effect)
    if(effect:GetSprite():IsFinished("Explosion")) then effect:Remove() end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, explosionUpdate, mod.EFFECT_METEOR_TEAR_EXPLOSION)