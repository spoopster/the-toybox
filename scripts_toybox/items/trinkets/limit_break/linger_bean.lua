

local SPAWN_FREQ = 90
local CLOUD_DUR = 135

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
    if(not (effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer() and ToyboxMod:playerHasLimitBreak(effect.SpawnerEntity:ToPlayer()))) then return end

    if(effect.FrameCount%SPAWN_FREQ==0) then
        local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, effect.Position, Vector.Zero, effect.SpawnerEntity):ToEffect()
        cloud:SetTimeout(CLOUD_DUR)
        cloud.SpriteScale = Vector(1,1)*1.2
        cloud.CollisionDamage = 3.5
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, EffectVariant.BROWN_CLOUD)