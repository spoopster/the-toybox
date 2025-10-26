--- make knifes
--- make bombs
--- make epic fetus? (intermediary rockets on ground)
--- 
--- make it copy hitlists (when it eventually gets added RGON)

local LOOP_INTERVAL = 40*3
local LOOP_INTERVAL_START = 40*1.5

local LOOP_DMGMULT = 0.8
local LOOP_SCALEMULT = 0.6

local INVALID_TEAR_EFFECTS =
    TearFlags.TEAR_TRACTOR_BEAM | TearFlags.TEAR_ORBIT | TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_LUDOVICO

local LUDO_ORBIT_DIST_TEARS = 30
local LUDO_ORBIT_DIST_LASER = 45

local DRFETUS_LOOP_VELMULT = 0.7

local EPICFETUS_TARGET_SCALEMULT = 0.8
local EPICFETUS_TARGET_LOOP_INTERVAL = 40*5
local EPICFETUS_TARGET_DELAY = 60

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
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGTON_LOOP))) then return end
    if(tear:IsDead()) then return end
    if(ToyboxMod:getEntityData(tear, "LANGSTON_LOOP_BLACKLIST")) then
        if(tear:HasTearFlags(TearFlags.TEAR_LUDOVICO)) then
            local parentTear = ToyboxMod:getEntityData(tear, "LANGSTON_LOOP_BLACKLIST")
            if(type(parentTear)~="boolean" and not (parentTear and parentTear:Exists() and not parentTear:IsDead())) then
                tear:Die()
            end
        end

        return
    end

    local data = ToyboxMod:getEntityDataTable(tear)

    if(tear:HasTearFlags(TearFlags.TEAR_LUDOVICO)) then
        data.LANGSTON_LOOP_LUDOTEARS = data.LANGSTON_LOOP_LUDOTEARS or {}

        if(#data.LANGSTON_LOOP_LUDOTEARS<2) then
            for i=#data.LANGSTON_LOOP_LUDOTEARS+1, 2 do
                local newTear = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, tear.SubType, tear.Position, tear.Velocity, tear.SpawnerEntity):ToTear()
                newTear.Parent = tear.Parent

                newTear.FallingSpeed = tear.FallingSpeed
                newTear.FallingAcceleration = tear.FallingAcceleration
                --newTear.Height = tear.Height

                newTear.Scale = tear.Scale*LOOP_SCALEMULT
                newTear.CollisionDamage = tear.CollisionDamage*LOOP_DMGMULT

                newTear.TearFlags = tear.TearFlags--| TearFlags.TEAR_ACCELERATE
                newTear:ClearTearFlags(INVALID_TEAR_EFFECTS)
                newTear.TearFlags = tear.TearFlags | TearFlags.TEAR_LUDOVICO

                newTear.CanTriggerStreakEnd = false
                newTear.KnockbackMultiplier = tear.KnockbackMultiplier
                newTear.Color = tear.Color

                ToyboxMod:cloneTableWithoutDeleteing(newTear:GetData(), tear:GetData())
                ToyboxMod:setEntityData(newTear, "LANGSTON_LOOP_BLACKLIST", tear)
                ToyboxMod:setEntityData(newTear, "LANGSTON_LOOP_LUDOANGLE", tear.Velocity:GetAngleDegrees())

                newTear:Update()

                data.LANGSTON_LOOP_LUDOTEARS[i] = newTear
            end
        end

        local ludoAngle = (ToyboxMod:getEntityData(data.LANGSTON_LOOP_LUDOTEARS[1], "LANGSTON_LOOP_LUDOANGLE") or tear.Velocity:GetAngleDegrees())
        ludoAngle = ludoAngle+ToyboxMod:angleDifference(ludoAngle, tear.Velocity:GetAngleDegrees())*0.15

        for i, orbitTear in ipairs(data.LANGSTON_LOOP_LUDOTEARS) do
            local targetPos = tear.Position+Vector.FromAngle(ludoAngle+(i*2-3)*90):Resized(LUDO_ORBIT_DIST_TEARS)

            orbitTear.Velocity = ToyboxMod:lerp(orbitTear.Velocity, tear.Velocity+(targetPos-orbitTear.Position), 0.7)

            ToyboxMod:setEntityData(orbitTear, "LANGSTON_LOOP_LUDOANGLE", ludoAngle)
        end
    else
        data.LANGSTON_LOOP_DISTTRAVELLED = (data.LANGSTON_LOOP_DISTTRAVELLED or LOOP_INTERVAL_START)+tear.Velocity:Length()

        if(data.LANGSTON_LOOP_LUDOTEARS) then
            for _, ent in ipairs(data.LANGSTON_LOOP_LUDOTEARS) do
                ent:Die()
            end
            data.LANGSTON_LOOP_LUDOTEARS = nil
        end
    
        local posToSpawn = tear.Position-tear.Velocity:Resized(data.LANGSTON_LOOP_DISTTRAVELLED%LOOP_INTERVAL)
        while(data.LANGSTON_LOOP_DISTTRAVELLED>=LOOP_INTERVAL) do
            for i=-1,1,2 do
                local newVel = tear.Velocity:Rotated(i*90)

                local newTear = Isaac.Spawn(EntityType.ENTITY_TEAR, tear.Variant, tear.SubType, posToSpawn, newVel, tear.SpawnerEntity):ToTear()
                newTear.Parent = tear.Parent

                newTear.FallingSpeed = tear.FallingSpeed
                newTear.FallingAcceleration = tear.FallingAcceleration
                --newTear.Height = tear.Height

                newTear.Scale = tear.Scale*LOOP_SCALEMULT
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
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, langstonTearUpdate)

