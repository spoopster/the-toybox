--- make tech 10 work
--- make knifes
--- make bombs
--- make epic fetus? (intermediary rockets on ground)

local LOOP_INTERVAL = 40*2.5
local LOOP_DMGMULT = 0.75

local INVALID_TEAR_EFFECTS = 
    TearFlags.TEAR_TRACTOR_BEAM | TearFlags.TEAR_ORBIT | TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_LUDOVICO

local VALUE_FONT = Font()
VALUE_FONT:Load("font/luaminioutlined.fnt")

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

---@param tear EntityTear
local function langstonTearUpdate(_, tear)
    local player = getPlayerForEnt(tear)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGSTON_LOOP))) then return end
    if(ToyboxMod:getEntityData(tear, "LANGSTON_LOOP_BLACKLIST")) then return end

    local data = ToyboxMod:getEntityDataTable(tear)
    data.LANGSTON_LOOP_DISTTRAVELLED = (data.LANGSTON_LOOP_DISTTRAVELLED or 0)+tear.Velocity:Length()
    
    local posToSpawn = tear.Position-tear.Velocity:Resized(data.LANGSTON_LOOP_DISTTRAVELLED%LOOP_INTERVAL)
    while(data.LANGSTON_LOOP_DISTTRAVELLED>=LOOP_INTERVAL) do
        for i=-1,1,2 do
            local newVel = tear.Velocity:Rotated(i*90)

            local newTear = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, tear.SubType, posToSpawn, newVel, tear.SpawnerEntity):ToTear()
            newTear.Parent = tear.Parent

            newTear.FallingSpeed = tear.FallingSpeed
            newTear.FallingAcceleration = tear.FallingAcceleration
            --newTear.Height = tear.Height

            newTear.Scale = tear.Scale*LOOP_DMGMULT
            newTear.CollisionDamage = tear.CollisionDamage*LOOP_DMGMULT

            newTear.TearFlags = tear.TearFlags--| TearFlags.TEAR_ACCELERATE
            newTear:ClearTearFlags(INVALID_TEAR_EFFECTS)

            newTear.CanTriggerStreakEnd = false
            newTear.KnockbackMultiplier = tear.KnockbackMultiplier
            newTear.Color = tear.Color

            ToyboxMod:cloneTableWithoutDeleteing(newTear:GetData(), tear:GetData())
            ToyboxMod:setEntityData(newTear, "LANGSTON_LOOP_BLACKLIST", true)

            newTear:Update()
        end

        posToSpawn = posToSpawn-tear.Velocity:Resized(LOOP_INTERVAL)

        data.LANGSTON_LOOP_DISTTRAVELLED = data.LANGSTON_LOOP_DISTTRAVELLED-LOOP_INTERVAL
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, langstonTearUpdate)


---@param laser EntityLaser
local function langstonLaserUpdate(_, laser)
    local player = getPlayerForEnt(laser)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGSTON_LOOP))) then return end
    if(laser:IsDead()) then return end
    if(ToyboxMod:getEntityData(laser, "LANGSTON_LOOP_BLACKLIST")) then
        local parentLaser = ToyboxMod:getEntityData(laser, "LANGSTON_LOOP_BLACKLIST")
        if(not (parentLaser and parentLaser:Exists() and not parentLaser:IsDead())) then
            laser:Die()
        end

        return
    end

    local data = ToyboxMod:getEntityDataTable(laser)
    local preexistingLasers = data.LANGSTON_LOOP_LIST or {}
    local laserIdx = 0

    local distTravelled = 0

    local samples = laser:GetSamples()
    for i=1, #samples-1 do
        distTravelled = distTravelled+samples:Get(i-1):Distance(samples:Get(i))
        local dir = (samples:Get(i)-samples:Get(i-1)):Normalized()
        local posToSpawn = samples:Get(i)-dir*(distTravelled%LOOP_INTERVAL)

        local lasersToSpawn = (distTravelled//LOOP_INTERVAL)
        local endIdx = laserIdx+2*lasersToSpawn
        if(lasersToSpawn==0) then endIdx = laserIdx end
        laserIdx = endIdx

        while(distTravelled>=LOOP_INTERVAL) do
            for r=-1,1,2 do
                local angle = dir:GetAngleDegrees()+r*90

                if(preexistingLasers[laserIdx] and preexistingLasers[laserIdx]:ToLaser()) then
                    local newLaser = preexistingLasers[laserIdx]:ToLaser()

                    newLaser:RotateToAngle(angle, 360)
                    newLaser.Position = posToSpawn
                    newLaser.ParentOffset = newLaser.ParentOffset+(posToSpawn-((newLaser.Parent or newLaser.SpawnerEntity or player).Position+newLaser.ParentOffset))
                    newLaser.Timeout = laser.Timeout
                else
                    local newLaser = EntityLaser.ShootAngle(laser.Variant,posToSpawn,angle,laser:GetTimeout()+1,laser.PositionOffset,laser.SpawnerEntity):ToLaser()
                    newLaser.CurveStrength = laser.CurveStrength
                    newLaser.MaxDistance = laser.MaxDistance
                    newLaser.OneHit = laser.OneHit
                    newLaser.Radius = laser.Radius
                    newLaser.TearFlags = laser.TearFlags
                    newLaser.HomingType = laser.HomingType

                    newLaser:SetDisableFollowParent(laser.DisableFollowParent)
                    newLaser:SetBlackHpDropChance(laser.BlackHpDropChance)
                    newLaser:SetScale(laser:GetScale()*LOOP_DMGMULT)
                    newLaser:SetDamageMultiplier(laser:GetDamageMultiplier()*LOOP_DMGMULT)
                    newLaser:SetShrink(laser:GetShrink())

                    newLaser.Color = laser.Color

                    ToyboxMod:setEntityData(newLaser, "LANGSTON_LOOP_BLACKLIST", laser)
                    preexistingLasers[laserIdx] = newLaser
                end

                laserIdx = laserIdx-1
            end

            posToSpawn = posToSpawn-dir*LOOP_INTERVAL
            distTravelled = distTravelled-LOOP_INTERVAL
        end

        laserIdx = endIdx
    end

    local lasersLen = #preexistingLasers
    if(laserIdx<lasersLen) then
        for i=laserIdx+1, lasersLen do
            if(preexistingLasers[i]) then
                preexistingLasers[i]:Remove()
                preexistingLasers[i] = nil
            end
        end
    end
    data.LANGSTON_LOOP_LIST = preexistingLasers
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, langstonLaserUpdate)

---@param laser EntityLaser
local function langstonLaserRender(_, laser)
    local player = getPlayerForEnt(laser)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGSTON_LOOP))) then return end
    if(ToyboxMod:getEntityData(laser, "LANGSTON_LOOP_BLACKLIST")) then return end

    local data = ToyboxMod:getEntityDataTable(laser)
    local preexistingLasers = data.LANGSTON_LOOP_LIST or {}

    for idx, cLaser in pairs(preexistingLasers) do
        cLaser = cLaser:ToLaser()
        local rpos = cLaser.Position+cLaser.PositionOffset+Vector.FromAngle(cLaser.AngleDegrees)*20
        rpos = Isaac.WorldToRenderPosition(rpos)

        Isaac.RenderText(tostring(idx), rpos.X, rpos.Y, 1,1,1,1)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, langstonLaserRender)