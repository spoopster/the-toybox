

local FART_RADIUS = 40*3
local HORSE_CLOUD_DURATION = 30*15
local HORSE_CLOUD_SIZE = 1.5

ToyboxMod:addPillCrusherEffect(PillEffect.PILLEFFECT_BAD_GAS,
function(_, player, isHorse, rng)
    for _, ent in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
        ent = ent:ToNPC()
        if(ent:IsActiveEnemy(false) and ent:IsVulnerableEnemy()) then
            local fart = Game():ButterBeanFart(ent.Position, FART_RADIUS, ent, true, false)
            if(isHorse) then
                local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, ent.Position, Vector.Zero, ent):ToEffect()
                cloud:SetTimeout(HORSE_CLOUD_DURATION)
                cloud.SpriteScale = Vector(1,1)*HORSE_CLOUD_SIZE
            end
        end
    end
end)