
local sfx = SFXManager()

local METEOR_CHANCE = 0.09
local METEOR_SPREAD = 9
local METEOR_SPEED = 10

local function playerAttack(_, ent, weap, dir, cMod)
    local p = ent:ToPlayer()
    if(ent.Type==EntityType.ENTITY_FAMILIAR and ent:ToFamiliar().Player) then p = ent:ToFamiliar().Player:ToPlayer() end

    if(p and p:HasCollectible(ToyboxMod.COLLECTIBLE_PEPPER_X)) then
        local rng = p:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_PEPPER_X)

        local c = ToyboxMod:getLuckAffectedChance(p.Luck, METEOR_CHANCE, 13, 0.5)*cMod-- *(2.73/ToyboxMod:getTps(p))
        if(rng:RandomFloat()<c) then
            local pos = p.Position
            local angle = {Min=dir:GetAngleDegrees()-METEOR_SPREAD, Max=dir:GetAngleDegrees()+METEOR_SPREAD}
            if(dir:Length()<0.01) then angle = {Min=0, Max=360} end
            if(weap:GetWeaponType()==WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
                pos = p:GetActiveWeaponEntity().Position
                angle = {Min=0, Max=360}
            end

            for _=1, p:GetCollectibleNum(ToyboxMod.COLLECTIBLE_PEPPER_X) do
                local v = Vector.FromAngle(ToyboxMod:lerp(angle.Min, angle.Max, rng:RandomFloat()))*METEOR_SPEED
                local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, ToyboxMod.TEAR_VARIANT.METEOR, 1, pos, v, p):ToTear()
                tear.CollisionDamage = ToyboxMod:lerp(3.5, p.Damage, 0.4)
                tear.Scale = tear.CollisionDamage/3.5
                tear.SpriteScale = tear.SpriteScale*(1/tear.Scale)

                tear.FallingAcceleration = tear.FallingAcceleration+(rng:RandomFloat()-0.5)*0.05
            end
            --sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.1)
            sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 0.4)
        end
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, playerAttack)

local function spawnOnDeath(_, tear)
    if(Game():IsPaused()) then return end

    if(tear.Variant==ToyboxMod.TEAR_VARIANT.METEOR and tear.SubType==1) then
        tear = tear:ToTear()
        local p = Isaac.GetPlayer()
        if(tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()) then p = tear.SpawnerEntity:ToPlayer() end

        local c = Color(1,1,0,1,0.1,0.1,0)

        local d = ToyboxMod:lerp(3.5, p.Damage, 0.5)*2

        for i=1,4 do
            local v = Vector.FromAngle(i*90+45)*30
            local spawnData = {
                SpawnType = "LINE",
                SpawnData = {EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0},
                SpawnerEntity = player,
                Position = tear.Position+v,
                Damage = d,
                PlayerFriendly = true,
                AngleVariation = 3,
                Color = Color(1,1,0,1,0.1,0.1,0),
                Distance = v,
                Delay = 5,
                Amount = 1,
            }
            ToyboxMod:spawnCustomObjects(spawnData)
        end

        local fire = Isaac.Spawn(1000,52,0, tear.Position, Vector.Zero, p):ToEffect()
        fire.Color = c

        local s = math.sqrt(tear.Scale)
        fire.SpriteScale = Vector(1,1)*s
        fire.Scale = s
        fire.CollisionDamage = d
        fire.Timeout = 5*30
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, spawnOnDeath, EntityType.ENTITY_TEAR)