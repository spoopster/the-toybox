---@param color1 Color
---@param color2 Color
local function colorEqual(color1, color2)
    local colO1 = color1:GetOffset()
    local colO2 = color2:GetOffset()

    local colC1 = color1:GetColorize()
    local colC2 = color2:GetColorize()

    return (color1.R==color2.R and color1.G==color2.G and color1.B==color2.B and color1.A==color2.A and
            colO1.R==colO2.R and colO1.G==colO2.G and colO1.B==colO2.B and
            colC1.R==colC2.R and colC1.G==colC2.G and colC1.B==colC2.B)
end

---@param baseTear EntityTear
local function familiarFireProj(_, baseTear)
    local fam = baseTear.SpawnerEntity and baseTear.SpawnerEntity:ToFamiliar()
    if(not (fam and fam.Player)) then return end

    local tears = {}
    for _, otherTear in ipairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
        if(otherTear.FrameCount==0 and otherTear.SpawnerEntity and GetPtrHash(otherTear.SpawnerEntity)==GetPtrHash(fam)) then
            table.insert(tears, otherTear:ToTear())
        end
    end

    for _, tear in ipairs(tears) do ---@cast tear EntityTear
        local displ = ToyboxMod:getEntityData(fam, "DOG_TEAR_DISPL") or -1
        if(#tears>1) then displ = 0 end

        local pl = fam.Player
        local newTear = pl:FireTear(tear.Position+displ*Vector(0,4):Rotated(tear.Velocity:GetAngleDegrees()), tear.Velocity, true, true, false, pl, tear.CollisionDamage/3.5)
        newTear.SpawnerEntity = fam

        newTear.FallingAcceleration = tear.FallingAcceleration + newTear.FallingAcceleration
        newTear.FallingSpeed = tear.FallingSpeed + newTear.FallingSpeed

        newTear.Scale = tear.Scale * newTear.Scale

        newTear:AddTearFlags(tear.TearFlags)

        newTear.CanTriggerStreakEnd = false
        newTear.KnockbackMultiplier = tear.KnockbackMultiplier * newTear.KnockbackMultiplier

        if(tear.Variant~=TearVariant.BLUE) then
            newTear:ChangeVariant(tear.Variant)
        end

        if(colorEqual(newTear.Color, Color(1,1,1,1))) then
            newTear.Color = tear.Color
        end

        ToyboxMod:copyEntityData(newTear, tear)

        tear:Remove()

        ToyboxMod:setEntityData(fam, "JUST_FIRED_TEAR", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, familiarFireProj)

local makeLaserNotPoop = false

---@param baseLaser EntityLaser
local function familiarFireTech(_, baseLaser)
    local fam = baseLaser.SpawnerEntity and baseLaser.SpawnerEntity:ToFamiliar()
    if(not (fam and fam.Player)) then return end

    local lasers = {}
    for _, otherLaser in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
        if(otherLaser.FrameCount==0 and otherLaser.SpawnerEntity and GetPtrHash(otherLaser.SpawnerEntity)==GetPtrHash(fam)) then
            otherLaser.Visible = false
            otherLaser:ToLaser():SetDamageMultiplier(0)
            table.insert(lasers, otherLaser:ToLaser())
        end
    end

    --[[]]
    for _, laser in ipairs(lasers) do ---@cast laser EntityLaser
        local pl = fam.Player
        makeLaserNotPoop = true
        local newLaser = pl:FireTechLaser(laser.Position, 0, Vector.FromAngle(laser.AngleDegrees), false, laser:GetOneHit(), pl, laser.CollisionDamage/3.5)
        makeLaserNotPoop = false
        newLaser.Position = laser.Position
        newLaser.SpawnerEntity = fam

        newLaser:AddTearFlags(laser.TearFlags)

        --newLaser.LaserLength = laser.LaserLength

        newLaser:SetDisableFollowParent(laser:GetDisableFollowParent())
        newLaser:SetBlackHpDropChance(newLaser.BlackHpDropChance * laser.BlackHpDropChance)
        newLaser:SetScale(newLaser:GetScale() * laser:GetScale())
        newLaser:SetDamageMultiplier(newLaser:GetDamageMultiplier() * (ToyboxMod:getEntityData(laser, "DOG_LASER_DMGMULT") or 1))

        newLaser.PositionOffset = laser.PositionOffset
        newLaser.ParentOffset = laser.ParentOffset
        newLaser.SpriteOffset = laser.SpriteOffset

        if(colorEqual(newLaser.Color, Color(1,1,1,1,0,0,0))) then
            newLaser.Color = ToyboxMod:getEntityData(laser, "DOG_LASER_COLOR") or Color(1,1,1,1)
        end

        ToyboxMod:copyEntityData(newLaser, laser)

        laser:Remove()

        ToyboxMod:setEntityData(fam, "JUST_FIRED_TEAR", true)
    end
    --]]
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_TECH_LASER, familiarFireTech)

---@param laser EntityLaser
local function familiarLaserInit(_, laser)
    if(not makeLaserNotPoop and laser.SpawnerEntity and laser.SpawnerEntity:ToFamiliar()) then
        ToyboxMod:setEntityData(laser, "DOG_LASER_DMGMULT", laser:GetDamageMultiplier())
        ToyboxMod:setEntityData(laser, "DOG_LASER_COLOR", laser.Color)

        laser.MaxDistance = 0.5
        laser:SetDamageMultiplier(0.001)
        laser.Color = Color(1,1,1,0)
        laser.Visible = false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, familiarLaserInit)

---@param fam EntityFamiliar
local function familiarUpdate(_, fam)
    if(not ToyboxMod:getEntityData(fam, "JUST_FIRED_TEAR")) then return end

    ToyboxMod:setEntityData(fam, "JUST_FIRED_TEAR", nil)
    if(fam.FireCooldown>0) then
        local mult = 22/fam.FireCooldown
        fam.FireCooldown = math.max((fam.Player.MaxFireDelay/mult)//1+1, 0)
    end

    ToyboxMod:setEntityData(fam, "DOG_TEAR_DISPL", -(ToyboxMod:getEntityData(fam, "DOG_TEAR_DISPL") or -1))
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiarUpdate)