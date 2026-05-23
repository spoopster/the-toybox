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

---@param pl EntityPlayer
local function addMango(_, _, _, firstTime, _, _, pl)
    pl:AddInnateTrinket(TrinketType.TRINKET_THE_TWINS, 1, "ToyboxOcDogTwins")
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addMango, ToyboxMod.COLLECTIBLE_OC_DOG)

---@param pl EntityPlayer
local function removeMango(_, pl)
    pl:RemoveInnateTrinket(TrinketType.TRINKET_THE_TWINS, 1, "ToyboxOcDogTwins")
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, removeMango, ToyboxMod.COLLECTIBLE_OC_DOG)

---@param baseTear EntityTear
local function familiarFireProj(_, baseTear)
    local fam = baseTear.SpawnerEntity and baseTear.SpawnerEntity:ToFamiliar()
    if(not (fam and fam.Player and fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_OC_DOG))) then return end

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
            if(tear.SubType~=0) then
                newTear.SubType = tear.SubType
            end
            newTear:ChangeVariant(tear.Variant)
        end

        if(colorEqual(newTear.Color, Color(1,1,1,1))) then
            newTear.Color = tear.Color
        end

        ToyboxMod:copyEntityData(newTear, tear)

        tear.Visible = false
        tear.Color = Color(1,1,1,0)
        tear.SpriteScale = Vector(0,0)
        tear:Remove()

        ToyboxMod:setEntityData(fam, "JUST_FIRED_TEAR", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, familiarFireProj)

local makeLaserNotPoop = false

---@param baseLaser EntityLaser
local function familiarFireTech(_, baseLaser)
    local fam = baseLaser.SpawnerEntity and baseLaser.SpawnerEntity:ToFamiliar()
    if(not (fam and fam.Player and fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_OC_DOG))) then return end

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

---@param baseLaser EntityLaser
local function familiarFireBrim(_, baseLaser)
    local fam = baseLaser.SpawnerEntity and baseLaser.SpawnerEntity:ToFamiliar()
    if(not (fam and fam.Player and fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_OC_DOG))) then return end

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
        local newLaser = pl:FireBrimstone(Vector.FromAngle(laser.AngleDegrees), pl, laser.CollisionDamage/3.5)
        makeLaserNotPoop = false
        newLaser.Position = laser.Position
        --newLaser.SpawnerEntity = fam
        newLaser.Parent = laser.Parent

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
    end
    --]]
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_BRIMSTONE, familiarFireBrim)

---@param laser EntityLaser
local function familiarLaserInit(_, laser)
    if(not makeLaserNotPoop and (laser.SpawnerEntity and laser.SpawnerEntity:ToFamiliar()) or (laser.Parent and laser.Parent:ToFamiliar())) then
        local pl = ((laser.SpawnerEntity and laser.SpawnerEntity:ToFamiliar()) or (laser.Parent and laser.Parent:ToFamiliar())).Player
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_OC_DOG)) then
            ToyboxMod:setEntityData(laser, "DOG_LASER_DMGMULT", laser:GetDamageMultiplier())
            ToyboxMod:setEntityData(laser, "DOG_LASER_COLOR", laser.Color)

            laser.MaxDistance = 0.5
            laser:SetDamageMultiplier(0.001)
            laser.Color = Color(1,1,1,0)
            laser.Visible = false
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, familiarLaserInit)

---@param fam EntityFamiliar
local function familiarUpdate(_, fam)
    if(not fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_OC_DOG)) then return end

    if(ToyboxMod:getEntityData(fam, "JUST_FIRED_TEAR")) then
        ToyboxMod:setEntityData(fam, "JUST_FIRED_TEAR", nil)
        if(fam.FireCooldown>0) then
            local mult = 22/fam.FireCooldown
            fam.FireCooldown = math.max((fam.Player.MaxFireDelay/mult)//1+1, 0)
        end

        ToyboxMod:setEntityData(fam, "DOG_TEAR_DISPL", -(ToyboxMod:getEntityData(fam, "DOG_TEAR_DISPL") or -1))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiarUpdate)

