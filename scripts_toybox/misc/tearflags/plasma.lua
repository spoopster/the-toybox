
--! finish rest of synergys im so bored

local DMG_MULT = 0.25

local LASER_DURATION = 2
local LASER_FREQ = 7
local LASER_FIRE_DIST = 80

---@param entity Entity
---@param player EntityPlayer
local function preAddTearFlag(_, entity, player, _, weaponFlag, tearFlag)
    if(TearFlagsLib.HasTearFlags(entity, tearFlag)) then return true end
end
--ToyboxMod:AddCallback(TearFlagsLib.Callback.PRE_ADD_TEARFLAG, preAddTearFlag, ToyboxMod.TEARFLAGS.PLASMA)

---@param ent Entity
---@return EntityPlayer?
local function getPlayerForEnt(ent)
    local check = {ent.SpawnerEntity, ent.Parent}

    for _, cEnt in ipairs(check) do
        if(cEnt) then
            if(cEnt:ToPlayer()) then
                return cEnt:ToPlayer()
            elseif(cEnt:ToFamiliar()) then
                if(ToyboxMod.TEAR_COPYING_FAMILIARS[cEnt.Variant] or cEnt.Variant==FamiliarVariant.FATES_REWARD) then
                    return cEnt:ToFamiliar().Player
                end
            end
        end
    end

    return nil
end

local function spawnSpark(startPos, endPos, player, dmg, offset)
    local dir = (endPos-startPos)
    local distToFire = dir:Length()
    local angleToFire = dir:GetAngleDegrees()

    local arc = EntityLaser.ShootAngle(LaserVariant.ELECTRIC, startPos, angleToFire, LASER_DURATION, offset, player)
    arc.DisableFollowParent = true
    arc.CollisionDamage = dmg*DMG_MULT
    arc.MaxDistance = distToFire+5
    arc.OneHit = true
    arc.Mass = 0
    ToyboxMod:setEntityData(arc, "PLASMA_BLACKLIST", true)
    TearFlagsLib.ClearTearFlags(arc, ToyboxMod.TEARFLAGS.PLASMA)

    return arc
end

---@param tear EntityTear
local function plasmaPostTearUpdate(_, tear)
    if(not TearFlagsLib.HasTearFlags(tear, ToyboxMod.TEARFLAGS.PLASMA)) then return end

    local data = ToyboxMod:getEntityDataTable(tear)
    data.PLASMA_COUNTDOWN = data.PLASMA_COUNTDOWN or 0
    if(data.PLASMA_COUNTDOWN > 0) then
        data.PLASMA_COUNTDOWN = data.PLASMA_COUNTDOWN - 1
    else
        local closestEnemy = ToyboxMod:closestEnemy(tear.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy and closestEnemy.Position:Distance(tear.Position)<=LASER_FIRE_DIST)) then return end

        spawnSpark(closestEnemy.Position, tear.Position, getPlayerForEnt(tear) or Isaac.GetPlayer(), tear.CollisionDamage, Vector(0, tear.Height))

        data.PLASMA_COUNTDOWN = LASER_FREQ
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, plasmaPostTearUpdate)

---@param laser EntityLaser
local function plasmaPostLaserUpdate(_, laser)
    if(ToyboxMod:getEntityData(laser, "PLASMA_BLACKLIST")) then return end
    if(not TearFlagsLib.HasTearFlags(laser, ToyboxMod.TEARFLAGS.PLASMA)) then return end
    if(not laser:IsSampleLaser()) then return end

    local data = ToyboxMod:getEntityDataTable(laser)
    data.PLASMA_COUNTDOWN = data.PLASMA_COUNTDOWN or 0
    if(data.PLASMA_COUNTDOWN > 0) then
        data.PLASMA_COUNTDOWN = data.PLASMA_COUNTDOWN - 1
    else
        local closestEnemy
        local closestDist = 2^31
        local spawnPos

        local samples = laser:GetNonOptimizedSamples()
        for i=0, #samples-1, 2 do
            local pos = samples:Get(i)

            local tryClosestEnemy = ToyboxMod:closestEnemy(pos)
            local tryClosestDist = (tryClosestEnemy and tryClosestEnemy.Position:Distance(pos) or closestDist)

            if(tryClosestEnemy and tryClosestDist<closestDist) then
                closestEnemy = tryClosestEnemy
                closestDist = tryClosestDist
                spawnPos = pos
            end
        end
        if(not (closestEnemy and closestDist<=LASER_FIRE_DIST)) then return end

        spawnSpark(closestEnemy.Position, spawnPos, getPlayerForEnt(laser) or Isaac.GetPlayer(), laser.CollisionDamage, laser.PositionOffset)

        data.PLASMA_COUNTDOWN = LASER_FREQ
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, plasmaPostLaserUpdate)

