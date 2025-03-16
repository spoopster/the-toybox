local mod = ToyboxMod
local sfx = SFXManager()

local TRIP_DAMAGE = 3.5*2

local CREEP_DAMAGE = 1
local CREEP_TIMEOUT = 30*5

mod:addPillCrusherEffect(PillEffect.PILLEFFECT_BAD_TRIP,
function(_, player, isHorse, rng)
    for _, ent in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
        ent = ent:ToNPC()
        if(ent:IsActiveEnemy(false) and ent:IsVulnerableEnemy()) then
            ent:TakeDamage(TRIP_DAMAGE*(isHorse and 3 or 1), 0, EntityRef(player), 0)
            local creep = Isaac.Spawn(1000,46,0,ent.Position,Vector.Zero,player):ToEffect()
            creep.CollisionDamage = CREEP_DAMAGE
            creep.Timeout = CREEP_TIMEOUT
            
            sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
            local splat = Isaac.Spawn(1000,16,4,ent.Position,Vector.Zero,player):ToEffect()

            print(ent.Size)
            splat.SpriteScale = Vector(1,1)*0.8*ent.Size/18
        end
    end
end)