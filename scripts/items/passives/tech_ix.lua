local mod = MilcomMOD

local LASER_RING_MAXSIZE = 50 --radius
local LASER_RING_DECREASEBY = 0.55
local LASER_RING_INCREASEBY = 10

local function increaseLaserRing(player, increaseMod, decreaseMod)
    local data = mod:getDataTable(player)

    if(not (data.TECH_IX_LASER_RING and data.TECH_IX_LASER_RING:Exists())) then
        data.TECH_IX_LASER_RING = Isaac.Spawn(7,2,3,player.Position,player.Velocity,player):ToLaser()
        data.TECH_IX_LASER_RING.Radius = 1
        data.TECH_IX_LASER_RING.CollisionDamage = 1
        data.TECH_IX_LASER_RING.Parent = player

        mod:setData(data.TECH_IX_LASER_RING, "IS_TECH_IX_LASER", decreaseMod or 1)
    end

    local tearsMod = (2.73/mod:getTps(player))
    if(tearsMod<1) then tearsMod = tearsMod^(1/2) end

    local radiusIncrease = LASER_RING_INCREASEBY*(increaseMod or 1)*tearsMod
    data.TECH_IX_LASER_RING.Radius = math.min(LASER_RING_MAXSIZE, data.TECH_IX_LASER_RING.Radius+radiusIncrease)
end

local function updateLaserRing(_, laser)
    if(not mod:getData(laser, "IS_TECH_IX_LASER")) then return end

    laser.Radius = math.max(0, laser.Radius-LASER_RING_DECREASEBY*mod:getData(laser, "IS_TECH_IX_LASER"))
    if(laser.Radius==0) then laser:Die() end
end
mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, updateLaserRing, LaserVariant.THIN_RED)

local function playerUpdate(_, p)
    if(not p:HasCollectible(mod.COLLECTIBLE_TECH_IX)) then return end

    if(mod:getData(p, "ALREADY_UPDATED_LASER")) then
        mod:setData(p, "ALREADY_UPDATED_LASER", nil)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, playerUpdate, 0)

mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED,
---@param e Entity
---@param w Weapon
function(_, fd, fa, e, w)
    if(not (e and e:ToPlayer())) then return end
    local p = e:ToPlayer()

    if(not p:HasCollectible(mod.COLLECTIBLE_TECH_IX)) then return end
    if(mod:getData(p, "ALREADY_UPDATED_LASER")) then return end
    mod:setData(p, "ALREADY_UPDATED_LASER", true)

    local wType = w:GetWeaponType()
    local wCharge = w:GetCharge()
    local wModifier = w:GetModifiers()
    local wFd = w:GetFireDelay()

    --print(wType,wCharge,wModifier,wFd,p.FrameCount,fd, p.MaxFireDelay)

    if(wType==WeaponType.WEAPON_TEARS) then
        increaseLaserRing(p, 1, 1)
    elseif(wType==WeaponType.WEAPON_BRIMSTONE) then
        increaseLaserRing(p, 0.1, 1)
    elseif(wType==WeaponType.WEAPON_LASER) then
        increaseLaserRing(p, 1, 1)
    elseif(wType==WeaponType.WEAPON_KNIFE) then
        increaseLaserRing(p, 3*wCharge/(p.MaxFireDelay*4), 0.5)
    elseif(wType==WeaponType.WEAPON_BOMBS) then
        increaseLaserRing(p, 1, 1)
    elseif(wType==WeaponType.WEAPON_ROCKETS) then
        increaseLaserRing(p, 1, 1)
    elseif(wType==WeaponType.WEAPON_MONSTROS_LUNGS) then
        increaseLaserRing(p, 1, 0.85)
    elseif(wType==WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
        if(mod:shouldTriggerLudoMove(p, fd)) then
            increaseLaserRing(p, 1, 0.85)
        end
    elseif(wType==WeaponType.WEAPON_TECH_X) then
        increaseLaserRing(p, 3*wCharge/math.ceil(p.MaxFireDelay*3), 0.5)
    elseif(wType==WeaponType.WEAPON_BONE) then
        if(wCharge>0) then
            increaseLaserRing(p, 3*wCharge/(p.MaxFireDelay*3), 0.75)
        else
            increaseLaserRing(p, 1, 0.75)
        end
    elseif(wType==WeaponType.WEAPON_SPIRIT_SWORD) then
        if(wFd==-1) then
            increaseLaserRing(p, 6, 1.2)
        else
            increaseLaserRing(p, 1, 1.2)
        end
    elseif(wType==WeaponType.WEAPON_FETUS) then
        increaseLaserRing(p, 2.5, 0.9)
    elseif(wType==WeaponType.WEAPON_UMBILICAL_WHIP) then
        increaseLaserRing(p, 10, 0.8)
    end
end
)