---@param tear EntityTear
---@param coll Entity
local function cancelLudoLangstonCollision(_, tear, coll)
    if(not (coll and coll:ToTear())) then return end
    coll = coll:ToTear() ---@cast coll EntityTear

    if(tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) and coll:HasTearFlags(TearFlags.TEAR_LUDOVICO)) then
        if(ToyboxMod:getEntityData(tear, "LANGSTON_LOOP_BLACKLIST")~=nil or ToyboxMod:getEntityData(coll, "LANGSTON_LOOP_BLACKLIST")~=nil) then
            return true
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, cancelLudoLangstonCollision)


---@param laser EntityLaser
local function langstonLaserUpdate(_, laser)
    if(laser.SubType==LaserSubType.LASER_SUBTYPE_NO_IMPACT or laser.SubType==LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT) then return end

    local player = getPlayerForEnt(laser)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGTON_LOOP))) then return end
    if(laser:IsDead()) then return end
    if(ToyboxMod:getEntityData(laser, "LANGSTON_LOOP_BLACKLIST")) then
        local parentLaser = ToyboxMod:getEntityData(laser, "LANGSTON_LOOP_BLACKLIST")
        if(type(parentLaser)~="boolean" and not (parentLaser and parentLaser:Exists() and not parentLaser:IsDead())) then
            laser:Die()
        end

        return
    end

    local data = ToyboxMod:getEntityDataTable(laser)

    if(laser.SubType==LaserSubType.LASER_SUBTYPE_LINEAR) then
        local preexistingLasers = data.LANGSTON_LOOP_LIST or {}
        local laserIdx = 0

        local distTravelled = LOOP_INTERVAL_START

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
                        newLaser:SetScale(laser:GetScale()*LOOP_SCALEMULT)
                        newLaser:SetDamageMultiplier(laser:GetDamageMultiplier()*LOOP_DMGMULT)
                        newLaser:SetShrink(laser:GetShrink())

                        newLaser.Color = laser.Color

                        ToyboxMod:cloneTableWithoutDeleteing(newLaser:GetData(), laser:GetData())
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
    elseif(laser.SubType==LaserSubType.LASER_SUBTYPE_RING_PROJECTILE) then
        data.LANGSTON_LOOP_DISTTRAVELLED = (data.LANGSTON_LOOP_DISTTRAVELLED or LOOP_INTERVAL_START)+laser.Velocity:Length()
    
        local posToSpawn = laser.Position-laser.Velocity:Resized(data.LANGSTON_LOOP_DISTTRAVELLED%LOOP_INTERVAL)
        while(data.LANGSTON_LOOP_DISTTRAVELLED>=LOOP_INTERVAL) do
            for i=-1,1,2 do
                local newVel = laser.Velocity:Rotated(i*90)

                local newLaser = Isaac.Spawn(laser.Type,laser.Variant,laser.SubType,posToSpawn,newVel,laser.SpawnerEntity):ToLaser()
                newLaser.Parent = laser.Parent
                newLaser.CurveStrength = laser.CurveStrength
                newLaser.MaxDistance = laser.MaxDistance
                newLaser.OneHit = laser.OneHit
                newLaser.Radius = laser.Radius*LOOP_SCALEMULT
                newLaser.TearFlags = laser.TearFlags & (~INVALID_TEAR_EFFECTS)
                newLaser.HomingType = laser.HomingType
                newLaser.PositionOffset = laser.PositionOffset

                newLaser:SetTimeout(laser:GetTimeout())
                newLaser:SetDisableFollowParent(laser.DisableFollowParent)
                newLaser:SetBlackHpDropChance(laser.BlackHpDropChance)
                newLaser:SetScale(laser:GetScale()*LOOP_SCALEMULT)
                newLaser:SetDamageMultiplier(laser:GetDamageMultiplier()*LOOP_DMGMULT)
                newLaser:SetShrink(laser:GetShrink())

                newLaser.Color = laser.Color

                ToyboxMod:cloneTableWithoutDeleteing(newLaser:GetData(), laser:GetData())
                ToyboxMod:setEntityData(newLaser, "LANGSTON_LOOP_BLACKLIST", true)
            end

            posToSpawn = posToSpawn-laser.Velocity:Resized(LOOP_INTERVAL)

            data.LANGSTON_LOOP_DISTTRAVELLED = data.LANGSTON_LOOP_DISTTRAVELLED-LOOP_INTERVAL
        end
    elseif(laser.SubType==LaserSubType.LASER_SUBTYPE_RING_LUDOVICO) then
        data.LANGSTON_LOOP_LUDOLASERS = data.LANGSTON_LOOP_LUDOLASERS or {}

        if(#data.LANGSTON_LOOP_LUDOLASERS<2) then
            for i=#data.LANGSTON_LOOP_LUDOLASERS+1, 2 do
                local newLaser = Isaac.Spawn(laser.Type,laser.Variant,laser.SubType,laser.Position,laser.Velocity,laser.SpawnerEntity):ToLaser()
                
                newLaser.Parent = laser.Parent
                newLaser.CurveStrength = laser.CurveStrength
                newLaser.MaxDistance = laser.MaxDistance
                newLaser.OneHit = laser.OneHit
                newLaser.Radius = laser.Radius*LOOP_SCALEMULT
                newLaser.TearFlags = laser.TearFlags & (~INVALID_TEAR_EFFECTS) | TearFlags.TEAR_LUDOVICO
                newLaser.HomingType = laser.HomingType
                newLaser.PositionOffset = laser.PositionOffset

                newLaser:SetTimeout(laser:GetTimeout())
                newLaser:SetDisableFollowParent(laser.DisableFollowParent)
                newLaser:SetBlackHpDropChance(laser.BlackHpDropChance)
                newLaser:SetScale(laser:GetScale()*LOOP_SCALEMULT)
                newLaser:SetDamageMultiplier(laser:GetDamageMultiplier()*LOOP_DMGMULT)
                newLaser:SetShrink(laser:GetShrink())

                newLaser.Color = laser.Color

                ToyboxMod:cloneTableWithoutDeleteing(newLaser:GetData(), laser:GetData())
                ToyboxMod:setEntityData(newLaser, "LANGSTON_LOOP_BLACKLIST", true)
                ToyboxMod:setEntityData(newLaser, "LANGSTON_LOOP_LUDOANGLE", laser.Velocity:GetAngleDegrees())

                data.LANGSTON_LOOP_LUDOLASERS[i] = newLaser
            end
        end

        local ludoAngle = (ToyboxMod:getEntityData(data.LANGSTON_LOOP_LUDOLASERS[1], "LANGSTON_LOOP_LUDOANGLE") or laser.Velocity:GetAngleDegrees())
        ludoAngle = ludoAngle+ToyboxMod:angleDifference(ludoAngle, laser.Velocity:GetAngleDegrees())*0.15

        for i, orbitLaser in ipairs(data.LANGSTON_LOOP_LUDOLASERS) do
            local targetPos = laser.Position+Vector.FromAngle(ludoAngle+(i*2-3)*90):Resized(LUDO_ORBIT_DIST_LASER)

            orbitLaser.Velocity = ToyboxMod:lerp(orbitLaser.Velocity, laser.Velocity+(targetPos-orbitLaser.Position), 0.7)

            ToyboxMod:setEntityData(orbitLaser, "LANGSTON_LOOP_LUDOANGLE", ludoAngle)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, langstonLaserUpdate)

