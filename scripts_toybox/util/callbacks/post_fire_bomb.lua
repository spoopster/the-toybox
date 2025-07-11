

-- cant use MC_POST_FIRE_BOMB bc of scatter bombs so its over
local function getSpawnerPlayer(bomb)
    local player = nil
    local sp = bomb.SpawnerEntity
    
    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(ToyboxMod.TEAR_COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

    return player
end

local function markFiredBomb(_, bomb)
    ToyboxMod:setEntityData(bomb, "IS_FIRED_BOMB", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, markFiredBomb)

local function testFiredBombs(_, _)
    for _, bomb in pairs(ToyboxMod.CALLBACK_BOMBS_FIRED) do
        if(ToyboxMod:getEntityData(bomb, "IS_FIRED_BOMB")) then
            Isaac.RunCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, bomb, getSpawnerPlayer(bomb), ToyboxMod:getEntityData(bomb, "IS_SCATTER_BOMB"))
        end
    end

    ToyboxMod.CALLBACK_BOMBS_FIRED = {}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, testFiredBombs)
for fVar, _ in pairs(ToyboxMod.TEAR_COPYING_FAMILIARS) do
    ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, testFiredBombs, fVar)
end

ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, function(_, bomb)
	if(bomb.Variant == BombVariant.BOMB_THROWABLE) then return end

    if(getSpawnerPlayer(bomb)) then ToyboxMod.CALLBACK_BOMBS_FIRED[bomb.InitSeed] = bomb end
end)

ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bomb)
	if(ToyboxMod.CALLBACK_BOMBS_FIRED[bomb.InitSeed]) then ToyboxMod.CALLBACK_BOMBS_FIRED[bomb.InitSeed]=nil end
end, EntityType.ENTITY_BOMB)