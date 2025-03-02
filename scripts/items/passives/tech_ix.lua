local mod = MilcomMOD

local LASER_RING_MAXSIZE = 60 --radius
local LASER_RING_DECREASEBY = 0.55
local LASER_RING_INCREASEBY = 10

local LASER_SPARK_COOLDOWN = 10

---@param player Entity
local function increaseLaserRing(player, increaseMod, decreaseMod)
    local data = mod:getEntityDataTable(player)

    if(not (data.TECH_IX_LASER_RING and data.TECH_IX_LASER_RING:Exists())) then
        data.TECH_IX_LASER_RING = Isaac.Spawn(7,2,3,player.Position,player.Velocity,player):ToLaser()
        data.TECH_IX_LASER_RING.Radius = 0.15
        data.TECH_IX_LASER_RING.CollisionDamage = 0.8
        data.TECH_IX_LASER_RING.Parent = player

        mod:setEntityData(data.TECH_IX_LASER_RING, "IS_TECH_IX_LASER", decreaseMod or 1)
    end

    local tearsMod = 0
    if(player.Type==EntityType.ENTITY_FAMILIAR) then tearsMod = (2.73/mod:getTps(player:ToFamiliar().Player))
    else tearsMod = (2.73/mod:getTps(player:ToPlayer())) end

    if(tearsMod<1) then tearsMod = tearsMod^(1/2) end

    local radiusIncrease = LASER_RING_INCREASEBY*(increaseMod or 1)*tearsMod
    data.TECH_IX_LASER_RING.Radius = math.min(LASER_RING_MAXSIZE, data.TECH_IX_LASER_RING.Radius+radiusIncrease)
end

local function updateLaserRing(_, laser)
    if(not mod:getEntityData(laser, "IS_TECH_IX_LASER")) then return end

    laser.Radius = math.max(0, laser.Radius-LASER_RING_DECREASEBY*mod:getEntityData(laser, "IS_TECH_IX_LASER"))
    if(laser.Radius==0) then laser:Die() end

    mod:setEntityData(laser, "TECHIX_RING_SPARK_COOLDOWN", math.max(0, (mod:getEntityData(laser, "TECHIX_RING_SPARK_COOLDOWN") or 0)-1))
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, updateLaserRing, LaserVariant.THIN_RED)

local function laserRingCollision(_, laser, coll)
    if(not (laser and mod:getEntityData(laser, "IS_TECH_IX_LASER"))) then return end
    if(not (mod:isValidEnemy(coll))) then return end

    if(mod:getEntityData(laser, "TECHIX_RING_SPARK_COOLDOWN")==0) then
        local p = Isaac.GetPlayer()
        if(laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()) then p = laser.SpawnerEntity:ToPlayer() end

        local laser2 = EntityLaser.ShootAngle(2, coll.Position, laser:GetDropRNG():RandomInt(360), 2, Vector(0, -10), p)
        laser2.Parent = p
        laser2.CollisionDamage = laser.CollisionDamage*3
        laser2.MaxDistance = coll.Size+45+laser:GetDropRNG():RandomInt(45)
        laser2.OneHit = true
        laser2.Mass = 0

        laser2:Update()

        coll:TakeDamage(laser2.CollisionDamage, 0, EntityRef(p), 0)

        mod:setEntityData(laser, "TECHIX_RING_SPARK_COOLDOWN", LASER_SPARK_COOLDOWN)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, laserRingCollision)

local function playerAttack(_, ent, weap, dir, cMod)
    local p = ent:ToPlayer()
    if(ent.Type==EntityType.ENTITY_FAMILIAR and ent:ToFamiliar().Player) then p = ent:ToFamiliar().Player:ToPlayer() end

    if(p and p:HasCollectible(mod.COLLECTIBLE.TECH_IX)) then
        local cMod2 = 1
        local t = weap:GetWeaponType()

        if(t==WeaponType.WEAPON_KNIFE) then cMod2=0.5
        elseif(t==WeaponType.WEAPON_MONSTROS_LUNGS) then cMod2=0.85
        elseif(t==WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then cMod2=0.85
        elseif(t==WeaponType.WEAPON_TECH_X) then cMod2=0.5
        elseif(t==WeaponType.WEAPON_BONE) then cMod2=0.75
        elseif(t==WeaponType.WEAPON_SPIRIT_SWORD) then cMod2=1.2
        elseif(t==WeaponType.WEAPON_FETUS) then cMod2=0.9
        elseif(t==WeaponType.WEAPON_UMBILICAL_WHIP) then cMod2=0.8 end
        
        increaseLaserRing(ent, cMod, cMod2)
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, playerAttack)