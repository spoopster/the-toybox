local mod = MilcomMOD
local sfx = SFXManager()

local VIRUS_LIFESPAN = 30*40
local LIFESPAN_MULT = 0.5

local ORBIT_DIST = Vector(45,30)
local ORBIT_SPEED = 0.02
local ORBIT_LAYER = 1004

local BASE_FIRERATE = 20
local BASE_DMG = 4
local BASE_VEL = 13
local VIRUS_INFO = {
    [mod.FAMILIAR_VIRUS_SUBTYPE.RED] = {
        DMGMULT = 0.5, TEARSMULT = 1,
        COLOR = Color(1.25,0.75,0.5,1, 0.2,0.05,0, 2,1,0,1),
        FLAGS = {
            {TearFlags.TEAR_BURN, 0.5},
        }
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.YELLOW_1] = {
        DMGMULT = 1.5, TEARSMULT = 1,
        COLOR = Color(0.75,0.75,0.5,1, 0.12,0.12,0, 1,1,0,1),
        SPREAD = 15,
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.BLUE] = {
        DMGMULT = 1, TEARSMULT = 1,
        COLOR = Color(2,2,3,1, 0,0,0.15, 0.25,0.25,1,1),
        FLAGS = {
            {TearFlags.TEAR_ICE, 0.5},
        }
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.MAGENTA] = {
        DMGMULT = 1.5, TEARSMULT = 0.75,
        COLOR = Color(2,1,2,1, 0.15,0,0.15, 2,0.25,2,1),
        FLAGS = {
            {TearFlags.TEAR_CONFUSION, 0.2},
        }
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.YELLOW_2] = {
        DMGMULT = 0.5, TEARSMULT = 2,
        RANGEMULT = 1.5, SHOTSPEEDMULT = 0.66,
        COLOR = Color(0.75,0.75,0.5,1, 0.2,0.2,0, 1,1,0,1),
        FLAGS = {
            {TearFlags.TEAR_FREEZE, 0.15},
        }
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.CYAN] = {
        DMGMULT = 0.75, TEARSMULT = 1,
        COLOR = Color(1,2,2,1, 0,0,0, 0.25,1,1,1),
        FLAGS = {
            {TearFlags.TEAR_SLOW, 0.2},
            {TearFlags.TEAR_WIGGLE, 1},
        }
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.GREEN] = {
        DMGMULT = 1.5, TEARSMULT = 0.33,
        COLOR = Color(0,3,2,1, 0,0.15,0, 0.25,1,0.25,1),
        FLAGS = {
            {TearFlags.TEAR_POISON, 0.5},
        }
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.LIGHT_BLUE] = {
        DMGMULT = 0.15, TEARSMULT = 6,
        SPREAD = 5,
        FLAGS = {
            {TearFlags.TEAR_LIGHT_FROM_HEAVEN, 0.025},
        }
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.PINK] = {
        DMGMULT = 1, TEARSMULT = 1,
        COLOR = Color(2,0.5,2,1, 0.15,0,0.15, 2,0.25,2,1),
        FLAGS = {
            {TearFlags.TEAR_CHARM, 0.2},
        }
    },
    [mod.FAMILIAR_VIRUS_SUBTYPE.PURPLE] = {
        DMGMULT = 1.25, TEARSMULT = 0.66,
        COLOR = Color(1.5,0.5,2.5,1, 0.1,0,0.2, 1.5,0.25,3,1),
        FLAGS = {
            {TearFlags.TEAR_HOMING, 1},
        }
    },
}

local PILL_PICKER = WeightedOutcomePicker()
    PILL_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.RED, 1)
    PILL_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.YELLOW_1, 1)
    PILL_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.BLUE, 1)
local CARD_PICKER = WeightedOutcomePicker()
    CARD_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.MAGENTA, 1)
    CARD_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.YELLOW_2, 1)
    CARD_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.CYAN, 1)
local RUNE_PICKER = WeightedOutcomePicker()
    RUNE_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.GREEN, 1)
    RUNE_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.LIGHT_BLUE, 1)
    RUNE_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.PINK, 1)
    RUNE_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.PURPLE, 1)
local OBJECT_PICKER = WeightedOutcomePicker()
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.RED, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.YELLOW_1, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.BLUE, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.MAGENTA, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.YELLOW_2, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.CYAN, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.GREEN, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.LIGHT_BLUE, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.PINK, 1)
    OBJECT_PICKER:AddOutcomeWeight(mod.FAMILIAR_VIRUS_SUBTYPE.PURPLE, 1)

---@param player EntityPlayer
function mod:addVirus(player, var, num)
    local data = mod:getEntityDataTable(player)
    data.GIANT_CAPSULE_VIRUSCOUNT = data.GIANT_CAPSULE_VIRUSCOUNT or {}
    data.GIANT_CAPSULE_VIRUSCOUNT[var] = (data.GIANT_CAPSULE_VIRUSCOUNT[var] or 0)+num
    data.GIANT_CAPSULE_VIRUSCOUNT[var] = math.max(data.GIANT_CAPSULE_VIRUSCOUNT[var], 0)

    if(num>0) then
        sfx:Play(mod.SFX_VIRUS_SPAWN)
    end
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local rng = player:GetPillRNG(effect)
    for _=1, player:GetCollectibleNum(mod.COLLECTIBLE_GIANT_CAPSULE) do
        local st = PILL_PICKER:PickOutcome(rng)
        mod:addVirus(player, st, 1)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill)