---@param knife EntityKnife
local function plasmaPostKnifeUpdate(_, knife)
    if(not TearFlagsLib.HasTearFlags(knife, ToyboxMod.TEARFLAGS.PLASMA)) then return end
    if(not (knife:IsFlying() or knife:GetIsSwinging() or knife:GetIsSpinAttack())) then return end

    local data = ToyboxMod:getEntityDataTable(knife)
    data.PLASMA_COUNTDOWN = data.PLASMA_COUNTDOWN or 0
    if(data.PLASMA_COUNTDOWN > 0) then
        data.PLASMA_COUNTDOWN = data.PLASMA_COUNTDOWN - 1
    else
        local closestEnemy = ToyboxMod:closestEnemy(knife.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy and closestEnemy.Position:Distance(knife.Position)<=LASER_FIRE_DIST)) then return end

        spawnSpark(closestEnemy.Position, knife.Position, getPlayerForEnt(knife) or Isaac.GetPlayer(), knife.CollisionDamage, Vector(0, -knife.PathOffset))

        data.PLASMA_COUNTDOWN = LASER_FREQ
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, plasmaPostKnifeUpdate)

---@param bomb EntityBomb
local function plasmaPostBombUpdate(_, bomb)
    if(not TearFlagsLib.HasTearFlags(bomb, ToyboxMod.TEARFLAGS.PLASMA)) then return end

    local data = ToyboxMod:getEntityDataTable(bomb)
    data.PLASMA_COUNTDOWN = data.PLASMA_COUNTDOWN or 0
    if(data.PLASMA_COUNTDOWN > 0) then
        data.PLASMA_COUNTDOWN = data.PLASMA_COUNTDOWN - 1
    else
        local closestEnemy = ToyboxMod:closestEnemy(bomb.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy)) then return end
        if(closestEnemy.Position:DistanceSquared(bomb.Position)>LASER_FIRE_DIST*LASER_FIRE_DIST) then return end

        spawnSpark(closestEnemy.Position, bomb.Position, getPlayerForEnt(bomb) or Isaac.GetPlayer(), bomb.ExplosionDamage*0.33, Vector(0, 0))

        data.PLASMA_COUNTDOWN = LASER_FREQ
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, plasmaPostBombUpdate)

--[[] ]

---@param rocket EntityEffect
local function electricRocketUpdate(_, rocket)
    local player = getPlayerForEnt(rocket)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_PLASMA_GLOBE))) then return end

    local laserCountdown = (ToyboxMod:getEntityData(rocket, "PLASMA_COUNTDOWN") or 0)
    if(laserCountdown>0) then
        laserCountdown = laserCountdown-1
    else
        local closestEnemy = ToyboxMod:closestEnemy(rocket.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy)) then return end
        if(closestEnemy.Position:DistanceSquared(rocket.Position)>LASER_FIRE_DIST*LASER_FIRE_DIST) then return end

        spawnSpark(closestEnemy.Position, rocket.Position, player, 70/3, Vector(0, 0))

        laserCountdown = LASER_FREQ
    end

    ToyboxMod:setEntityData(rocket, "PLASMA_COUNTDOWN", laserCountdown)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, electricRocketUpdate, EffectVariant.TARGET)
--]]