local mod = MilcomMOD

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	if(not (effect.SpawnerEntity and effect.SpawnerEntity.Type==EntityType.ENTITY_PLAYER)) then return end

	local player = effect.SpawnerEntity:ToPlayer()
	Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_AQUARIUS, player, effect)
end,
EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)

-- set aquarius color
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, creep)
	local aquariusCol = mod:getEntityData(creep, "AQUARIUS_CREEP_COLOR")
	if(creep.FrameCount==0 and aquariusCol) then
		creep.Color = aquariusCol
	end
end, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)