---@param knife EntityKnife
local function langstonKnifeUpdate(_, knife)
    local player = getPlayerForEnt(knife)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGTON_LOOP))) then return end
    if(knife:IsDead()) then return end
    if(ToyboxMod:getEntityData(knife, "LANGSTON_LOOP_BLACKLIST")) then return end

    local data = ToyboxMod:getEntityDataTable(knife)

    if(knife:HasTearFlags(TearFlags.TEAR_LUDOVICO)) then
        data.LANGSTON_LOOP_LUDOTEARS = data.LANGSTON_LOOP_LUDOTEARS or {}

        if(#data.LANGSTON_LOOP_LUDOTEARS<2) then
            for i=#data.LANGSTON_LOOP_LUDOTEARS+1, 2 do

                local newTear = player:FireTear(knife.Position, knife.Velocity, true, true, false, player, LOOP_DMGMULT)

                newTear:ClearTearFlags(INVALID_TEAR_EFFECTS)
                newTear.TearFlags = newTear.TearFlags | TearFlags.TEAR_LUDOVICO | TearFlags.TEAR_SPECTRAL

                ToyboxMod:setEntityData(newTear, "LANGSTON_LOOP_BLACKLIST", knife)
                ToyboxMod:setEntityData(newTear, "LANGSTON_LOOP_LUDOANGLE", knife.Velocity:GetAngleDegrees())

                newTear:Update()

                data.LANGSTON_LOOP_LUDOTEARS[i] = newTear
            end
        end

        local ludoAngle = (ToyboxMod:getEntityData(data.LANGSTON_LOOP_LUDOTEARS[1], "LANGSTON_LOOP_LUDOANGLE") or knife.Velocity:GetAngleDegrees())
        ludoAngle = ludoAngle+ToyboxMod:angleDifference(ludoAngle, knife.Velocity:GetAngleDegrees())*0.15
        
        for i, orbitTear in ipairs(data.LANGSTON_LOOP_LUDOTEARS) do 
            local targetPos = knife.Position+Vector.FromAngle(ludoAngle+(i*2-3)*90):Resized(LUDO_ORBIT_DIST_TEARS)

            orbitTear.Velocity = ToyboxMod:lerp(orbitTear.Velocity, knife.Velocity+(targetPos-orbitTear.Position), 0.7)

            ToyboxMod:setEntityData(orbitTear, "LANGSTON_LOOP_LUDOANGLE", ludoAngle)
        end

        local len = #data.LANGSTON_LOOP_LUDOTEARS
        for i=1, len do
            if(data.LANGSTON_LOOP_LUDOTEARS[i] and not data.LANGSTON_LOOP_LUDOTEARS[i]:Exists()) then
                table.remove(data.LANGSTON_LOOP_LUDOTEARS, i)
                len = len-1
            end
        end
    elseif(knife:IsFlying()) then
        data.LANGSTON_LOOP_DISTTRAVELLED = (data.LANGSTON_LOOP_DISTTRAVELLED or LOOP_INTERVAL_START)+math.abs(knife:GetKnifeVelocity())/2

        if(data.LANGSTON_LOOP_LUDOTEARS) then
            for _, ent in ipairs(data.LANGSTON_LOOP_LUDOTEARS) do
                ent:Die()
            end
            data.LANGSTON_LOOP_LUDOTEARS = nil
        end

        local vel = Vector.FromAngle(knife.Rotation+knife.RotationOffset)
        local posToSpawn = knife.Position-vel:Resized(data.LANGSTON_LOOP_DISTTRAVELLED%LOOP_INTERVAL)
        while(data.LANGSTON_LOOP_DISTTRAVELLED>=LOOP_INTERVAL) do
            for i=-1,1,2 do
                local newVel = Vector.FromAngle(knife.Rotation+knife.RotationOffset+i*90):Resized(player.ShotSpeed*9)

                local newTear = player:FireTear(posToSpawn, newVel, true, true, false, player, LOOP_DMGMULT)

                newTear.Scale = newTear.Scale*LOOP_SCALEMULT
                newTear:ClearTearFlags(INVALID_TEAR_EFFECTS)

                ToyboxMod:setEntityData(newTear, "LANGSTON_LOOP_BLACKLIST", true)

                newTear:Update()
            end

            posToSpawn = posToSpawn-vel:Resized(LOOP_INTERVAL)
            data.LANGSTON_LOOP_DISTTRAVELLED = data.LANGSTON_LOOP_DISTTRAVELLED-LOOP_INTERVAL
        end
    else
        data.LANGSTON_LOOP_DISTTRAVELLED = nil
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, langstonKnifeUpdate)


