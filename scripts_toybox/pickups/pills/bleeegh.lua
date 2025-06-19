
local sfx = SFXManager()

local DURATION = 5*60
local DURATION_HORSE = 7*60
local DMG = 2
local DMG_HORSE = 3.5

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    local data = ToyboxMod:getEntityDataTable(player)
    data.BLEEEGH_HORSE = isHorse
    data.BLEEEGH_DURATION = (isHorse and DURATION_HORSE or DURATION)

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
    sfx:Play(12)
    sfx:Play(11)
    sfx:Play(6)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_EFFECT.BLEEEGH)

---@param player EntityPlayer
local function bleeeghUpdate(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    data.BLEEEGH_DURATION = (data.BLEEEGH_DURATION or 0)
    if(data.BLEEEGH_DURATION<=0) then
        if(data.BLEEEGH_ENT and data.BLEEEGH_ENT:Exists() and not data.BLEEEGH_ENT:IsDead()) then data.BLEEEGH_ENT:Die() end
    else
        if(not (data.BLEEEGH_ENT and data.BLEEEGH_ENT:Exists())) then
            local laser = EntityLaser.ShootAngle(LaserVariant.THICK_BROWN, player.Position, player:GetAimDirection():GetAngleDegrees(), math.ceil(data.BLEEEGH_DURATION/2), Vector(0,-15), player)
            laser.Parent = player
            laser.CollisionDamage = (data.BLEEEGH_HORSE and DMG_HORSE or DMG)
            ToyboxMod:setEntityData(laser, "BLEEEGH_LASER", true)
            sfx:Play(SoundEffect.SOUND_POOP_LASER, 0, 10)

            data.BLEEEGH_ENT = laser
        else
            if(player:GetAimDirection():Length()>0.01) then
                local angleDif = ToyboxMod:angleDifference(data.BLEEEGH_ENT.AngleDegrees, player:GetAimDirection():GetAngleDegrees())
                data.BLEEEGH_ENT.AngleDegrees = data.BLEEEGH_ENT.AngleDegrees+angleDif*0.07
            end

            player:AddVelocity(-Vector.FromAngle(data.BLEEEGH_ENT.AngleDegrees)*0.2)
        end

        data.BLEEEGH_DURATION = data.BLEEEGH_DURATION-1
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, bleeeghUpdate, 0)