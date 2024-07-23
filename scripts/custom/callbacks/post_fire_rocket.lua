local mod = MilcomMOD
--! also has the ROCKET_COPY_TARGET_DATA and POST_ROCKET_EXPLODE

function mod:tryCalculateRocketEffects(player, effect)
	if(not mod:getEntityData(effect, "HAS_CALCULATED_ROCKET_EFFECTS")) then
        Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_ROCKET, effect, player)

        --print(mod:getEntityData(effect, "EXPLOSION_COLOR"))

		mod:setEntityData(effect, "HAS_CALCULATED_ROCKET_EFFECTS", true)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local player = nil
    local sp = effect.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(mod.COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

	mod:tryCalculateRocketEffects(player, effect)
end, EffectVariant.TARGET)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local player = nil
    local sp = effect.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(mod.COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

	if(effect.FrameCount<=1) then
		if(effect.Parent and effect.Parent.Type==EntityType.ENTITY_EFFECT and effect.Parent.Variant==EffectVariant.TARGET and not mod:getEntityData(effect.Parent, "ALREADY_COPIED_EFFECTS")) then
			Isaac.RunCallback(mod.CUSTOM_CALLBACKS.ROCKET_COPY_TARGET_DATA, effect, effect.Parent)

            --print(mod:getEntityData(effect.Parent, "EXPLOSION_COLOR"))

            mod:setEntityData(effect, "EXPLOSION_COLOR", mod:getEntityData(effect.Parent, "EXPLOSION_COLOR"))
            mod:setEntityData(effect, "HAS_CALCULATED_ROCKET_EFFECTS", true)
            mod:setEntityData(effect.Parent, "ALREADY_COPIED_EFFECTS", true)
		else
			mod:tryCalculateRocketEffects(player, effect)
		end
	end
end, EffectVariant.ROCKET)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	if(effect.SpawnerEntity and effect.SpawnerType==EntityType.ENTITY_EFFECT and effect.SpawnerVariant==EffectVariant.ROCKET) then
		local rocket = effect.SpawnerEntity
        mod:setEntityData(effect, "EXPLOSION_COLOR", mod:getEntityData(rocket, "EXPLOSION_COLOR"))

        local sp = rocket.SpawnerEntity
        local player = nil
        if(sp==nil) then return end
        if(sp:ToPlayer()) then player = sp:ToPlayer()
        elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
            local fam = sp:ToFamiliar()
            if(mod.COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
            else return end
        else return end

        Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_ROCKET_EXPLODE, rocket, effect, player)
	end
end, EffectVariant.BOMB_EXPLOSION)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
	if(effect.FrameCount<=0) then
		effect.Color = mod:getEntityData(effect, "EXPLOSION_COLOR") or effect.Color
	end
end, EffectVariant.BOMB_EXPLOSION)