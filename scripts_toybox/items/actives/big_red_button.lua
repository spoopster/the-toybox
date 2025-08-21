local NUKE_ROCKET_SUBTYPE = 124

local NUKE_ROCKET_DMG = 50
local NUKE_SHOCKWAVE_DMG = 100

---@param rng RNG
---@param pl EntityPlayer
local function bigRedButtonUse(_, _, rng, pl, flags, slot, vdata)
    local vel = (pl.Velocity:LengthSquared()<1 and Vector.Zero or pl.Velocity)

    local nuke = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_ROCKET_GIGA, NUKE_ROCKET_SUBTYPE, pl.Position, pl.Velocity, pl):ToBomb()
    nuke:GetSprite():ReplaceSpritesheet(0, "gfx_tb/bombs/nuke.png", true)
    nuke.ExplosionDamage = NUKE_ROCKET_DMG
    pl:TryHoldEntity(nuke)

    nuke:Update()

    pl:DischargeActiveItem(slot)
    
    return {
        Discharge = false,
        ShowAnim = false,
        Remove = false,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, bigRedButtonUse, ToyboxMod.COLLECTIBLE_BIG_RED_BUTTON)

---@param bomb EntityBomb
local function nukeUpdate(_, bomb)
    if(bomb.SubType~=NUKE_ROCKET_SUBTYPE) then return end

    if(bomb:GetExplosionCountdown()<=0) then
        local room = Game():GetRoom()

       -- room:MamaMegaExplosion(bomb.Position, (bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()))
        local expl = Isaac.Spawn(1000, EffectVariant.MAMA_MEGA_EXPLOSION, 0, bomb.Position, Vector.Zero, (bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer())):ToEffect()
        expl.CollisionDamage = NUKE_SHOCKWAVE_DMG
        expl.TargetPosition = bomb.Position

        local cornerTL = room:GetTopLeftPos()
        local cornerBR = room:GetBottomRightPos()
        local centerPos = room:GetCenterPos()

        local farthestPos = Vector(
            (math.abs(cornerTL.X-bomb.Position.X)>math.abs(cornerBR.X-bomb.Position.X) and cornerTL.X or cornerBR.X),
            (math.abs(cornerTL.Y-bomb.Position.Y)>math.abs(cornerBR.Y-bomb.Position.Y) and cornerTL.Y or cornerBR.Y)
        )

        farthestPos = farthestPos+Vector(80,80)*Vector(ToyboxMod:sign(farthestPos.X-centerPos.X), ToyboxMod:sign(farthestPos.Y-centerPos.Y))

        local cloudSize = 1.5
        local cloudRadius = 40*cloudSize

        local bombPos = bomb.Position
        local bombSp = bomb.SpawnerEntity

        local numClouds = math.ceil(farthestPos:Distance(bomb.Position)/(1.9*cloudRadius))
        local cloudIdx = 0
        Isaac.CreateTimer(function()
            local cloudsToSpawn = 2*math.pi*cloudIdx*cloudRadius*1.5//cloudRadius
            if(cloudsToSpawn==0) then
                cloudsToSpawn = 1
            end

            for i=1, cloudsToSpawn do
                local spawnPos = Vector.FromAngle(360*i/cloudsToSpawn):Resized(cloudIdx*cloudRadius*1.5)+bombPos
                if(room:IsPositionInRoom(spawnPos, -80)) then
                    local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, spawnPos, Vector.Zero, bombSp):ToEffect()
                    cloud:SetTimeout(30*3)
                    cloud.Scale = cloudSize
                    cloud.SpriteScale = Vector(cloudSize,cloudSize)
                    cloud.SpriteRotation = cloud:GetDropRNG():RandomInt(360)
                end
            end

            cloudIdx = cloudIdx+1
        end, 2, numClouds+1, false)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, nukeUpdate, BombVariant.BOMB_ROCKET_GIGA)