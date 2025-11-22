local sfx = SFXManager()
-- idk how to do mouse input

local BREATH_FLAMES = 15
local BREATH_COOLDOWN = 2

local BREATH_VEL = 15
local BREATH_ARC = 40
local BREATH_WAVE_FREQ = 10

local BREATH_FIRE_SUB = 200
local BREATH_FIRE_TIMEOUT = 20
local BREATH_FIRE_DMG_MOD = 1.5
local BREATH_FIRE_BASE_SCALE = 0.5

local BREATH_FIRE_FAM_MOD = 1

---@param dir Direction
local function dirToVector(dir)
    local angle = 90
    if(dir==Direction.RIGHT) then angle = 0
    elseif(dir==Direction.LEFT) then angle = 180
    elseif(dir==Direction.UP) then angle = 270 end

    return Vector.FromAngle(angle)
end
---@param vec Vector
local function vectorToDir(vec)
    local a = vec:GetAngleDegrees()
    return math.floor((a+225)%360/90)
end

---@param effect EntityEffect
local function fireBreathHelperInit(_, effect)
    effect.Parent = effect.SpawnerEntity
    if(not effect.Parent) then
        effect.Parent = Isaac.GetPlayer()
    end

    effect.Position = effect.Parent.Position
    effect:FollowParent(effect.Parent)
    effect:SetTimeout((BREATH_FLAMES+1)*BREATH_COOLDOWN)

    ToyboxMod:setEntityData(effect, "PEPPERX_LAST_DIR", (effect.Velocity:Length()<0.1 and Vector(1,0) or effect.Velocity):Normalized())

    effect.Visible = false

    sfx:Play(SoundEffect.SOUND_WAR_FLAME)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, fireBreathHelperInit, ToyboxMod.EFFECT_VARIANT.FLAME_BREATH_HELPER)

---@param effect EntityEffect
local function fireBreathHelperUpdate(_, effect)
    if(effect.FrameCount<BREATH_COOLDOWN or effect.FrameCount%BREATH_COOLDOWN~=0) then return end

    local ent = effect.Parent or Isaac.GetPlayer()
    local pl = ToyboxMod:getPlayerFromEnt(effect.Parent)
    if(not (ent and pl)) then return end

    local dir = Vector.Zero
    if(ent:ToFamiliar()) then
        local fam = ent:ToFamiliar()
        dir = (fam.ShootDirection==-1 and (fam.MoveDirection==-1 and dir or dirToVector(fam.MoveDirection)) or dirToVector(fam.ShootDirection))
    elseif(ent:ToPlayer()) then
        dir = (pl:GetShootingJoystick():Length()<0.1 and (pl.Velocity:Length()<pl.MoveSpeed and Vector.Zero or pl.Velocity) or pl:GetShootingJoystick()):Normalized()
    end

    local currentDir = (ToyboxMod:getEntityData(effect, "PEPPERX_LAST_DIR") or Vector(1,0)):Normalized()
    if(dir:Length()<0.5) then
        dir = currentDir
    end

    currentDir = currentDir:Rotated(ToyboxMod:angleDifference(currentDir:GetAngleDegrees(), dir:GetAngleDegrees())*0.33)

    local angleRotation = math.sin(math.rad((effect.FrameCount-BREATH_COOLDOWN-1)*360/BREATH_WAVE_FREQ))*BREATH_ARC/2
    local shootDir = currentDir:Rotated(angleRotation):Resized(BREATH_VEL)

    local isFamiliar = (ent:ToFamiliar() and true or false)
    local dmg = (effect.CollisionDamage==0 and (isFamiliar and BREATH_FIRE_FAM_MOD or 1)*BREATH_FIRE_DMG_MOD*pl.Damage or effect.CollisionDamage)

    local fire = Isaac.Spawn(1000,EffectVariant.RED_CANDLE_FLAME,BREATH_FIRE_SUB,effect.Position,shootDir,pl):ToEffect()
    fire:SetTimeout(BREATH_FIRE_TIMEOUT)
    fire.CollisionDamage = dmg/BREATH_FIRE_BASE_SCALE
    fire.Scale = BREATH_FIRE_BASE_SCALE*(isFamiliar and BREATH_FIRE_FAM_MOD or 1)
    ToyboxMod:setEntityData(fire, "PEPPERX_FIRE_DMG", dmg)
    fire.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    fire:Update()

    if(ent:ToPlayer()) then
        pl:SetHeadDirection(vectorToDir(currentDir), BREATH_COOLDOWN, true)
    end

    ToyboxMod:setEntityData(effect, "PEPPERX_LAST_DIR", currentDir)

    if(effect.Timeout==0) then effect:Remove() end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, fireBreathHelperUpdate, ToyboxMod.EFFECT_VARIANT.FLAME_BREATH_HELPER)

---@param effect EntityEffect
local function breathFireUpdate(_, effect)
    if(effect.SubType~=BREATH_FIRE_SUB) then return end

    local dmg = ToyboxMod:getEntityData(effect, "PEPPERX_FIRE_DMG") or (3.5*BREATH_FIRE_DMG_MOD)

    local frac = effect.FrameCount/BREATH_FIRE_TIMEOUT
    effect.Scale = (0.5+frac)*(isFamiliar and BREATH_FIRE_FAM_MOD or 1)
    effect.Color = Color(0.8,1.1,0.6,1-frac*0.4,0,0.1,0,0.4+0.3*frac,1-0.8*frac,0,1-frac)

    effect.CollisionDamage = dmg/effect.Scale
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, breathFireUpdate, EffectVariant.RED_CANDLE_FLAME)