local sfx = SFXManager()

local FIRE_FREQ = 10
local FIRE_TEARS_MIN = 2
local FIRE_TEARS_MAX = 5
local FIRE_TEARS_ARC = 14

local FIRE_SPREAD_RADIUS = 20
local FIRE_SPREAD_SIZEMULT = 1.5

---@param dir Vector
---@param amount number
---@param owner Entity
---@param weapon Weapon
local function postTriggerWeaponFired(_, dir, amount, owner, weapon)
    local pl = ToyboxMod:getPlayerFromEnt(owner)
    if(not pl) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    if(GetPtrHash(pl)==GetPtrHash(owner)) then
        data.EMBER_WEAPON_FIRED_COUNTER = ((data.EMBER_WEAPON_FIRED_COUNTER or 0)+1)%FIRE_FREQ
    end

    if(data.EMBER_WEAPON_FIRED_COUNTER==0 and pl:HasCollectible(ToyboxMod.COLLECTIBLE_EMBER)) then
        sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING)

        local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_EMBER)
        local numToFire = rng:RandomInt(FIRE_TEARS_MIN, FIRE_TEARS_MAX)
        for i=1, numToFire do
            local vel = dir:Resized(13*pl.ShotSpeed*(0.9+0.2*rng:RandomFloat()))
            if(i~=1) then
                vel = vel:Rotated(rng:RandomInt(-FIRE_TEARS_ARC, FIRE_TEARS_ARC))
            end

            local tear = pl:FireTear(owner.Position, vel, false, true, false, owner, 0.75)
            tear:AddTearFlags(TearFlags.TEAR_BURN)
            tear.CollisionDamage = tear.CollisionDamage*(0.25/0.75)

            tear.FallingSpeed = tear.FallingSpeed+rng:RandomInt(-13,-7)
            tear.FallingAcceleration = tear.FallingAcceleration+1+rng:RandomFloat()*0.5

            tear:ChangeVariant(TearVariant.ROCK)
            tear.Color = Color(255/140,131/123,1/123,1,0.1,0.05,0)
            tear:Update()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, postTriggerWeaponFired)

---@param ent Entity
---@param dmg integer
---@param flags DamageFlag
local function increaseDebuffDamage(_, ent, dmg, flags, source, cnt)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_EMBER)) then return end

    if(flags & DamageFlag.DAMAGE_POISON_BURN == DamageFlag.DAMAGE_POISON_BURN and ent:GetBurnDamageTimer()%20==2) then
        for _, otherEnt in ipairs(Isaac.FindInRadius(ent.Position, ent.Size*FIRE_SPREAD_SIZEMULT+FIRE_SPREAD_RADIUS, EntityPartition.ENEMY)) do
            if(ToyboxMod:isValidEnemy(otherEnt)) then
                otherEnt:AddBurn(source, -(ent:GetBurnCountdown()*1.5)//1, dmg)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, increaseDebuffDamage)