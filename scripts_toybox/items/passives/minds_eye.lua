local sfx = SFXManager()

local DAMAGE_SPEED = 30*0.5

local COLL_DMG = 2
local BLEED_DURATION = 30*4

local BLEED_COLOR = Color(0.7,0.14,0.1,1,0.3)

local EYE_OFFSET = Vector(0, -17)

---@param pl EntityPlayer
local function updatePlayerHit(_, pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    if(not ((data.MINDS_EYE_HITCOUNTER or 0)>0)) then return end

    local lerpval = data.MINDS_EYE_HITCOUNTER/DAMAGE_SPEED
    if(pl.FrameCount%4<2) then lerpval = lerpval*0.7 end
    pl:SetColor(Color.Lerp(pl.Color, BLEED_COLOR, lerpval), 1, 1, false, false)

    if(data.MINDS_EYE_HITCOUNTER>=DAMAGE_SPEED) then
        pl:ResetDamageCooldown()
        pl:TakeDamage(2, 0, EntityRef(nil), 10)

        data.MINDS_EYE_HITCOUNTER = 0

        local poof1 = Isaac.Spawn(1000,16,3,pl.Position,Vector.Zero,nil)
        poof1.SpriteScale = Vector(1,1)*0.75
        poof1.Color = Color(1,1,1,1,0.3,0,0,1/0.75)
        poof1:GetSprite():SetCustomShader("spriteshaders/pixelateshader")

        local poof2 = Isaac.Spawn(1000,16,4,pl.Position,Vector.Zero,nil)
        poof2.SpriteScale = Vector(1,1)*0.75
        poof2.Color = Color(1,1,1,1,0.3,0,0,1/0.75)
        poof2:GetSprite():SetCustomShader("spriteshaders/pixelateshader")

        --sfx:Play(SoundEffect.SOUND_MAGGOT_BURST_OUT)
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
    end

    if(data.MINDS_EYE_JUSTHIT) then
        data.MINDS_EYE_JUSTHIT = nil
    else
        data.MINDS_EYE_HITCOUNTER = math.max(0, data.MINDS_EYE_HITCOUNTER-1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, updatePlayerHit)

---@param pl EntityPlayer
---@param flag CacheFlag
local function giveEyeFamiliar(_, pl, flag)
    pl:CheckFamiliar(
        ToyboxMod.FAMILIAR_MINDS_EYE,
        (pl:HasCollectible(ToyboxMod.COLLECTIBLE_MINDS_EYE) and 1 or 0),
        pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_MINDS_EYE),
        Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_MINDS_EYE)
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, giveEyeFamiliar, CacheFlag.CACHE_FAMILIARS)


---@param fam EntityFamiliar
local function eyeFamiliarInit(_, fam)
    fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    fam.CollisionDamage = COLL_DMG

    fam.SpriteOffset = EYE_OFFSET
    local sp = fam:GetSprite()
    sp:SetCustomShader("spriteshaders/sphereshader")
    sp:Play("Idle", true)
    sp.Color = Color(1,1,1, 1, 0,0,0, 20, 90, 0, (fam:GetMultiplier()>1 and 5 or 7.9))
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, eyeFamiliarInit, ToyboxMod.FAMILIAR_MINDS_EYE)

