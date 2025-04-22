local mod = ToyboxMod

--! finish rest of synergys im so bored

local SHOTSPEED_UP = -0.2

local DMG_MULT = 0.25

local LASER_DURATION = 2
local LASER_FREQ = 7
local LASER_FIRE_DIST = 80

---@param ent Entity
---@return EntityPlayer?
local function getPlayerForEnt(ent)
    local check = {ent.SpawnerEntity, ent.Parent}

    for _, cEnt in ipairs(check) do
        if(cEnt) then
            if(cEnt:ToPlayer()) then
                return cEnt:ToPlayer()
            elseif(cEnt:ToFamiliar()) then
                if(mod.TEAR_COPYING_FAMILIARS[cEnt.Variant] or cEnt.Variant==FamiliarVariant.FATES_REWARD) then
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
    mod:setEntityData(arc, "DISABLE_PLASMA_TRIGGER", 0)

    return arc
end


---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE.PLASMA_GLOBE)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE.PLASMA_GLOBE)
    player.ShotSpeed = player.ShotSpeed+SHOTSPEED_UP*mult
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_SHOTSPEED)

---@param tear EntityTear
local function electricTearUpdate(_, tear)
    local player = getPlayerForEnt(tear)
    if(not (player and player:HasCollectible(mod.COLLECTIBLE.PLASMA_GLOBE))) then return end

    local laserCountdown = (mod:getEntityData(tear, "PLASMAGLOBE_LASER_COUNTDOWN") or 0)
    if(laserCountdown>0) then
        laserCountdown = laserCountdown-1
    else
        local closestEnemy = mod:closestEnemy(tear.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy)) then return end
        if(closestEnemy.Position:DistanceSquared(tear.Position)>LASER_FIRE_DIST*LASER_FIRE_DIST) then return end

        spawnSpark(closestEnemy.Position, tear.Position, player, tear.CollisionDamage, Vector(0, tear.Height))

        laserCountdown = LASER_FREQ
    end

    mod:setEntityData(tear, "PLASMAGLOBE_LASER_COUNTDOWN", laserCountdown)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, electricTearUpdate)

---@param laser EntityLaser
local function electricLaserUpdate(_, laser)
    if(mod:getEntityData(laser, "DISABLE_PLASMA_TRIGGER")==0) then return end

    local player = getPlayerForEnt(laser)
    if(not (player and player:HasCollectible(mod.COLLECTIBLE.PLASMA_GLOBE))) then return end

    local laserCountdown = (mod:getEntityData(laser, "PLASMAGLOBE_LASER_COUNTDOWN") or 0)
    if(laserCountdown>0) then
        laserCountdown = laserCountdown-1
    else
        local closestEnemy
        local spawnPos

        local samples = laser:GetNonOptimizedSamples()
        for i=0, #samples-1, 2 do
            local pos = samples:Get(i)

            local tryClosestEnemy = mod:closestEnemy(pos)

            if(tryClosestEnemy and tryClosestEnemy.Position:Distance(pos)<=LASER_FIRE_DIST) then
                closestEnemy = tryClosestEnemy
                spawnPos = pos
            end
        end
        if(not closestEnemy) then return end

        spawnSpark(closestEnemy.Position, spawnPos, player, laser.CollisionDamage, laser.PositionOffset)

        laserCountdown = LASER_FREQ
    end

    mod:setEntityData(laser, "PLASMAGLOBE_LASER_COUNTDOWN", laserCountdown)
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, electricLaserUpdate)

---@param knife EntityKnife
local function electricKnifeUpdate(_, knife)
    local player = getPlayerForEnt(knife)
    if(not (player and player:HasCollectible(mod.COLLECTIBLE.PLASMA_GLOBE))) then return end

    if(not (knife:IsFlying() or knife:GetIsSwinging() or knife:GetIsSpinAttack())) then return end

    local laserCountdown = (mod:getEntityData(knife, "PLASMAGLOBE_LASER_COUNTDOWN") or 0)
    if(laserCountdown>0) then
        laserCountdown = laserCountdown-1
    else
        local closestEnemy = mod:closestEnemy(knife.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy)) then return end
        if(closestEnemy.Position:DistanceSquared(knife.Position)>LASER_FIRE_DIST*LASER_FIRE_DIST) then return end

        spawnSpark(closestEnemy.Position, knife.Position, player, knife.CollisionDamage, Vector(0, -knife.PathOffset))

        laserCountdown = LASER_FREQ
    end

    mod:setEntityData(knife, "PLASMAGLOBE_LASER_COUNTDOWN", laserCountdown)
end
mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, electricKnifeUpdate)

---@param bomb EntityBomb
local function electricBombUpdate(_, bomb)
    local player = getPlayerForEnt(bomb)
    if(not (player and player:HasCollectible(mod.COLLECTIBLE.PLASMA_GLOBE))) then return end

    local laserCountdown = (mod:getEntityData(bomb, "PLASMAGLOBE_LASER_COUNTDOWN") or 0)
    if(laserCountdown>0) then
        laserCountdown = laserCountdown-1
    else
        local closestEnemy = mod:closestEnemy(bomb.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy)) then return end
        if(closestEnemy.Position:DistanceSquared(bomb.Position)>LASER_FIRE_DIST*LASER_FIRE_DIST) then return end

        spawnSpark(closestEnemy.Position, bomb.Position, player, bomb.ExplosionDamage*0.33, Vector(0, 0))

        laserCountdown = LASER_FREQ
    end

    mod:setEntityData(bomb, "PLASMAGLOBE_LASER_COUNTDOWN", laserCountdown)
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, electricBombUpdate)

