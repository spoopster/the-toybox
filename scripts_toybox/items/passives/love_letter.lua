
local sfx = SFXManager()



local CHARM_CHANCE = 0.1
local CHARM_STACKCHANCE = 0.05
local CHARM_MAXCHANCE = 0.25

local CHARM_DURATION = 5*30
local CHARM_COLOR = Color(0.9,0.7,1,1,0.25,0,0.2,1.5,0,1.5,1)
--local 

local CHARM_DMGMULT = 0.5
local CHARM_STACKMULT = 0.25

local CHARM_INVINCIBILITY = 60

ToyboxMod:addTearFlagEnum(
    "LOVELETTER_CHARM",
    ---@param npc EntityNPC
    ---@param source Entity
    function(npc, flag, source, pos, dmg, key)
        npc:AddCharmed(EntityRef(ToyboxMod:getPlayerFromEnt(source)), math.max(0, CHARM_DURATION-npc:GetCharmedCountdown()))
    end,
    nil,
    CHARM_COLOR
)

---@param pl EntityPlayer
local function giveTearflag(_, pl, _)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_LOVE_LETTER)) then return end

    ToyboxMod:addTearFlag(
        pl,
        "LOVELETTER_CHARM",
        function(player)
            return math.min(CHARM_MAXCHANCE, CHARM_CHANCE+player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_LOVE_LETTER)*CHARM_STACKCHANCE)
        end,
        ToyboxMod.COLLECTIBLE_LOVE_LETTER
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, giveTearflag, CacheFlag.CACHE_TEARFLAG)

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
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, playerTakeDMGFromCharm)