---@param player EntityPlayer
local function useCard(_, card, player, flags)
    local itemConf = Isaac.GetItemConfig():GetCard(card)
    local isRune = itemConf:IsRune()
    local isObj = not (itemConf:IsCard() or itemConf:IsRune())

    local rng = player:GetCardRNG(card)
    for _=1, player:GetCollectibleNum(mod.COLLECTIBLE_GIANT_CAPSULE) do
        local st = ((isObj and OBJECT_PICKER) or (isRune and RUNE_PICKER) or CARD_PICKER):PickOutcome(rng)
        mod:addVirus(player, st, 1)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useCard)

---@param player EntityPlayer
local function evalViruses(_, player)
    local data = mod:getEntityDataTable(player)

    for st, val in pairs(data.GIANT_CAPSULE_VIRUSCOUNT or {}) do
        player:CheckFamiliar(
            mod.FAMILIAR_VIRUS,
            val,
            player:GetCollectibleRNG(mod.COLLECTIBLE_GIANT_CAPSULE),
            Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_GIANT_CAPSULE),
            st
        )

        if(val and val<=0) then data.GIANT_CAPSULE_VIRUSCOUNT[st] = nil end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalViruses, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
local function virusInit(_, familiar)
    local sprite = familiar:GetSprite()
    sprite:Play("Float", true)

    familiar:RemoveFromFollowers()
    familiar:RemoveFromDelayed()
    familiar:AddToOrbit(ORBIT_LAYER)

    if(familiar.Hearts==0) then
        familiar.Hearts = VIRUS_LIFESPAN*(1+LIFESPAN_MULT*math.max(0, (familiar.Player:GetCollectibleNum(mod.COLLECTIBLE_GIANT_CAPSULE)-1)))
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, virusInit, mod.FAMILIAR_VIRUS)

---@param familiar EntityFamiliar
local function virusUpdate(_, familiar)
    if(familiar.Hearts<0) then return end

    local sp = familiar:GetSprite()
    local rng = familiar:GetDropRNG()
    local pl = familiar.Player

    -- ORBIT LOGIC
    familiar.OrbitDistance = ORBIT_DIST
    familiar.OrbitSpeed = ORBIT_SPEED
    familiar.Velocity = mod:lerp(familiar.Velocity, (familiar:GetOrbitPosition(pl.Position+pl.Velocity)-familiar.Position), 0.5)

    -- FIRE LOGIC
    local virusData = VIRUS_INFO[familiar.SubType] or VIRUS_INFO[0]
    local fireCool = math.floor(BASE_FIRERATE/(virusData.TEARSMULT or 1))

    if(familiar.FireCooldown<=0) then
        if(mod:isPlayerShooting(pl)) then
            local dir = math.floor((pl:GetShootingInput():GetAngleDegrees()+225)%360/90)
            local fireVec = Isaac.GetAxisAlignedUnitVectorFromDir(dir)

            if(virusData.SPREAD) then
                fireVec = fireVec:Rotated((rng:RandomFloat()*2-1)*virusData.SPREAD)
            end

            sp:SetAnimation("FloatShoot", false)
            local tear = familiar:FireProjectile(fireVec)
            tear.CollisionDamage = BASE_DMG*(virusData.DMGMULT or 1)
            tear.Velocity:Resize(BASE_VEL*(virusData.SHOTSPEEDMULT or 1))
            if(virusData.COLOR) then
                tear.Color = virusData.COLOR
            end
            for _, flagData in pairs(virusData.FLAGS or {}) do
                if(rng:RandomFloat()<(flagData[2] or 1)) then
                    tear:AddTearFlags(flagData[1])
                end
            end
            tear:Update()
            sfx:Play(mod.SFX_VIRUS_SHOOT, 0.5, 1, false, 0.95+rng:RandomFloat()*0.1, 0)

            familiar.FireCooldown = fireCool
        end
    else
        familiar.FireCooldown = familiar.FireCooldown-(pl:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2 or 1)
        familiar.FireCooldown = math.max(familiar.FireCooldown, 0)

        if(sp:GetAnimation()=="FloatShoot" and familiar.FireCooldown<=fireCool/2) then
            sp:SetAnimation("Float", false)
        end
    end
    
    familiar.Hearts = familiar.Hearts-1
    if(familiar.Hearts==0) then
        local data = mod:getEntityDataTable(pl)
        data.GIANT_CAPSULE_VIRUSCOUNT = data.GIANT_CAPSULE_VIRUSCOUNT or {}

        data.GIANT_CAPSULE_VIRUSCOUNT[familiar.SubType] = (data.GIANT_CAPSULE_VIRUSCOUNT[familiar.SubType] or 1)-1

        familiar.Hearts = -1
        familiar:Remove()
        familiar:Update()

        local imp = Isaac.Spawn(1000, EffectVariant.IMPACT, 0, familiar.Position, Vector.Zero, familiar):ToEffect()
        imp.SpriteOffset = Vector(0, -15)

        local col = (VIRUS_INFO[familiar.SubType] or VIRUS_INFO[0]).COLOR
        imp.Color = col or imp.Color
        sfx:Play(mod.SFX_VIRUS_DIE)

        pl:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, virusUpdate, mod.FAMILIAR_VIRUS)
--im bored

