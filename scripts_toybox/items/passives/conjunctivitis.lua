
---Finish tomorrow or remove it idk

local PUSSY_COLOR = Color()
PUSSY_COLOR:SetColorize(1,1,0.6,1)
PUSSY_COLOR:SetOffset(0.1,0.1,0)

local DMG_UP = 0.5
local POISON_CHANCE = 0.25
local SPEED_UP = -0.2
local SCALE_UP = 0.1

local BOMB_DMG_UP = DMG_UP*10

---@param pl EntityPlayer
---@param isTears boolean
local function canFireRightEye(pl, isTears)
    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS)

    if(not isTears or pl:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) or pl:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)) then
        return (rng:RandomInt(2)==0)
    end

    if(pl:GetTearDisplacement()==1) then
        return true
    end

    if(pl:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) or pl:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION)) then
        return (rng:RandomInt(2)==0)
    end

    return false
end

---@param tear EntityTear
local function fireTear(_, tear)
    local pl = ToyboxMod:getPlayerFromEnt(tear) ---@type EntityPlayer
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS))) then return end
    
    if(canFireRightEye(pl, (tear.SpawnerEntity:ToPlayer()~=nil))) then
        tear.Color = PUSSY_COLOR
        tear.CollisionDamage = tear.CollisionDamage+DMG_UP
        tear.Velocity = tear.Velocity*(1+SPEED_UP)
        tear.Scale = tear.Scale*(1+SCALE_UP)

        if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS):RandomFloat()<POISON_CHANCE) then
            tear:AddTearFlags(TearFlags.TEAR_POISON)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, fireTear)

---@param tear EntityTear
local function checkLudoTear(_, tear)
    if(not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO)) then return end

    local pl = ToyboxMod:getPlayerFromEnt(tear) ---@type EntityPlayer
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS))) then return end

    if(tear.FrameCount//pl.MaxFireDelay ~= (tear.FrameCount-1)//pl.MaxFireDelay) then
        if(canFireRightEye(pl, (tear.SpawnerEntity:ToPlayer()~=nil))) then
            tear.Color = PUSSY_COLOR
            tear.CollisionDamage = tear.CollisionDamage+DMG_UP
            if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS):RandomFloat()<POISON_CHANCE) then
                tear:AddTearFlags(TearFlags.TEAR_POISON)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, checkLudoTear)

---@param ent Entity
---@param dmg number
---@param flags DamageFlag
---@param source EntityRef
local function onLaserKnifeHit(_, ent, dmg, flags, source, frames)
    if(not (flags & DamageFlag.DAMAGE_CLONES == 0 and ent:ToNPC() and source)) then return end

    local pl = nil
    if(source.Type==EntityType.ENTITY_PLAYER and (flags & DamageFlag.DAMAGE_LASER ~= 0)) then
        pl = source.Entity:ToPlayer()
    elseif(source.Type==EntityType.ENTITY_KNIFE and (source.Variant==KnifeVariant.MOMS_KNIFE or source.Variant==KnifeVariant.SUMPTORIUM)) then
        pl = ToyboxMod:getPlayerFromEnt(source.Entity)
    end

    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS))) then return end

    if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS):RandomFloat()<POISON_CHANCE) then
        ent:AddPoison(EntityRef(nil), 23, ToyboxMod:lerp(dmg, 3.5, 0.5))
    end

    return {
        Damage = dmg+DMG_UP,
        DamageFlags = flags,
        DamageCountdown = frames,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onLaserKnifeHit)

---@param bomb EntityBomb
local function onFireBomb(_, bomb)
    local pl = ToyboxMod:getPlayerFromEnt(bomb)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS))) then return end
    
    if(canFireRightEye(pl, false)) then
        bomb.Color = PUSSY_COLOR
        bomb.ExplosionDamage = bomb.ExplosionDamage+BOMB_DMG_UP
        --bomb.Velocity = bomb.Velocity*(1+SPEED_UP)
        
        if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CONJUNCTIVITIS):RandomFloat()<POISON_CHANCE) then
            bomb:AddTearFlags(TearFlags.TEAR_POISON)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, onFireBomb)