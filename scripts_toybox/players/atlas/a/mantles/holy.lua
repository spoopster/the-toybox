
local sfx = SFXManager()

local SACRED_CHANCE = 1/30
local RANGE_UP = 0.5

local AURA_SIZE_POW = 7
local AURA_DMG = 2
local AURA_FREQ = 6

local BASE_AURA_RADIUS = 60

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not ToyboxMod:isAtlasA(player)) then return end

    local numMantles = ToyboxMod:getNumMantlesByType(player, ToyboxMod.MANTLE_DATA.HOLY.ID)

    if(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+RANGE_UP*numMantles*40
    end
    if(ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.HOLY.ID)) then
        if(flag==CacheFlag.CACHE_FLYING) then
            player.CanFly = true
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function makeHolyAura(_, pl)
    if(not (ToyboxMod:isAtlasA(pl) and ToyboxMod:atlasHasTransformation(pl, ToyboxMod.MANTLE_DATA.HOLY.ID))) then
        local ent = ToyboxMod:getEntityData(pl, "HOLY_AURA")
        if(ent) then
            ent:Die()
            ToyboxMod:setEntityData(pl, "HOLY_AURA", nil)
        end

        return
    end

    local data = ToyboxMod:getEntityDataTable(pl)
    if(not (data.HOLY_AURA and data.HOLY_AURA:Exists())) then
        local aura = Isaac.Spawn(1000,ToyboxMod.EFFECT_VARIANT.AURA,ToyboxMod.EFFECT_AURA_SUBTYPE.HOLY_MANTLE,pl.Position,Vector.Zero,pl):ToEffect()
        aura.DepthOffset = -1000
        aura:FollowParent(pl)
    
        aura.Scale = 1
        aura.SpriteScale = Vector(1,1)*aura.Scale*BASE_AURA_RADIUS/(2*40)
        aura:GetSprite():Play("Appear", true)

        data.HOLY_AURA = aura
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, makeHolyAura)

---@param effect EntityEffect
local function holyAuraUpdate(_, effect)
    if(effect.SubType~=ToyboxMod.EFFECT_AURA_SUBTYPE.HOLY_MANTLE) then return end

    if(effect.FrameCount%AURA_FREQ==0) then
        for _, npc in ipairs(Isaac.FindInRadius(effect.Position, effect.Scale*BASE_AURA_RADIUS, EntityPartition.ENEMY)) do
            if(npc:ToNPC() and ToyboxMod:isValidEnemy(npc:ToNPC())) then
                npc:TakeDamage(AURA_DMG, 0, EntityRef(effect.Parent), 3)
            end
        end
    end

    local sp = effect:GetSprite()
    if(sp:IsFinished("Appear")) then
        sp:Play("Idle", true)
    end

    local alpha = 0.2
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
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, holyAuraUpdate, ToyboxMod.EFFECT_VARIANT.AURA)

--ADDING THE HOMING TEARFLAG + DMG BONUS ON DIFFERENT WEAPONS
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and ToyboxMod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    local chance = SACRED_CHANCE*ToyboxMod:getNumMantlesByType(p, ToyboxMod.MANTLE_DATA.HOLY.ID)
    if(e:GetDropRNG():RandomFloat()<chance) then
        e:AddTearFlags(TearFlags.TEAR_HOMING)
        e.CollisionDamage = e.CollisionDamage*2
    end
end
)

ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and ToyboxMod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    local chance = SACRED_CHANCE*ToyboxMod:getNumMantlesByType(p, ToyboxMod.MANTLE_DATA.HOLY.ID)
    if(e:GetDropRNG():RandomFloat()<chance) then
        e:AddTearFlags(TearFlags.TEAR_HOMING)
        e.ExplosionDamage = e.ExplosionDamage*2
    end
end
)

ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and ToyboxMod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    local chance = SACRED_CHANCE*ToyboxMod:getNumMantlesByType(p, ToyboxMod.MANTLE_DATA.HOLY.ID)
    if(e:GetDropRNG():RandomFloat()<chance) then
        e:AddTearFlags(TearFlags.TEAR_HOMING)
        e.CollisionDamage = e.CollisionDamage*2
    end
end
)

ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and ToyboxMod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    local chance = SACRED_CHANCE*ToyboxMod:getNumMantlesByType(p, ToyboxMod.MANTLE_DATA.HOLY.ID)
    if(e:GetDropRNG():RandomFloat()<chance) then
        e:AddTearFlags(TearFlags.TEAR_HOMING)
        e.CollisionDamage = e.CollisionDamage*2
    end
end
)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(not ToyboxMod:isAtlasA(player)) then return end

    sfx:Play(ToyboxMod.SOUND_EFFECT.ATLASA_ROCKBREAK)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, playMantleSFX, ToyboxMod.MANTLE_DATA.HOLY.ID)