local BASE_AURA_RADIUS = 2.5*40
local CLEAR_AURA_RADIUS = 1*40

local WEAKNESS_DURATION = 30*0.5

local DMG_MULT = 0.6
local SPEED_DOWN = 0.3

---@param pl EntityPlayer
local function evalCache(_, pl)
    pl:CheckFamiliar(
        ToyboxMod.FAMILIAR_MINDFLAYER_BABY,
        pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_MINDFLAYER_BABY)+pl:GetEffects():GetCollectibleEffectNum(ToyboxMod.COLLECTIBLE_MINDFLAYER_BABY),
        pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_MINDFLAYER_BABY),
        Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_MINDFLAYER_BABY)
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FAMILIARS)

---@param pl EntityPlayer
local function checkEnterExitFlayerRadius(_, pl)
    local data = ToyboxMod:getEntityDataTable(pl)

    local prevAuras = (data.MINDFLAYER_AURAS or 0)
    data.MINDFLAYER_AURAS = 0
    for _, effect in ipairs(Isaac.FindByType(1000,ToyboxMod.EFFECT_AURA,ToyboxMod.EFFECT_AURA_MINDFLAYER)) do
        effect = effect:ToEffect()

        local dist = effect.Scale*effect.Scale*BASE_AURA_RADIUS*BASE_AURA_RADIUS
        if(effect.Position:DistanceSquared(pl.Position)<=dist) then
            data.MINDFLAYER_AURAS = data.MINDFLAYER_AURAS+1
        end
    end

    if(data.MINDFLAYER_AURAS~=prevAuras) then
        pl:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE, true)
    end
    if(data.MINDFLAYER_AURAS>0) then
        local m = pl.FrameCount%4<2 and 1 or 0.8
        pl:SetColor(Color(m,m,m,1,0,0,0,1.3,0.9,1.5,0.6),1,0,false,true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, checkEnterExitFlayerRadius)

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalFlayerAuraCache(_, pl, flag)
    local auras = ToyboxMod:getEntityData(pl, "MINDFLAYER_AURAS")
    if((auras or 0)<=0) then return end

    if(flag == CacheFlag.CACHE_SPEED) then
        pl.MoveSpeed = pl.MoveSpeed-SPEED_DOWN
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        pl.Damage = pl.Damage*DMG_MULT
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalFlayerAuraCache)

---@param fam EntityFamiliar
local function mindflayerBabyUpdate(_, fam)
    fam:MoveDiagonally(0.7)

    local roomClear = ToyboxMod:isRoomClear()

    local sp = fam:GetSprite()
    if(roomClear) then
        if(sp:GetAnimation()~="Idle") then
            fam:GetSprite():SetAnimation("Idle", false)
        end
    else
        if(sp:GetAnimation()~="IdleActive") then
            fam:GetSprite():SetAnimation("IdleActive", false)
        end
    end

    local desiredAuraScale = (roomClear and CLEAR_AURA_RADIUS or BASE_AURA_RADIUS)

    local aura = ToyboxMod:getEntityData(fam, "MINDFLAYER_AURA")
    if(not (aura and aura:Exists())) then
        if(Game():GetRoom():GetFrameCount()<(desiredAuraScale/fam.Velocity:Length())*0.5+5) then return end
        aura = Isaac.Spawn(1000,ToyboxMod.EFFECT_AURA,ToyboxMod.EFFECT_AURA_MINDFLAYER,fam.Position,Vector.Zero,pl):ToEffect()
        aura.DepthOffset = -1000
        aura:FollowParent(fam)

        aura.Scale = desiredAuraScale/BASE_AURA_RADIUS
        aura.SpriteScale = Vector(1,1)*desiredAuraScale/(2*40)
        aura.Color = Color(1,1,1,1,0,0,0,0,aura.Scale,aura.Position.X/1000, aura.Position.Y/1000)

        aura:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.OVERLAY)
        aura:GetSprite():Play("Appear", true)
        aura:GetSprite():SetCustomShader("shaders_tb/flayer")

        ToyboxMod:setEntityData(fam, "MINDFLAYER_AURA", aura)
    end

    local nextScale = ToyboxMod:lerp(aura.Scale, desiredAuraScale/BASE_AURA_RADIUS, 0.2)
    aura.Scale = nextScale
    aura.SpriteScale = Vector(1,1)*nextScale*BASE_AURA_RADIUS/(2*40)
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mindflayerBabyUpdate, ToyboxMod.FAMILIAR_MINDFLAYER_BABY)

---@param effect EntityEffect
local function auraUpdate(_, effect)
    if(effect.SubType~=ToyboxMod.EFFECT_AURA_MINDFLAYER) then return end

    local sp = effect:GetSprite()
    if(sp:IsFinished("Appear")) then
        sp:Play("Idle", true)
    end

    local alpha = 0.4
    if(sp:GetAnimation()=="Idle") then
        alpha = alpha*(1+0.1*math.sin(math.rad(effect.FrameCount-sp:GetAnimationData("Appear"):GetLength())*15))
    end
    effect.Color = Color(1,1,1,alpha,0,0,0, effect.FrameCount/30, effect.Scale, effect.Position.X/1000, effect.Position.Y/1000)

    if(sp:GetAnimation()=="Idle" and effect.FrameCount%2==0) then
        for _, ent in ipairs(Isaac.FindInRadius(effect.Position, BASE_AURA_RADIUS*effect.Scale, EntityPartition.ENEMY)) do
            if(ToyboxMod:isValidEnemy(ent)) then
                ent:AddWeakness(EntityRef(effect.SpawnerEntity), math.max(0, WEAKNESS_DURATION-ent:GetWeaknessCountdown()))
            end
        end
    end

    if(effect:Exists() and not (effect.Parent and effect.Parent:Exists())) then
        if(sp:GetAnimation()~="Disappear") then
            sp:Play("Disappear")
        end
        if(sp:IsFinished("Disappear")) then
            effect:Remove()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, auraUpdate, ToyboxMod.EFFECT_AURA)