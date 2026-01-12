local sfx = SFXManager()

local STAR_SPEED = 0.25
local STAR_MINDIST = 40*4

local TAROTCLOTH_SCALEMULT = 1.5

---@param pl EntityPlayer
local function useTheWiseMen(_, _, pl, flags)
    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isRoomClear()) then
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(pl.Position, 40)
        local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, pos, Vector.Zero, nil):ToPickup()
    
        --sfx:Play(ToyboxMod.SFX_STAR_TRANSFORM, 1, 2, false, 0.95+math.random()*0.1)
        sfx:Play(ToyboxMod.SFX_STAR_SPAWN, 1, 2, false, 0.95+math.random()*0.1+0.5)
    else
        local desired = ((flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) and 1 or 0)
        local star = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_WISE_MEN_STAR, desired, pl.Position, Vector.Zero, pl):ToFamiliar()
    
        sfx:Play(ToyboxMod.SFX_STAR_SPAWN, 1, 2, false, 0.95+math.random()*0.1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useTheWiseMen, ToyboxMod.CARD_THE_WISE_MEN)

local function removeEffect(_)
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_WISE_MEN_STAR)) do
        ent:Remove()
    end
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, EffectVariant.HALLOWED_GROUND)) do
        if(ent.Parent and ent.Parent.Type==EntityType.ENTITY_FAMILIAR and ent.Parent.Variant==ToyboxMod.FAMILIAR_WISE_MEN_STAR) then
            ent:Remove()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, removeEffect)

---@param fam EntityFamiliar
local function pickRandomPos(fam)
    local room = Game():GetRoom()
    local pos = nil

    while(not (pos and pos:Distance(fam.Position)>=STAR_MINDIST and fam:GetPathFinder():HasPathToPos(pos, false))) do
        pos = room:GetGridPosition(room:GetGridIndex(room:GetRandomPosition(40)))
    end

    return pos
end

---@param fam EntityFamiliar
local function initStar(_, fam)
    fam:GetSprite():Play("Float", true)
    --fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    
    fam.Player = (fam.SpawnerEntity and fam.SpawnerEntity:ToPlayer() or fam.Player)
    fam.Position= fam.Player.Position
    fam.TargetPosition = pickRandomPos(fam)

    local aura = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, fam.Position, fam.Velocity, fam):ToEffect()
    aura:FollowParent(fam)
    aura.SpriteOffset = Vector(0,-12)
    if(fam.SubType==1) then
        aura.Scale = aura.Scale*TAROTCLOTH_SCALEMULT
        aura.SpriteScale = aura.SpriteScale*TAROTCLOTH_SCALEMULT
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, initStar, ToyboxMod.FAMILIAR_WISE_MEN_STAR)

---@param fam EntityFamiliar
local function updateStar(_, fam)
    fam:GetPathFinder():FindGridPath(fam.TargetPosition, STAR_SPEED, 0, false)
    if(fam.Position:Distance(fam.TargetPosition)<10) then
        fam.TargetPosition = pickRandomPos(fam)
    end

    if(ToyboxMod:isRoomClear()) then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 1, fam.Position, Vector.Zero, nil):ToEffect()
        poof.SpriteOffset = Vector(0,-24)
        poof.Color = Color(1,1,1.3,1,0.1,0.35,0.4)

        local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, fam.Position, Vector.Zero, nil):ToPickup()
        heart:GetSprite():SetFrame(6)
        
        fam:Remove()

        sfx:Play(ToyboxMod.SFX_STAR_SPAWN, 1, 2, false, 0.95+math.random()*0.1+0.5)
    end

    return true
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_UPDATE, updateStar, ToyboxMod.FAMILIAR_WISE_MEN_STAR)

local function getAuraValues(pl)
    local numaura = 0
    local numaurawise = 0
    for _, eff in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
        if(eff.Position:Distance(pl.Position)< 70*eff:ToEffect().Scale + pl.Size) then
            local effp = eff.Parent
            if(effp and effp.Type==EntityType.ENTITY_FAMILIAR) then
                if(effp.Variant==FamiliarVariant.STAR_OF_BETHLEHEM) then
                    numaura = numaura+1
                elseif(effp.Variant==ToyboxMod.FAMILIAR_WISE_MEN_STAR) then
                    numaura = numaura+1
                    numaurawise = numaurawise+1
                end
            end
        end
    end

    return numaurawise, numaura
end

---@param pl EntityPlayer
local function updateAuraStats(_, pl)
    local auraw, _ = getAuraValues(pl)
    if(auraw~=(ToyboxMod:getEntityData(pl, "WISE_AURA_COUNT") or 0)) then
        pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG | CacheFlag.CACHE_TEARCOLOR, true)
        ToyboxMod:setEntityData(pl, "WISE_AURA_COUNT", auraw)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, updateAuraStats)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalAuraCache(_, player, flag)
    local auraw, aura = getAuraValues(player)
    if(auraw<aura or auraw==0) then return end

    if(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*1.2
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = ToyboxMod:toFireDelay(2.5*ToyboxMod:toTps(player.MaxFireDelay))
    elseif(flag==CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING
    elseif(flag==CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = Color(1.5,2,2,1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalAuraCache)

---@param ent Entity
local function tryCancelDamage(_, ent)
    local auraw, aura = getAuraValues(ent)
    if(auraw<aura or auraw==0) then return end

    local pl = ent:ToPlayer()
    pl:SetColor(Color(1,1,1,1,0.25,0.25,0.5,0,0,0,0), 15, 0, true, false)
    pl:SetMinDamageCooldown(7)
    pl:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK)

    return false
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, tryCancelDamage, EntityType.ENTITY_PLAYER)