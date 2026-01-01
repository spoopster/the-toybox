local ROTATE_SPEED = 0.08
local LIGHT_DIST = -3

local START_ROTATION_DURATION = 36

local LIGHT_ARC = 30
local MAX_LIGHT_DIST = 5*40

-----------------------------------------------------------------------------------------------------
--------------------------------------------- NPC LOGIC ---------------------------------------------
-----------------------------------------------------------------------------------------------------

local function dir2Angle(x)
    if(x==Direction.DOWN) then return 90
    elseif(x==Direction.LEFT) then return 180
    elseif(x==Direction.UP) then return 270
    else return 0 end
end

---@param npc EntityNPC
local function eyeSpyInit(_, npc)
    if(not (npc.Variant==ToyboxMod.VAR_EYE_SPY)) then return end

    local dir = (npc.SubType & 3)
    if(dir==0) then npc.I1=0
    elseif(dir==1) then npc.I1=90
    elseif(dir==2) then npc.I1=180
    elseif(dir==3) then npc.I1=270 end
    npc.I2 = (npc.SubType>>2) & 1

    local sp = npc:GetSprite()
    sp:Play((npc.I2==1 and "RotateInverse" or "Rotate"), true)
    if(npc.I1==90) then
        if(npc.I2==1) then sp:SetFrame(27)
        else sp:SetFrame(9) end
    elseif(npc.I1==180) then
        if(npc.I2==1) then sp:SetFrame(18)
        else sp:SetFrame(18) end
    elseif(npc.I1==270) then
        if(npc.I2==1) then sp:SetFrame(9)
        else sp:SetFrame(27) end
    end
    --sp:Stop()

    sp.PlaybackSpeed = 1

    npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    npc:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, eyeSpyInit, ToyboxMod.NPC_MAIN)

---@param npc EntityNPC
local function eyeSpyUpdate(_, npc)
    if(not (npc.Variant==ToyboxMod.VAR_EYE_SPY)) then return end

    local sp = npc:GetSprite()

    if(npc.State==NpcState.STATE_INIT and npc.StateFrame==START_ROTATION_DURATION) then
        npc.State = NpcState.STATE_IDLE
        npc.StateFrame = 0

        sp:Continue(true)
    end

    if(npc.State==NpcState.STATE_IDLE) then
        sp.PlaybackSpeed = ROTATE_SPEED

        if(not (npc.Child and npc.Child:Exists())) then
            local light = Isaac.Spawn(1000, ToyboxMod.EFFECT_FEAR_LIGHT, npc.I2, npc.Position, Vector.Zero, npc):ToEffect()
            light:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            light.Rotation = light.Rotation+npc.I1
            light:Update()

            npc.Child = light
        end
    end

    npc.StateFrame = npc.StateFrame+1
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, eyeSpyUpdate, ToyboxMod.NPC_MAIN)

---@param npc EntityNPC
local function eyeSpyDeath(_, npc)
    if(not (npc.Variant==ToyboxMod.VAR_EYE_SPY)) then return end

    npc.Child:Remove()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, eyeSpyDeath, ToyboxMod.NPC_MAIN)

local function eyeSpyTakeDmg(_, npc)
    if(npc.Variant==ToyboxMod.VAR_EYE_SPY) then
        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, eyeSpyTakeDmg, ToyboxMod.NPC_MAIN)

-----------------------------------------------------------------------------------------------------
-------------------------------------------- LIGHT LOGIC --------------------------------------------
-----------------------------------------------------------------------------------------------------

---@param effect EntityEffect
local function lightInit(_, effect)
    local sp = effect:GetSprite()

    sp:GetLayer(0):GetBlendMode():SetMode(BlendType.OVERLAY)

    effect.DepthOffset = -1000
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, lightInit, ToyboxMod.EFFECT_FEAR_LIGHT)

---@param effect EntityEffect
local function lightUpdate(_, effect)
    if(not (effect.SpawnerEntity and effect.SpawnerEntity:Exists() and not effect.SpawnerEntity:IsDead())) then
        effect.Visible = false
        effect:Remove()
        return
    end

    local sp = effect.SpawnerEntity

    effect.Rotation = (effect.Rotation+(effect.SubType~=0 and -1 or 1)*10*ROTATE_SPEED)%360
    effect.SpriteRotation = effect.Rotation


    effect.Position = sp.Position+Vector(0, LIGHT_DIST):Rotated(effect.Rotation)

    local entitiesToFear = {}
    if(not (sp:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then
        for _, ent in ipairs(Isaac.FindInRadius(effect.Position, MAX_LIGHT_DIST, EntityPartition.PLAYER)) do
            local angleDif = ToyboxMod:angleDifference((ent.Position-effect.Position):GetAngleDegrees(), effect.Rotation+90)

            if(math.abs(angleDif)<=LIGHT_ARC/2) then
                table.insert(entitiesToFear, ent)
            end
        end
    end

    if(sp:HasEntityFlags(EntityFlag.FLAG_CHARM) or sp:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        for _, ent in ipairs(Isaac.FindInRadius(effect.Position, MAX_LIGHT_DIST, EntityPartition.ENEMY)) do
            local angleDif = ToyboxMod:angleDifference((ent.Position-effect.Position):GetAngleDegrees(), effect.Rotation+90)

            if(math.abs(angleDif)<=LIGHT_ARC/2) then
                table.insert(entitiesToFear, ent)
            end
        end
    end

    for _, ent in ipairs(entitiesToFear) do
        ent:AddFear(EntityRef(sp), 2)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, lightUpdate, ToyboxMod.EFFECT_FEAR_LIGHT)