---@param pl EntityPlayer
---@param bomb EntityBomb
local function invalidateUsedBomb(_, pl, bomb)
    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_LANGTON_LOOP)) then
        ToyboxMod:setEntityData(bomb, "LANGSTON_LOOP_BLACKLIST", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, invalidateUsedBomb)

---@param bomb EntityBomb
---@param ogbomb EntityBomb
local function copyInvalidBombData(_, bomb, ogbomb)
    ToyboxMod:setEntityData(bomb, "LANGSTON_LOOP_BLACKLIST", ToyboxMod:getEntityData(ogbomb, "LANGSTON_LOOP_BLACKLIST"))
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.COPY_SCATTER_BOMB_DATA, copyInvalidBombData)

---@param bomb EntityBomb
local function langstonBombUpdate(_, bomb)
    local player = getPlayerForEnt(bomb)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGTON_LOOP))) then return end
    if(bomb:IsDead()) then return end
    if(ToyboxMod:getEntityData(bomb, "LANGSTON_LOOP_BLACKLIST")) then return end

    local data = ToyboxMod:getEntityDataTable(bomb)
    data.LANGSTON_LOOP_DISTTRAVELLED = (data.LANGSTON_LOOP_DISTTRAVELLED or LOOP_INTERVAL_START)+bomb.Velocity:Length()

    local posToSpawn = bomb.Position-bomb.Velocity:Resized(data.LANGSTON_LOOP_DISTTRAVELLED%LOOP_INTERVAL)
    while(data.LANGSTON_LOOP_DISTTRAVELLED>=LOOP_INTERVAL) do
        for i=-1,1,2 do
            local newVel = bomb.Velocity:Rotated(i*90)*DRFETUS_LOOP_VELMULT

            local newBomb = Isaac.Spawn(EntityType.ENTITY_BOMB, bomb.Variant, bomb.SubType, posToSpawn, newVel, bomb.SpawnerEntity):ToBomb()
            newBomb.Parent = bomb.Parent

            newBomb.ExplosionDamage = bomb.ExplosionDamage*LOOP_DMGMULT
            newBomb:SetScale(bomb:GetScale()*LOOP_SCALEMULT)
            newBomb.RadiusMultiplier = bomb.RadiusMultiplier*LOOP_SCALEMULT
            newBomb:SetRocketAngle(bomb:GetRocketAngle()+i*90)

            newBomb.Color = bomb.Color

            newBomb:SetLoadCostumes(true)

            ToyboxMod:cloneTableWithoutDeleteing(newBomb:GetData(), bomb:GetData())
            ToyboxMod:setEntityData(newBomb, "LANGSTON_LOOP_BLACKLIST", true)

            newBomb:Update()
        end

        posToSpawn = posToSpawn-bomb.Velocity:Resized(LOOP_INTERVAL)

        data.LANGSTON_LOOP_DISTTRAVELLED = data.LANGSTON_LOOP_DISTTRAVELLED-LOOP_INTERVAL
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, langstonBombUpdate)

