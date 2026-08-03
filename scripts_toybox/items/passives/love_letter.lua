local sfx = SFXManager()

local CHARM_DODGE_COLOR = Color(0.9,0.7,1,1,0.25,0,0.2,1.5,0,1.5,1)

local CHARM_DMGMULT = 0.5
local CHARM_STACKMULT = 0.25

local CHARM_INVINCIBILITY = 60
 
local CHARM_CHANCE = 0.1
local CHARM_STACKCHANCE = 0.05
local CHARM_MAXCHANCE = 0.25

local CHARM_COLOR = Color(0.9,0.7,1,1,0.25,0,0.2,1.5,0,1.5,1)

---@param pl EntityPlayer
---@param params TearParams
local function addCharmFlag(_, pl, params, weap, dmg, tearDisp, source)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_LOVE_LETTER)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_LOVE_LETTER)
    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_LOVE_LETTER)
    local chance = math.min(CHARM_CHANCE+CHARM_STACKCHANCE*(mult-1), CHARM_MAXCHANCE)

    if(rng:RandomFloat()<chance) then
        params.TearFlags = params.TearFlags | TearFlags.TEAR_CHARM
        params.TearColor = params.TearColor*CHARM_COLOR
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, addCharmFlag)


---@param ent Entity
local function postCharmedTakeDMG(_, ent, dmg, flags, source, cooldown)
    if(not (ent:HasEntityFlags(EntityFlag.FLAG_CHARM) and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then return end

    local numLetters = PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_LOVE_LETTER)
    if(numLetters>0) then
        return
        {
            Damage = dmg*(1+CHARM_DMGMULT+(numLetters-1)*CHARM_STACKMULT),
            DamageFlags = flags,
            DamageCountdown = cooldown,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, postCharmedTakeDMG)

---@param p EntityPlayer
---@param source EntityRef
local function playerTakeDMGFromCharm(_, p, dmg, flags, source, cooldown)
    if(not p:HasCollectible(ToyboxMod.COLLECTIBLE_LOVE_LETTER)) then return end

    local dmgSource = source.Entity
    if(not dmgSource) then return end

    if(dmgSource:HasEntityFlags(EntityFlag.FLAG_CHARM) and not dmgSource:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        if(p:GetDamageCooldown()==0) then
            p:SetMinDamageCooldown(CHARM_INVINCIBILITY)
            sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
            p:SetColor(CHARM_DODGE_COLOR,10,2,true,false)
        end

        return false
    end

    dmgSource = dmgSource.SpawnerEntity
    if(dmgSource and dmgSource:HasEntityFlags(EntityFlag.FLAG_CHARM) and not dmgSource:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        if(p:GetDamageCooldown()==0) then
            p:SetMinDamageCooldown(CHARM_INVINCIBILITY)
            sfx:Play(SoundEffect.SOUND_KISS_LIPS1)
            p:SetColor(CHARM_DODGE_COLOR,10,2,true,false)
        end

        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, playerTakeDMGFromCharm)