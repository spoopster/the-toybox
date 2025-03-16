local mod = ToyboxMod
local sfx = SFXManager()

--* needs some polish

local DMG_BONUS = 0.4
local LOSEMANTLE_DMG = 60
local AURA_DMG = 0.5
local BASE_AURA_RADIUS = 80

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not mod:isAtlasA(player)) then return end

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.DARK.ID)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(player, DMG_BONUS*numMantles)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function mantleDestroyed(_, player, mantle)
    if(not mod:isAtlasA(player)) then return end
    if(not (mantle==mod.MANTLE_DATA.DARK.ID or mod:atlasHasTransformation(player, mod.MANTLE_DATA.DARK.ID))) then return end

    for _, enemy in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 1200, EntityPartition.ENEMY)) do
        enemy:TakeDamage(LOSEMANTLE_DMG, 0, EntityRef(player), 30)
    end

    Game():ShakeScreen(20)
    sfx:Play(SoundEffect.SOUND_DEATH_CARD)
    local poof = Isaac.Spawn(1000,16,1,player.Position,Vector.Zero,nil):ToEffect()
    poof.Color = Color(0.1,0.1,0.1,1)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, mantleDestroyed)

local function checkEnterExitDarkRadius(_, pl)
    if(not (mod:isAtlasA(pl) and mod:atlasHasTransformation(pl, mod.MANTLE_DATA.DARK.ID))) then
        local ent = mod:getEntityData(pl, "DARK_AURA")
        if(ent) then
            ent:Die()
            mod:setEntityData(pl, "DARK_AURA", nil)
        end

        return
    end

    local data = mod:getEntityDataTable(pl)
    if(not (data.DARK_AURA and data.DARK_AURA:Exists())) then
        local darkAura = Isaac.Spawn(1000,mod.EFFECT_VARIANT.AURA,mod.EFFECT_AURA_SUBTYPE.DARK_MANTLE,pl.Position,Vector.Zero,pl):ToEffect()
        darkAura.DepthOffset = -1000
        darkAura:FollowParent(pl)

        darkAura:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.OVERLAY)
    
        darkAura.Scale = 1
        darkAura.SpriteScale = Vector(1,1)*darkAura.Scale*BASE_AURA_RADIUS/(2*40)
        darkAura:GetSprite():Play("Appear", true)

        data.DARK_AURA = darkAura
    end

    data.DARK_AURA_ENEMIES = 0
    for _, npc in ipairs(Isaac.FindInRadius(data.DARK_AURA.Position, data.DARK_AURA:ToEffect().Scale*BASE_AURA_RADIUS, EntityPartition.ENEMY)) do
        if(npc:ToNPC() and mod:isValidEnemy(npc:ToNPC())) then
            data.DARK_AURA_ENEMIES = data.DARK_AURA_ENEMIES+1
        end
    end
    if(data.DARK_AURA_ENEMIES~=data.DARK_AURA_ENEMIES_PREV) then
        pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
    end

    data.DARK_AURA_ENEMIES_PREV = data.DARK_AURA_ENEMIES
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, checkEnterExitDarkRadius)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalAuraCache(_, player, flag)
    if(not mod:isAtlasA(player)) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.DARK.ID)) then return end

    local aurasNum = mod:getEntityData(player, "DARK_AURA_ENEMIES") or 0
    if(aurasNum<=0) then return end

    if(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(player, AURA_DMG*aurasNum)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalAuraCache)

---@param effect EntityEffect
local function darkAuraUpdate(_, effect)
    if(effect.SubType~=mod.EFFECT_AURA_SUBTYPE.DARK_MANTLE) then return end

    local sp = effect:GetSprite()
    if(sp:IsFinished("Appear")) then
        sp:Play("Idle", true)
    end

    local alpha = 0.4
    if(sp:GetAnimation()=="Idle") then
        alpha = alpha*(1+0.1*math.sin(math.rad(effect.FrameCount-sp:GetAnimationData("Appear"):GetLength())*6))
    end
    effect.Color = Color(1,1,1,alpha)

    if(effect:Exists() and (effect:IsDead() or not (effect.Parent and effect.Parent:Exists()))) then
        if(sp:GetAnimation()~="Disappear") then
            sp:Play("Disappear")
        end
        if(sp:IsFinished("Disappear")) then
            effect:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, darkAuraUpdate, mod.EFFECT_VARIANT.AURA)