--[[] poopy trinket forme
local ELECTRIFIED_DURATION = 120
local ELECTRIFIED_DMG = 0.5

local TMULT_DURATION_MOD = 1.5

local ELECTRIFIED_CHANCE = 0.15 -- chance to inflict at 0 luck
local ELECTRIFIED_MAXLUCK = 20 -- max luck value for scaling
local ELECTRIFIED_MAXCHANCE = 0.5 -- chance at max luck

local function postNewRoom(_)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(mod:isValidEnemy(ent)) then
            local willElectrify = nil

            for i=0, Game():GetNumPlayers()-1 do
                local p = Isaac.GetPlayer(i)
                local tMult = p:GetTrinketMultiplier(mod.TRINKET.PLASMA_GLOBE)

                if(tMult>0 and p:GetTrinketRNG(mod.TRINKET.PLASMA_GLOBE):RandomFloat()<mod:getLuckAffectedChance(p.Luck, ELECTRIFIED_CHANCE, ELECTRIFIED_MAXLUCK, ELECTRIFIED_MAXCHANCE)) then
                    willElectrify = {p,tMult}
                    break
                end
            end

            if(willElectrify) then
                local electrifyPlayer = willElectrify[1]
                local electrifyMult = willElectrify[2]

                local duration = ELECTRIFIED_DURATION*(TMULT_DURATION_MOD^(electrifyMult-1))
                duration = math.floor(duration)*(electrifyPlayer:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND)+1)

                mod:addElectrified(ent, electrifyPlayer, duration, electrifyPlayer.Damage)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
--]]

--[[ TECH omega

local DMG_MULT = 2
local LASER_DURATION = 2
local LASER_FREQ = 7

---@param ent Entity
---@return EntityPlayer?
local function getPlayerForEnt(ent)
    local check = {ent.SpawnerEntity, ent.Parent}

    for _, cEnt in ipairs(check) do
        if(cEnt) then
            if(cEnt:ToPlayer()) then
                return cEnt:ToPlayer()
            elseif(cEnt:ToFamiliar()) then
                if(mod.TEAR_COPYING_FAMILIARS[fam.Variant] or fam.Variant==FamiliarVariant.FATES_REWARD) then
                    return cEnt:ToFamiliar().Player
                end
            end
        end
    end

    return nil
end

---@param tear EntityTear
---@param player EntityPlayer
local function fireMagnetTear(_, tear, player)
    if(player:GetCollectibleRNG(mod.COLLECTIBLE.PLASMA_GLOBE):RandomFloat()<0.025) then
        tear.Velocity = tear.Velocity*0.33
        tear.FallingAcceleration = -0.1
        tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_BOUNCE)

        mod:setEntityData(tear, "MAGNET_SPHERE", true)

        tear.Scale = 3
        tear:ResetSpriteScale(true)

        local sp = tear:GetSprite()
        local prevAnim = sp:GetAnimation()
        sp:Load("gfx/tears/tb_tear_plasma.anm2", true)
        sp:Play(prevAnim, true)
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, fireMagnetTear)

---@param tear EntityTear
local function electricTearUpdate(_, tear)
    if(not (mod:getEntityData(tear, "MAGNET_SPHERE"))) then return end

    local player = getPlayerForEnt(tear)
    if(not (player)) then return end

    local laserCountdown = (mod:getEntityData(tear, "PLASMAGLOBE_LASER_COUNTDOWN") or 0)
    if(laserCountdown>0) then
        laserCountdown = laserCountdown-1
    else
        local closestEnemy = mod:closestEnemy(tear.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy)) then return end
        --if(closestEnemy.Position:DistanceSquared(tear.Position)>LASER_FIRE_DIST*LASER_FIRE_DIST) then return end

        local dir = (closestEnemy.Position-tear.Position)
        local distToFire = dir:Length()
        local angleToFire = dir:GetAngleDegrees()

        local arc = EntityLaser.ShootAngle(LaserVariant.ELECTRIC, tear.Position, angleToFire, LASER_DURATION, Vector(0, tear.Height), player)
        arc.DisableFollowParent = true
        arc.CollisionDamage = tear.CollisionDamage*DMG_MULT
        arc.MaxDistance = distToFire+5
        arc.OneHit = true
        arc.Mass = 0
        mod:setEntityData(arc, "DISABLE_PLASMA_TRIGGER", 0)

        arc.Color = Color(0,0,0,1,0,1,0.8)

        laserCountdown = LASER_FREQ
    end

    mod:setEntityData(tear, "PLASMAGLOBE_LASER_COUNTDOWN", laserCountdown)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, electricTearUpdate)

]]