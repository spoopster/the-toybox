
--! also has the ROCKET_COPY_TARGET_DATA and POST_ROCKET_EXPLODE

function ToyboxMod:tryCalculateRocketEffects(player, effect)
	if(not ToyboxMod:getEntityData(effect, "HAS_CALCULATED_ROCKET_EFFECTS")) then
        Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_ROCKET, effect, player)

        --print(ToyboxMod:getEntityData(effect, "EXPLOSION_COLOR"))

		ToyboxMod:setEntityData(effect, "HAS_CALCULATED_ROCKET_EFFECTS", true)
	end
end

ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local player = nil
    local sp = effect.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(ToyboxMod.TEAR_COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

	ToyboxMod:tryCalculateRocketEffects(player, effect)
end, EffectVariant.TARGET)

ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local player = nil
    local sp = effect.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(ToyboxMod.TEAR_COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

	if(effect.FrameCount<=1) then
		if(effect.Parent and effect.Parent.Type==EntityType.ENTITY_EFFECT and effect.Parent.Variant==EffectVariant.TARGET and not ToyboxMod:getEntityData(effect.Parent, "ALREADY_COPIED_EFFECTS")) then
			Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.ROCKET_COPY_TARGET_DATA, effect, effect.Parent)

            --print(ToyboxMod:getEntityData(effect.Parent, "EXPLOSION_COLOR"))

            ToyboxMod:setEntityData(effect, "EXPLOSION_COLOR", ToyboxMod:getEntityData(effect.Parent, "EXPLOSION_COLOR"))
            ToyboxMod:setEntityData(effect, "HAS_CALCULATED_ROCKET_EFFECTS", true)
            ToyboxMod:setEntityData(effect.Parent, "ALREADY_COPIED_EFFECTS", true)
		else
			ToyboxMod:tryCalculateRocketEffects(player, effect)
		end
	end
end, EffectVariant.ROCKET)

ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	if(effect.SpawnerEntity and effect.SpawnerType==EntityType.ENTITY_EFFECT and effect.SpawnerVariant==EffectVariant.ROCKET) then
		local rocket = effect.SpawnerEntity
        ToyboxMod:setEntityData(effect, "EXPLOSION_COLOR", ToyboxMod:getEntityData(rocket, "EXPLOSION_COLOR"))

        local sp = rocket.SpawnerEntity
        local player = nil
        if(sp==nil) then return end
        if(sp:ToPlayer()) then player = sp:ToPlayer()
        elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
            local fam = sp:ToFamiliar()
            if(ToyboxMod.TEAR_COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
            else return end
        else return end

        Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ROCKET_EXPLODE, rocket, effect, player)
	end
end, EffectVariant.BOMB_EXPLOSION)

ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
	if(effect.FrameCount<=0) then
		effect.Color = ToyboxMod:getEntityData(effect, "EXPLOSION_COLOR") or effect.Color
	end
end, EffectVariant.BOMB_EXPLOSION)