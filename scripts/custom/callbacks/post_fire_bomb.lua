local mod = MilcomMOD

-- cant use MC_POST_FIRE_BOMB bc of scatter bombs so its over
local function testFiredBombs(_, _)
    for _, bomb in pairs(mod.CALLBACK_BOMBS_FIRED) do
        local player = nil
        local sp = bomb.SpawnerEntity
    
        if(sp==nil) then return end
        if(sp:ToPlayer()) then player = sp:ToPlayer()
        elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
            local fam = sp:ToFamiliar()
            if(mod.COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
            else return end
        else return end

        Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, bomb, player)
    end

    mod.CALLBACK_BOMBS_FIRED = {}
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, testFiredBombs)
for fVar, _ in pairs(mod.COPYING_FAMILIARS) do
    mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, testFiredBombs, fVar)
end

mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
	if(bomb.Variant == BombVariant.BOMB_THROWABLE) then return end

    local player = nil
    local sp = bomb.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(mod.COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

    if(player) then mod.CALLBACK_BOMBS_FIRED[bomb.InitSeed] = bomb end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bomb)
	if(mod.CALLBACK_BOMBS_FIRED[bomb.InitSeed]) then mod.CALLBACK_BOMBS_FIRED[bomb.InitSeed]=nil end
end, EntityType.ENTITY_BOMB)