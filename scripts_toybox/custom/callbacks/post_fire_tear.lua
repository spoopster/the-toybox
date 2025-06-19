

-- normal tears - no evil hacks
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local player = nil
    local sp = tear.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(ToyboxMod.TEAR_COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

    Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, tear, player, tear:HasTearFlags(TearFlags.TEAR_LUDOVICO))
end)

-- fates reward -- fuck you
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, function(_, tear)
	local player = nil
    local sp = tear.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(fam.Variant==FamiliarVariant.FATES_REWARD) then player = fam.Player
        else return end
    else return end

    Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, tear, player, tear:HasTearFlags(TearFlags.TEAR_LUDOVICO))
end, FamiliarVariant.FATES_REWARD)

-- ludovico tear updates - no hakc
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	if(not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO)) then return end
    local player = nil
    local sp = tear.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(fam.Variant == FamiliarVariant.FATES_REWARD) then player = fam.Player
        else return end
    else return end

    if(math.floor(tear.FrameCount/player.MaxFireDelay) ~= math.floor((tear.FrameCount-1)/player.MaxFireDelay)) then
        Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, tear, player, true)
    end
end)