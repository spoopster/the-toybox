local sfx = SFXManager()

local TIMED_UNFILLED_RECHARGE = 30*2.5

local ARM_DAMAGE = 12
local ARM_SWING_SIZE = 27

local FILLED_TEARS_NUM = 6
local FILLED_TEARS_ARC = 90
local FILLED_TEARS_SPEED = 17
local FILLED_TEARS_DMGMULT = 1.5

---@param vec Vector
local function vectorToDir(vec)
    local a = vec:GetAngleDegrees()
    return math.floor((a+225)%360/90)
end

---@param rng RNG
---@param pl EntityPlayer
---@param flags UseFlag
local function useWoodenArm(_, _, rng, pl, flags, slot, _)
    local rotation = 90
    if(pl:GetAimDirection():Length()>0.01) then
        rotation = Isaac.GetAxisAlignedUnitVectorFromDir(vectorToDir(pl:GetAimDirection())):GetAngleDegrees()
    elseif(pl:GetMovementJoystick():Length()>0.01) then
        rotation = Isaac.GetAxisAlignedUnitVectorFromDir(vectorToDir(pl:GetMovementJoystick())):GetAngleDegrees()
    elseif(pl.Velocity:Length()>0.5) then
        rotation = Isaac.GetAxisAlignedUnitVectorFromDir(vectorToDir(pl.Velocity)):GetAngleDegrees()
    end

    local rotVec = Vector.FromAngle(rotation)
    local spawnPos = pl.Position+rotVec*3
    local eff = Isaac.Spawn(1000, ToyboxMod.EFFECT_WOODEN_ARM, 0, spawnPos, pl.Velocity, pl):ToEffect()
    eff.Parent = pl
    eff:FollowParent(pl)

    eff.SpriteRotation = rotation-90
    eff.SpriteOffset = Vector(3,0):Rotated(eff.SpriteRotation+90)+Vector(0,-6)
    eff.DepthOffset = pl.DepthOffset+3
    eff:GetSprite():Play("Swing")

    sfx:Play(SoundEffect.SOUND_SHELLGAME)

    if(slot~=-1 and pl:GetTotalActiveCharge(slot)>=pl:GetActiveMaxCharge(slot)) then
        local tearCol = Color(1.5,1,1,1,0.1,0,0,2.5,1,1,1)

        for i=1, FILLED_TEARS_NUM do
            local tearVel = rotVec*FILLED_TEARS_SPEED+pl:GetTearMovementInheritance(rotVec)
            local tearAngle = tearVel:GetAngleDegrees()
            local squishMult = (Vector(1,0.8):Rotated(tearAngle))
            squishMult = Vector(math.abs(squishMult.X), math.abs(squishMult.Y))

            local tearPos = spawnPos-rotVec*8+(Vector.FromAngle(FILLED_TEARS_ARC*(2*(i-1)/(FILLED_TEARS_NUM-1)-1))*Vector(1,0.8)*25):Rotated(tearAngle)
            local tear = pl:FireTear(tearPos, tearVel, true, true, false, pl, FILLED_TEARS_DMGMULT)

            tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
            tear:ChangeVariant(TearVariant.MYSTERIOUS)
            tear.Color = tearCol
            tear.Scale = tear.Scale*1.2
            tear:SetSize(tear.Size, tear.SizeMulti*1.3, 12)

            ToyboxMod:setEntityData(tear, "ARM_TEAR", true)
        end

        sfx:Play(ToyboxMod.SFX_ARM_ATTACK)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = false,
        }
    else
        if(slot~=-1) then
            pl:GetActiveItemDesc(slot).VarData = TIMED_UNFILLED_RECHARGE
            ToyboxMod:setEntityData(eff, "WOODENARM_SHOULD_CHARGE", true)
        end

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useWoodenArm, ToyboxMod.COLLECTIBLE_WOODEN_ARM)

