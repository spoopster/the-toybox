local mod = MilcomMOD
local sfx = SFXManager()

local BASE_CHANCE = 1/40
local DMG_MULT = 2

local BULLET_COLOR = Color(0.5,0.5,0.5,1)
BULLET_COLOR:SetColorize(0.25,0.6,0.2,1)

local function getBulletChance(p)
    local m = p:GetTrinketMultiplier(mod.TRINKET.FOAM_BULLET)
    return mod:getLuckAffectedChance(p.Luck, BASE_CHANCE*m, 30, 1/2)
end

local function postFireBulletTear(_, tear)
    local p = tear.SpawnerEntity
    if(p and p:ToPlayer()) then p=p:ToPlayer()
    elseif(p and p:ToFamiliar() and p:ToFamiliar().Player) then p=p:ToFamiliar().Player
    else p=Isaac.GetPlayer() end

    if(p:GetTrinketMultiplier(mod.TRINKET.FOAM_BULLET)>0 and p:GetTrinketRNG(mod.TRINKET.FOAM_BULLET):RandomFloat()<getBulletChance(p)) then
        tear:ChangeVariant(mod.TEAR_VARIANT.BULLET)

        tear.CollisionDamage = tear.CollisionDamage*DMG_MULT
        tear.SpriteScale = tear.SpriteScale*(1/tear.Scale)

        sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
        sfx:Play(mod.SOUND_EFFECT.BULLET_FIRE, 0.3)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, postFireBulletTear)

local function postFireBulletBomb(_, bomb)
    local p = bomb.SpawnerEntity
    if(p and p:ToPlayer()) then p=p:ToPlayer()
    elseif(p and p:ToFamiliar() and p:ToFamiliar().Player) then p=p:ToFamiliar().Player
    else p=Isaac.GetPlayer() end

    if(p:GetTrinketMultiplier(mod.TRINKET.FOAM_BULLET)>0 and p:GetTrinketRNG(mod.TRINKET.FOAM_BULLET):RandomFloat()<getBulletChance(p)) then
        bomb.ExplosionDamage = bomb.ExplosionDamage*DMG_MULT
        sfx:Play(SoundEffect.SOUND_PLOP, 0.2, 0, false, 1)
        sfx:Play(mod.SOUND_EFFECT.BULLET_HIT, 1, 0, false, 1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, postFireBulletBomb)

---@param source EntityRef
local function postDealBulletDamage(_, ent, amount, flags, source, frames)
    local p = source.Entity
    if(p and p:ToPlayer()) then p=p:ToPlayer()
    elseif(p and p.SpawnerEntity) then
        p=p.SpawnerEntity
        if(p and p:ToPlayer()) then p=p:ToPlayer()
        elseif(p and p:ToFamiliar() and p:ToFamiliar().Player and mod:isTearCopyingFamiliar(p:ToFamiliar())) then
            p=p:ToFamiliar().Player
        else p=nil end
    else p=nil end
    if(p==nil) then return end

    local s = source.Entity

    if(p and p:GetTrinketMultiplier(mod.TRINKET.FOAM_BULLET)>0 and p:GetTrinketRNG(mod.TRINKET.FOAM_BULLET):RandomFloat()<getBulletChance(p)) then
        local triggerEffect = false

        --print(s.Type, s.Variant, s.SubType, flags)

        local validKnifeSubtypes = {
            [KnifeVariant.MOMS_KNIFE]=true,
            [KnifeVariant.BONE_CLUB]=true,
            [KnifeVariant.BONE_SCYTHE]=true,
            [KnifeVariant.SUMPTORIUM]=true,
            [KnifeVariant.BERSERK_CLUB]=true,
        }

        if( (s and mod:getEntityData(s, "HAS_FOAM_BULLET_EFFECT")==true)
        or  (s.Type==EntityType.ENTITY_PLAYER) -- ALL MISC PLAYER DMG (Aries, bone club/spirit sword, moms heels)
        --or  (s.Type==EntityType.ENTITY_PLAYER and flags & DamageFlag.DAMAGE_LASER ~= 0)  --LASER
        or  (s and s.Type==EntityType.ENTITY_KNIFE and validKnifeSubtypes[s.Variant])  --KNIFE
        or  (s and s.Type==EntityType.ENTITY_EFFECT and s.Variant==EffectVariant.DARK_SNARE) --DARK ARTS
        )then
            triggerEffect=true
        end

        if(triggerEffect) then
            sfx:Play(SoundEffect.SOUND_PLOP, 0.2, 0, false, 1)
            sfx:Play(mod.SOUND_EFFECT.BULLET_HIT, 1, 0, false, 1)
            return {
                Damage = amount*DMG_MULT,
                DamageFlags = flags,
                DamageCountdown = frames,
            }
        end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, postDealBulletDamage)

local function postSpawnBulletAquariusCreep(_, effect)
    if(not (effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer())) then return end
    local p = effect.SpawnerEntity:ToPlayer()

    if(p and p:GetTrinketMultiplier(mod.TRINKET.FOAM_BULLET)>0 and p:GetTrinketRNG(mod.TRINKET.FOAM_BULLET):RandomFloat()<getBulletChance(p)) then
        mod:setEntityData(effect, "HAS_FOAM_BULLET_EFFECT", true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postSpawnBulletAquariusCreep, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)

local function postSpawnBulletRocket(_, effect)
    if(effect.FrameCount~=1) then return end

    local p = effect.SpawnerEntity
    if(p and p:ToPlayer()) then p=p:ToPlayer()
    elseif(p and p.SpawnerEntity) then
        p=p.SpawnerEntity
        if(p and p:ToPlayer()) then p=p:ToPlayer()
        elseif(p and p:ToFamiliar() and p:ToFamiliar().Player and mod:isTearCopyingFamiliar(p:ToFamiliar())) then
            p=p:ToFamiliar().Player
        else p=nil end
    else p=nil end
    if(p==nil) then return end

    if(effect.Parent and effect.Parent.Type==EntityType.ENTITY_EFFECT and effect.Parent.Variant==EffectVariant.TARGET) then
        if(p and p:GetTrinketMultiplier(mod.TRINKET.FOAM_BULLET)>0 and p:GetTrinketRNG(mod.TRINKET.FOAM_BULLET):RandomFloat()<getBulletChance(p)) then
            mod:setEntityData(effect, "HAS_FOAM_BULLET_EFFECT", true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postSpawnBulletRocket, EffectVariant.ROCKET)

local function postTrinketInit(_, pickup)
    if(not mod:trinketIsTrinketType(pickup, mod.TRINKET.FOAM_BULLET)) then return end

    pickup.SpriteOffset = pickup.SpriteOffset+Vector(0,5)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postTrinketInit, PickupVariant.PICKUP_TRINKET)