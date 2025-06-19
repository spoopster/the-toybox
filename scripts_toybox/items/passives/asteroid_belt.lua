

local START_NUM = 8
local MAX_NUM = 20
local KILL_ADD = 1
local CLEAR_ADD = 5


local ORBIT_INIT_DURATION = 10
local ORBIT_DIST = Vector(25,25)
local TEAR_SPEED = {3.5,5}
local TEAR_OFFSET = {-8,8}
local TEAR_DMG = 1

---@param tear EntityTear
local function getAsteroidPos(tear)
    local asteroidData = ToyboxMod:getEntityData(tear, "ASTEROID_ROCK")
    if(not asteroidData) then return tear.Position end

    return ORBIT_DIST:Rotated(asteroidData.Offset+tear.FrameCount*asteroidData.Speed)*math.min(1,tear.FrameCount/ORBIT_INIT_DURATION)+tear.SpawnerEntity.Position
end

---@param pl EntityPlayer
---@param rng RNG
---@param angleOffset number?
local function spawnAsteroidRock(pl, rng, angleOffset)
    local rock = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.ROCK, 0, pl.Position, Vector.Zero, pl):ToTear()
    ToyboxMod:setEntityData(rock, "ASTEROID_ROCK",{
        Speed = ToyboxMod:randomRange(rng, TEAR_SPEED[1], TEAR_SPEED[2]),
        Offset = (angleOffset or rng:RandomInt(360))+ToyboxMod:randomRange(rng, TEAR_OFFSET[1], TEAR_OFFSET[2]),
    })

    rock.Position = ToyboxMod:lerp(pl.Position, getAsteroidPos(rock), 0.5)
    rock:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_SHIELDED | TearFlags.TEAR_NO_GRID_DAMAGE)
    rock.FallingAcceleration = -0.1
    rock.FallingSpeed = 0
    rock.CollisionDamage = TEAR_DMG
    rock.Mass = 1
    rock.Height = -7

    return rock
end

---@param pl EntityPlayer
---@param count integer
local function addAsteroidRocks(pl, count)
    local data = ToyboxMod:getEntityDataTable(pl)

    local maxNum = MAX_NUM*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_ASTEROID_BELT)-(data.ASTEROID_BELT_COUNTER or 0)
    count = math.min(maxNum, count)
    data.ASTEROID_BELT_COUNTER = data.ASTEROID_BELT_COUNTER+count
    
    if(count>0) then
        local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_ASTEROID_BELT)
        local offsetMult = 360/count
        local globalOffset = rng:RandomInt(360)
        for i=1, count do
            spawnAsteroidRock(pl, rng, i*offsetMult+globalOffset)
        end
    end
end


---@param firstTime boolean
---@param pl EntityPlayer
local function getAsteroidBelt(_, _, _, firstTime, _, _, pl)
    if(firstTime) then
        addAsteroidRocks(pl, START_NUM)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, getAsteroidBelt, ToyboxMod.COLLECTIBLE_ASTEROID_BELT)

local function giveAsteroidOnKill(_)
    for plIdx=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(plIdx)
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_ASTEROID_BELT)) then
            addAsteroidRocks(pl, KILL_ADD)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, giveAsteroidOnKill)


local function giveAsteroidOnClear(_)
    for plIdx=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(plIdx)
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_ASTEROID_BELT)) then
            addAsteroidRocks(pl, CLEAR_ADD)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, giveAsteroidOnClear)



local function spawnAsteroidRocks(_)
    for plIdx=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(plIdx)
        local data = ToyboxMod:getEntityDataTable(pl)
        data.ASTEROID_BELT_COUNTER = data.ASTEROID_BELT_COUNTER or 0

        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_ASTEROID_BELT)) then
            local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_ASTEROID_BELT)

            local numRocks = data.ASTEROID_BELT_COUNTER
            local offsetMult = 360/numRocks
            local globalOffset = rng:RandomInt(360)
            for i=1, numRocks do
                spawnAsteroidRock(pl, rng, i*offsetMult+globalOffset)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, spawnAsteroidRocks)

---@param tear EntityTear
local function asteroidOrbitLogic(_, tear)
    local asteroidData = ToyboxMod:getEntityData(tear, "ASTEROID_ROCK")
    if(not asteroidData) then return end

    tear.Velocity = ToyboxMod:lerp(tear.Velocity, getAsteroidPos(tear)-tear.Position, 0.85)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, asteroidOrbitLogic)

---@param tear EntityTear
local function asteroidDeathLogic(_, tear)
    local asteroidData = ToyboxMod:getEntityData(tear, "ASTEROID_ROCK")
    if(not asteroidData) then return end

    local pl = tear.SpawnerEntity:ToPlayer()
    local data = ToyboxMod:getEntityDataTable(pl)
    data.ASTEROID_BELT_COUNTER = math.max((data.ASTEROID_BELT_COUNTER or 0)-1, 0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, asteroidDeathLogic)