---@param eff EntityEffect
local function woodenArmUpdate(_, eff)
    if(eff:GetSprite():IsFinished("Swing")) then
        eff:Remove()
        return
    end

    if(eff.FrameCount>8) then return end
    local capRad = ARM_SWING_SIZE*eff.SpriteScale.X
    local capPos = eff.Position-(eff.SpawnerEntity or eff).Velocity+Vector(0.9,0):Rotated(eff.SpriteRotation+90)*capRad

    local shouldCharge = false

    local pl = eff.SpawnerEntity and eff.SpawnerEntity:ToPlayer()

    local data = ToyboxMod:getEntityDataTable(eff)

    for _, ent in ipairs(Isaac.FindInRadius(capPos, capRad, EntityPartition.ENEMY)) do
        if(not (data.WOODENARM_HITLIST or {})[tostring(ent.InitSeed)]) then
            ent:TakeDamage(ARM_DAMAGE, 0, EntityRef(pl), 0)
            ent:AddVelocity((ent.Position-eff.Position):Resized(17))

            if(ent:IsVulnerableEnemy()) then
                ent:BloodExplode()
            end

            data.WOODENARM_HITLIST = data.WOODENARM_HITLIST or {}
            data.WOODENARM_HITLIST[tostring(ent.InitSeed)] = true
        end
    end
    if(eff.FrameCount<=5) then -- proj parry
        for _, ent in ipairs(Isaac.FindInRadius(capPos, capRad, EntityPartition.BULLET)) do
            if(not ent:IsDead()) then
                ent:Die()
                shouldCharge = true
            end
        end

        if(shouldCharge and data.WOODENARM_SHOULD_CHARGE and pl) then
            for _, slot in pairs(ActiveSlot) do
                pl:AddActiveCharge(1, slot, true, false, true)
            end
            data.WOODENARM_SHOULD_CHARGE = nil -- makes it only charge once per arm

            sfx:Play(868)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, woodenArmUpdate, ToyboxMod.EFFECT_WOODEN_ARM)

---@param pl EntityPlayer
local function peffectUpdate(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_WOODEN_ARM)) then return end

    for _, slot in pairs(ActiveSlot) do
        if(pl:GetActiveItem(slot)==ToyboxMod.COLLECTIBLE_WOODEN_ARM) then
            local desc = pl:GetActiveItemDesc(slot)
            --print(slot, desc.VarData)
            if(desc.VarData>0) then
                if(desc.VarData==1) then
                    sfx:Play(SoundEffect.SOUND_BEEP)
                end
                desc.VarData = desc.VarData-1

                if(pl:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT)) then
                    desc.VarData = math.min(desc.VarData, TIMED_UNFILLED_RECHARGE//2)
                end
            end
            if(pl:GetTotalActiveCharge(slot)>=pl:GetActiveMaxCharge(slot)) then
                desc.VarData = TIMED_UNFILLED_RECHARGE
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, peffectUpdate)

---@param slot ActiveSlot
---@param pl EntityPlayer
---@param minCharge integer
local function getMinUsableCharge(_, slot, pl, minCharge)
    if(slot==-1) then return end
    
    local desc = pl:GetActiveItemDesc(slot)
    if(desc.VarData==0) then
        return 0
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MIN_USABLE_CHARGE, getMinUsableCharge, ToyboxMod.COLLECTIBLE_WOODEN_ARM)

---@param player EntityPlayer
---@param slot ActiveSlot
---@param offset Vector
---@param a number
---@param scale Vector
---@param chargeOffset Vector
local function renderUnder(_, player, slot, offset, a, scale, chargeOffset)
    if(slot==-1) then return end

    local maxCharges = player:GetActiveMaxCharge(slot)
    local currentCharges = player:GetActiveCharge(slot)

    if(player:GetTotalActiveCharge(slot)>=maxCharges) then return end

    local desc = player:GetActiveItemDesc(slot)
    local chargeBarSize = (desc.VarData/TIMED_UNFILLED_RECHARGE)

    local chargeSprite = ToyboxMod.GAME:GetHUD():GetChargeBarSprite()

    local topRightClamp = Vector(0,3+chargeBarSize*(maxCharges-currentCharges)*23/maxCharges)
    local botrightClamp = Vector(0,6+currentCharges*24/maxCharges)

    local ogAnim = chargeSprite:GetAnimation() -- should usually be the charge overlay animation

    chargeSprite.Color = Color(1,1,1,a*0.25)
    chargeSprite:Play("BarFull", true)
    chargeSprite:Render(chargeOffset, topRightClamp, botrightClamp)
    chargeSprite.Color = Color(1,1,1,a)

    chargeSprite:Play(ogAnim, true)
    chargeSprite:Render(chargeOffset)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderUnder, ToyboxMod.COLLECTIBLE_WOODEN_ARM)

---@param tear EntityTear
local function tearUpdate(_, tear)
    if(not ToyboxMod:getEntityData(tear, "ARM_TEAR")) then return end

    for _, proj in ipairs(Isaac.FindInRadius(tear.Position, tear.Size*tear.SizeMulti.X, EntityPartition.BULLET)) do
        if(proj:ToProjectile() and not proj:IsDead()) then
            proj:Die()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, tearUpdate)