local mod = MilcomMOD
local sfx = SFXManager()

local METEOR_CHANCE = 0.09
local METEOR_SPREAD = 9
local METEOR_SPEED = 10

local function playerAttack(_, ent, weap, dir, cMod)
    local p = ent:ToPlayer()
    if(ent.Type==EntityType.ENTITY_FAMILIAR and ent:ToFamiliar().Player) then p = ent:ToFamiliar().Player:ToPlayer() end

    if(p and p:HasCollectible(mod.COLLECTIBLE_PEPPER_X)) then
        local rng = p:GetCollectibleRNG(mod.COLLECTIBLE_PEPPER_X)

        local c = mod:getLuckAffectedChance(p.Luck, METEOR_CHANCE, 13, 0.5)*cMod-- *(2.73/mod:getTps(p))
        if(rng:RandomFloat()<c) then
            local pos = p.Position

            local angle = {Min=dir:GetAngleDegrees()-METEOR_SPREAD, Max=dir:GetAngleDegrees()+METEOR_SPREAD}

            if(dir:Length()<0.01) then angle = {Min=0, Max=360} end
            if(weap:GetWeaponType()==WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
                pos = p:GetActiveWeaponEntity().Position
                angle = {Min=0, Max=360}
            end

            local v = Vector.FromAngle(mod:lerp(angle.Min, angle.Max, rng:RandomFloat()))*METEOR_SPEED
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, mod.TEAR_METEOR, 1, pos, v, p):ToTear()
            tear.CollisionDamage = mod:lerp(3.5, p.Damage, 0.4)
            tear.Scale = tear.CollisionDamage/3.5
            tear.SpriteScale = tear.SpriteScale*(1/tear.Scale)

            tear.FallingAcceleration = tear.FallingAcceleration+(rng:RandomFloat()-0.5)*0.05

            --sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.1)
            sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 0.4)
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, playerAttack)

local function spawnOnDeath(_, tear)
    if(Game():IsPaused()) then return end

    if(tear.Variant==mod.TEAR_METEOR and tear.SubType==1) then
        tear = tear:ToTear()
        local p = Isaac.GetPlayer()
        if(tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()) then p = tear.SpawnerEntity:ToPlayer() end

        local c = Color(1,1,0,1,0.1,0.1,0)

        local d = mod:lerp(3.5, p.Damage, 0.5)*2

        for i=1,4 do
            local v = Vector.FromAngle(i*90+45)*30
            local fj = mod:spawnFireJet(tear, d, tear.Position+v, 1, 5, v, 0, c, true)
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
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, spawnOnDeath, EntityType.ENTITY_TEAR)