---@param bomb EntityBomb   
---@param coll Entity
local function cancelBombLangstonCollision(_, bomb, coll)
    if(not (coll and coll:ToBomb())) then return end
    coll = coll:ToBomb() ---@cast coll EntityBomb

    if(ToyboxMod:getEntityData(bomb, "LANGSTON_LOOP_BLACKLIST") or ToyboxMod:getEntityData(coll, "LANGSTON_LOOP_BLACKLIST")) then
        return true
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, cancelBombLangstonCollision)


---@param rocket EntityEffect
local function langstonRocketUpdate(_, rocket)
    local player = getPlayerForEnt(rocket)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LANGTON_LOOP))) then return end
    if(rocket:IsDead()) then return end
    if(ToyboxMod:getEntityData(rocket, "LANGSTON_LOOP_BLACKLIST")) then
        return
    end

    local data = ToyboxMod:getEntityDataTable(rocket)
    data.LANGSTON_LOOP_DISTTRAVELLED = (data.LANGSTON_LOOP_DISTTRAVELLED or LOOP_INTERVAL_START)+rocket.Velocity:Length()

    local posToSpawn = rocket.Position-rocket.Velocity:Resized(data.LANGSTON_LOOP_DISTTRAVELLED%EPICFETUS_TARGET_LOOP_INTERVAL)
    while(data.LANGSTON_LOOP_DISTTRAVELLED>=EPICFETUS_TARGET_LOOP_INTERVAL) do
        local newRocket = Isaac.Spawn(EntityType.ENTITY_EFFECT, rocket.Variant, rocket.SubType, posToSpawn, Vector.Zero, rocket.SpawnerEntity):ToEffect()
        newRocket.Parent = rocket.Parent

        newRocket:SetTimeout(EPICFETUS_TARGET_DELAY)
        newRocket.State = 1
        newRocket.SpriteScale = rocket.SpriteScale*EPICFETUS_TARGET_SCALEMULT

        ToyboxMod:cloneTableWithoutDeleteing(newRocket:GetData(), rocket:GetData())
        ToyboxMod:setEntityData(newRocket, "LANGSTON_LOOP_BLACKLIST", true)

        newRocket:Update()

        posToSpawn = posToSpawn-rocket.Velocity:Resized(EPICFETUS_TARGET_LOOP_INTERVAL)

        data.LANGSTON_LOOP_DISTTRAVELLED = data.LANGSTON_LOOP_DISTTRAVELLED-EPICFETUS_TARGET_LOOP_INTERVAL
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, langstonRocketUpdate, EffectVariant.TARGET)