---@param fam EntityFamiliar
local function eyeFamiliarUpdate(_, fam)
    local sp = fam:GetSprite()
    local dir = (fam.Player.Position-fam.Position)

    -- angle logic
    local angleDir = dir:GetAngleDegrees()
    local angleDif = ToyboxMod:angleDifference(-sp.Color:GetColorize().G, angleDir)
    local newAngle = sp.Color:GetColorize().G-angleDif*0.15
    sp.Color = Color(1,1,1, 1, 0,0,0, 20, newAngle, 0, (fam:GetMultiplier()>1 and 5 or 7.9))

    -- update logic

    local invisibleDur = (Game():GetLevel().EnterDoor==-1 and 30 or 10)
    if(fam.FrameCount<Game():GetRoom():GetFrameCount()) then
        invisibleDur = Game():GetRoom():GetFrameCount()-fam.FrameCount+30+1
    end

    local room = Game():GetRoom()
    if(room:GetFrameCount()<invisibleDur) then
        fam.Velocity = Vector.Zero
        local enterdoor = Game():GetLevel().EnterDoor
        if(enterdoor~=-1) then
            fam.Position = room:GetClampedPosition(room:GetDoorSlotPosition(enterdoor), 0)
        else
            fam.Position = fam.Player.Position
        end

        fam.Visible = false
        fam:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)

        return
    end

    local data = ToyboxMod:getEntityDataTable(fam)
    local intendedAuraScale = 0.7
    if(not (data.MINDS_EYE_AURA and data.MINDS_EYE_AURA:Exists()) and room:GetFrameCount()>invisibleDur+(invisibleDur>10 and 30 or 10)) then
        local aura = Isaac.Spawn(1000, ToyboxMod.EFFECT_MINDS_EYE, 0, fam.Position, fam.Velocity, fam):ToEffect()
        aura:FollowParent(fam)
        aura.Scale = intendedAuraScale
        aura:Update()

        data.MINDS_EYE_AURA = aura
    end
    local aura = data.MINDS_EYE_AURA
    if(aura and room:GetFrameCount()<=invisibleDur+(invisibleDur>10 and 30 or 10)) then
        aura:Remove()
        aura = nil
    end
    if(aura and aura.State>0) then
        local size = aura.Scale*85

        if(fam.FireCooldown<=0) then
            local hitEnemy = false
            for _, ent in ipairs(Isaac.FindInRadius(aura.Position, size, EntityPartition.ENEMY)) do
                if(ToyboxMod:isValidEnemy(ent)) then
                    local npc = ent:ToNPC()

                    npc:TakeDamage(fam.CollisionDamage, 0, EntityRef(fam), 10)
                    npc:AddBleeding(EntityRef(fam.Player), math.max(0, BLEED_DURATION-npc:GetBleedingCountdown()))

                    if(npc:HasMortalDamage()) then
                        npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
                    end

                    hitEnemy = true
                end
            end
            if(hitEnemy) then
                fam.FireCooldown = 3
            end
        end

        for _, ent in ipairs(Isaac.FindInRadius(aura.Position, size, EntityPartition.PLAYER)) do
            local pl = ent:ToPlayer()
            if(pl and not pl:IsDead()) then
                local effData = ToyboxMod:getEntityData(pl, "MINDS_EYE_HITCOUNTER") or 0
                effData = effData+1
                ToyboxMod:setEntityData(pl, "MINDS_EYE_HITCOUNTER", effData)
                ToyboxMod:setEntityData(pl, "MINDS_EYE_JUSTHIT", true)

                sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 0.3, 4, false, 0.5+0.5*effData/DAMAGE_SPEED)
            end
        end
    end
    if(fam.FireCooldown>0) then
        fam.FireCooldown = fam.FireCooldown-1
    end

    if(room:GetFrameCount()<=invisibleDur+20) then
        fam.Visible = true

        local newcol = Color.Lerp(sp.Color, sp.Color, 1)
        newcol.A = (room:GetFrameCount()-invisibleDur)/20
        sp.Color = newcol

        local enterdoor = Game():GetLevel().EnterDoor
        if(enterdoor~=-1) then
            local ogpos = room:GetDoorSlotPosition(enterdoor)
            local dif = (room:GetClampedPosition(ogpos, 10)-ogpos):Normalized()

            fam.Velocity = dif*(0.2+newcol.A*2.8)
        else
            fam.SpriteOffset = EYE_OFFSET+Vector(0,-10*(1-newcol.A)^3)
        end

        if(room:GetFrameCount()==10+20) then
            fam:ClearEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        end

        return
    end

    -- follow player logic
    local maxlen = 1
    local len = dir:Length()

    local maxfastdist = 40*9
    local fastdist = 40*2.5
    local fastspeed = 7

    local regspeed = 3
    if(len>fastdist) then
        if(len<=maxfastdist) then
            dir:Resize(regspeed+(fastspeed-regspeed)*(len-fastdist)/(maxfastdist-fastdist))
        else
            dir:Resize(fastspeed)
        end
    elseif(len>regspeed) then
        dir:Resize(regspeed)
    end

    fam.Velocity = ToyboxMod:lerp(fam.Velocity, dir, 0.05)
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, eyeFamiliarUpdate, ToyboxMod.FAMILIAR_MINDS_EYE)

---@param effect EntityEffect
local function eyeEffectInit(_, effect)
    local sp = effect:GetSprite()
    sp:Play("Aura", true)
    sp:SetCustomShader("spriteshaders/eyeshader")

    effect.DepthOffset = -1000

    effect.State = 0
    effect.Color = Color(1,1,1,0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, eyeEffectInit, ToyboxMod.EFFECT_MINDS_EYE)

---@param effect EntityEffect
local function eyeEffectRender(_, effect, offs)
    if(not (effect.Parent and effect.Parent:Exists())) then
        effect:Remove()
        return
    end

    local sp = effect:GetSprite()

    local trueScale = effect.Scale
    effect.SpriteScale = Vector(1,1)*trueScale

    local data = ToyboxMod:getEntityDataTable(effect)
    data.DIDDY_MANGO = data.DIDDY_MANGO or 0
    data.DIDDY_MANGO = data.DIDDY_MANGO*0.9 + (1-effect.Color.A)*0.04

    local rpos = Isaac.WorldToRenderPosition(effect.Position)+offs
    local posScale = 1/500
    effect.Color = Color(1,1,1,effect.Color.A+data.DIDDY_MANGO,0,0,0,(Game():GetFrameCount()/30/5),rpos.X*posScale, rpos.Y*posScale, trueScale)
    if(effect.FrameCount>20) then
        effect.State = 1
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, eyeEffectRender, ToyboxMod.EFFECT_MINDS_EYE)