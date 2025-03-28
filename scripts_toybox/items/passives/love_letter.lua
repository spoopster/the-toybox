local mod = ToyboxMod
local sfx = SFXManager()

local CHARM_CHANCE = 0.1
local CHARM_STACKCHANCE = 0.05
local CHARM_MAXCHANCE = 0.25

local CHARM_DURATION = 5*30
local CHARM_COLOR = Color(0.9,0.7,1,1,0.25,0,0.2,1.5,0,1.5,1)
--local 

local CHARM_DMGMULT = 0.33
local CHARM_STACKMULT = 0.16

local CHARM_INVINCIBILITY = 60

---@param ent Entity
local function postCharmedTakeDMG(_, ent, dmg, flags, source, cooldown)
    if(not (ent:HasEntityFlags(EntityFlag.FLAG_CHARM) and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then return end

    local numLetters = PlayerManager.GetNumCollectibles(mod.COLLECTIBLE.LOVE_LETTER)
    if(numLetters>0) then
        return
        {
            Damage = dmg*(1+CHARM_DMGMULT+(numLetters-1)*CHARM_STACKMULT),
            DamageFlags = flags,
            DamageCountdown = cooldown,
        }
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, postCharmedTakeDMG)

---@param p EntityPlayer
---@param source EntityRef
local function playerTakeDMGFromCharm(_, p, dmg, flags, source, cooldown)
    if(not p:HasCollectible(mod.COLLECTIBLE.LOVE_LETTER)) then return end

    local dmgSource = source.Entity
    if(not dmgSource) then return end

    if(dmgSource:HasEntityFlags(EntityFlag.FLAG_CHARM) and not dmgSource:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        if(p:GetDamageCooldown()==0) then
            p:SetMinDamageCooldown(CHARM_INVINCIBILITY)
            sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
            p:SetColor(CHARM_COLOR,10,2,true,false)
        end

        return false
    end

    dmgSource = dmgSource.SpawnerEntity
    if(dmgSource and dmgSource:HasEntityFlags(EntityFlag.FLAG_CHARM) and not dmgSource:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        if(p:GetDamageCooldown()==0) then
            p:SetMinDamageCooldown(CHARM_INVINCIBILITY)
            sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
            p:SetColor(CHARM_COLOR,10,2,true,false)
        end

        return false
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, playerTakeDMGFromCharm)



---@param player EntityPlayer
local function getTriggerChance(player, chancemult)
    local itemNum = player:GetCollectibleNum(mod.COLLECTIBLE.LOVE_LETTER)
    if(itemNum==0) then return 0 end
    return chancemult*math.min(CHARM_MAXCHANCE, CHARM_CHANCE+(itemNum-1)*CHARM_STACKCHANCE)
end

---@param ent Entity
local function applyLetterCharm(_, ent, amount, flags, ref, frames)
    if(not (ref.Entity and mod:getEntityData(ref.Entity, "LOVELETTER_CHARM"))) then return end

    ent:AddCharmed(ref, math.max(0, CHARM_DURATION-ent:GetCharmedCountdown()))
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, applyLetterCharm)

---@param tear EntityTear
---@param player EntityPlayer
local function letterFireTear(_, tear, player, isLudo)
    if(not player:HasCollectible(mod.COLLECTIBLE.LOVE_LETTER)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE.LOVE_LETTER)

    if(rng:RandomFloat()>=getTriggerChance(player, (isLudo and 0.75 or 1))) then return end

    tear.Color = CHARM_COLOR
    tear:AddTearFlags(TearFlags.TEAR_CHARM)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, letterFireTear)

---@param bomb EntityBomb
---@param player EntityPlayer
local function letterFireBomb(_, bomb, player)
    if(not player:HasCollectible(mod.COLLECTIBLE.LOVE_LETTER)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE.LOVE_LETTER)

    if(rng:RandomFloat()>=getTriggerChance(player, 1.5)) then return end

    bomb.Color = CHARM_COLOR
    bomb:AddTearFlags(TearFlags.TEAR_CHARM)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, letterFireBomb)

---@param rocket EntityEffect
---@param player EntityPlayer
local function letterFireRocket(_, rocket, player)
    if(not player:HasCollectible(mod.COLLECTIBLE.LOVE_LETTER)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE.LOVE_LETTER)

    if(rng:RandomFloat()>=getTriggerChance(player, 1.5)) then return end

    mod:setEntityData(rocket, "LOVELETTER_CHARM", true)
    mod:setEntityData(rocket, "EXPLOSION_COLOR", CHARM_COLOR)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_ROCKET, letterFireRocket)
---@param rocket EntityEffect
---@param target EntityEffect
local function letterCopyTargetData(_, rocket, target)
    mod:setEntityData(rocket, "LOVELETTER_CHARM", mod:getEntityData(target, "LOVELETTER_CHARM"))
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.ROCKET_COPY_TARGET_DATA, letterCopyTargetData)

---@param player EntityPlayer
---@param ent Entity
local function laserKnifeDamage(_, dmgtype, player, ent)
    if(not (dmgtype==mod.DAMAGE_TYPE.LASER or dmgtype==mod.DAMAGE_TYPE.KNIFE)) then return end

    if(not player:HasCollectible(mod.COLLECTIBLE.LOVE_LETTER)) then return end
    local rng = player:GetCollectibleRNG(mod.COLLECTIBLE.LOVE_LETTER)
    if(rng:RandomFloat()>=getTriggerChance(player, 0.8)) then return end

    ent:AddCharmed(EntityRef(player), CHARM_DURATION)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_EXTRA_DMG, laserKnifeDamage)