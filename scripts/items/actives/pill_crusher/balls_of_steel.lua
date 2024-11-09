local mod = MilcomMOD
local sfx = SFXManager()

local HEALTH_PERCENT = 0.2
local HORSE_HEALTH_PERCENT = 0.5
local ADD_MIN = 2
local ADD_MAX = 50

local SOULHEART_GULPCOL = Color(1,1,1,1)
SOULHEART_GULPCOL:SetColorize(1.5,1.5,3,1)

mod:addPillCrusherEffect(PillEffect.PILLEFFECT_BALLS_OF_STEEL,
function(_, player, isHorse, rng)
    for _, ent in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
        ent = ent:ToNPC()
        if(ent:IsActiveEnemy(false) and ent:IsVulnerableEnemy()) then
            local perc = ent.MaxHitPoints*(isHorse and HORSE_HEALTH_PERCENT or HEALTH_PERCENT)
            perc = math.max(ADD_MIN, math.min(math.floor(ADD_MAX*(isHorse and 2.5 or 1)), perc))
            ent.HitPoints = ent.HitPoints+perc

            local gulpEffect = Isaac.Spawn(1000, 49, 0, ent.Position, Vector.Zero, player):ToEffect()
            gulpEffect.Color = SOULHEART_GULPCOL
            gulpEffect.SpriteOffset = Vector(0, -35)
            gulpEffect.DepthOffset = 1000
            gulpEffect:FollowParent(ent)
            sfx:Play(SoundEffect.SOUND_VAMP_GULP)
        end
    end
end)