local LASER_RING_RADIUS = 40
local LASER_RING_DAMAGE = 0.6

local LASER_EXTRA_START = 10
local LASER_EXTRA_EXPO = 0.63
local LASER_EXTRA_MULT = 0.02
local LASER_EXTRA_DMGMULT = 0.01

local LASER_STACK_DMGMULT = 0.5

local LASER_SPARK_COOLDOWN = 10

---@param pl EntityPlayer
local function trySpawnLaser(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_TECH_IX)) then return end

    local laser = ToyboxMod:getEntityData(pl, "LASER_BRAIN_LASER")
    local isFiring = ToyboxMod:isPlayerShooting(pl)

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_TECH_IX)

    if(isFiring and not (laser and laser:Exists() and not laser:IsDead())) then
        laser = Isaac.Spawn(7,LaserVariant.THIN_RED,LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT,pl.Position,pl.Velocity,pl):ToLaser()
        laser.Radius = LASER_RING_RADIUS*0.1
        laser.CollisionDamage = LASER_RING_DAMAGE
        laser.Timeout = 10
        laser.Parent = pl
        laser.Color = Color.LaserPoison -- Color(0.9,1.2,0.7,1,0,0.5,0,0.5,0.9,0,1)
        laser.DepthOffset = -50
        laser.PositionOffset = Vector(0,-12)

        ToyboxMod:setEntityData(pl, "LASER_BRAIN_LASER", laser)
        ToyboxMod:setEntityData(laser, "IS_LASER_BRAIN_LASER", true)
        ToyboxMod:setEntityData(laser, "LASER_BRAIN_DMGMULT", mult)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, trySpawnLaser)

local function updateLaser(_, laser)
    if(laser:IsDead()) then return end
    if(not ToyboxMod:getEntityData(laser, "IS_LASER_BRAIN_LASER")) then return end

    local dmgmult = ToyboxMod:getEntityData(laser, "LASER_BRAIN_DMGMULT") or 1

    local extramult = (math.max(1,laser.FrameCount-LASER_EXTRA_START)^LASER_EXTRA_EXPO-1)
    laser.Radius = ToyboxMod:lerp(laser.Radius, LASER_RING_RADIUS*(1+extramult*LASER_EXTRA_MULT), 0.33)
    laser.CollisionDamage = LASER_RING_DAMAGE*(1+extramult*LASER_EXTRA_DMGMULT)*(1+(dmgmult-1)*LASER_STACK_DMGMULT)
    laser.Timeout = 30

    local pl = ToyboxMod:getPlayerFromEnt(laser)
    if(not (pl and pl:ToPlayer() and ToyboxMod:isPlayerShooting(pl:ToPlayer()))) then
        laser:Die()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, updateLaser, LaserVariant.THIN_RED)