---@param fam EntityFamiliar
local function preFamiliarUpdate(_, fam)
    if(not fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_OC_DOG)) then return end

    if(fam.Player:GetWeapon(1) and fam.Player:GetWeapon(1):GetModifiers() & WeaponModifier.SOY_MILK == WeaponModifier.SOY_MILK) then
        local spr = fam:GetSprite()
        local player = fam.Player

        fam:FollowParent()

        if(ToyboxMod:isPlayerShooting(player)) then
            local dir = math.floor((player:GetShootingInput():GetAngleDegrees()+225)%360/90)
            local fireVec = Isaac.GetAxisAlignedUnitVectorFromDir(dir)

            if(fam.FireCooldown==300) then
                fam:PlayChargeAnim(dir)
            end
            fam.FireCooldown = 299

            if(string.find(spr:GetAnimation(), "Charge")) then
                spr:SetFrame(ToyboxMod:getEntityData(fam, "DOG_SOYBRIM_CHARGEFRAME") or 0)
                ToyboxMod:setEntityData(fam, "DOG_SOYBRIM_CHARGEFRAME", spr:GetFrame()+5)

                if((ToyboxMod:getEntityData(fam, "DOG_SOYBRIM_CHARGEFRAME") or 0)>=spr:GetCurrentAnimationData():GetLength()) then
                    fam:PlayShootAnim(dir)
                end
            end

            if(not string.find(spr:GetAnimation(), "Charge")) then
                fam:PlayShootAnim(dir)

                local brim = ToyboxMod:getEntityData(fam, "DOG_SOYBRIM_LASER")
                if(not (brim and not brim:IsDead() and brim:GetTimeout()>0)) then
                    if(brim) then
                        brim:Remove()
                        brim = nil
                    end

                    makeLaserNotPoop = true
                    brim = player:FireBrimstone(fireVec, pl, 3*fam:GetMultiplier()/3.5)
                    makeLaserNotPoop = false

                    brim:SetScale(brim:GetScale() * 0.5)

                    brim.Parent = fam

                    brim:SetTimeout(7)
                    ToyboxMod:setEntityData(fam, "DOG_SOYBRIM_LASER", brim)

                    return
                end

                brim:SetTimeout(7)
                brim:RotateToAngle(player:GetShootingInput():GetAngleDegrees())

                brim.PositionOffset = Vector(0,-19)
                if(dir==Direction.LEFT) then brim.PositionOffset = Vector(-8, -22)
                elseif(dir==Direction.RIGHT) then brim.PositionOffset = Vector(8, -22) end

                brim.Position = brim.Position-Vector(0,brim.DepthOffset)

                if(dir==Direction.UP) then brim.DepthOffset = -10
                else brim.DepthOffset = 3000 end
            end
        else
            fam.FireCooldown = 300

            fam:PlayFloatAnim(Direction.DOWN)

            ToyboxMod:setEntityData(fam, "DOG_SOYBRIM_CHARGEFRAME", 0)
        end
        
        return true
    end

    if(fam.FireCooldown<30) then
        if(fam.Player.MaxFireDelay<=0) then
            fam.FireCooldown = 0
        else
            local oldFrames = (ToyboxMod:getEntityData(fam, "DOG_FIRE_REMAINDER") or 0)
            local framesPerFrame = 30/fam.Player.MaxFireDelay
            oldFrames = oldFrames+framesPerFrame-1

            local framesToRemove = ToyboxMod:sign(oldFrames)*(math.abs(oldFrames)//1)

            oldFrames = oldFrames-framesToRemove
            if(fam.FireCooldown>-15) then
                fam.FireCooldown = fam.FireCooldown-framesToRemove
            end

            ToyboxMod:setEntityData(fam, "DOG_FIRE_REMAINDER", oldFrames)
        end
    else
        ToyboxMod:setEntityData(fam, "DOG_FIRE_REMAINDER", 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, preFamiliarUpdate, FamiliarVariant.LIL_BRIMSTONE)

---@param fam EntityFamiliar
local function preFamiliarRender(_, fam, offset)
    if(not fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_OC_DOG)) then return end

    if(fam.Player:GetWeapon(1) and fam.Player:GetWeapon(1):GetModifiers() & WeaponModifier.SOY_MILK == WeaponModifier.SOY_MILK) then
        local spr = fam:GetSprite()

        spr:Render(Isaac.WorldToRenderPosition(fam.Position)+offset)

        return false
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, CallbackPriority.LATE, preFamiliarRender, FamiliarVariant.LIL_BRIMSTONE)