local mod = ToyboxMod

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
	if(not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO)) then return end
    local player = nil
    local sp = tear.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(mod.COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

    if(math.floor(tear.FrameCount/player.MaxFireDelay) ~= math.floor((tear.FrameCount-1)/player.MaxFireDelay)) then
        Isaac.RunCallback(mod.CUSTOM_CALLBACKS.RESET_LUDOVICO_DATA, tear)
    end
end)