local mod = MilcomMOD

local PILL_DROP_RNG

---@param npc EntityNPC
local function enemyDie(_, npc)
    if(not npc:IsEnemy()) then return end
    if(not PlayerManager.AnyoneIsPlayerType(mod.PLAYER_JONAS_A)) then return end

    local chance = 0
    for _, player in ipairs(Isaac.FindByType(1,0,mod.PLAYER_JONAS_A)) do
        chance = chance+(mod:getJonasAData(player:ToPlayer(), "MONSTER_PILLDROP_CHANCE") or 0.0777)
    end

    PILL_DROP_RNG = PILL_DROP_RNG or mod:generateRng()
    if(PILL_DROP_RNG:RandomFloat()<chance) then
        local isHorsePill = false
        if(npc:ToNPC():IsBoss()) then isHorsePill=true end

        local spawnPos = npc.Position
        spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(spawnPos)
        local pill = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, spawnPos,Vector.Zero,nil):ToPickup()
        if(isHorsePill) then
            pill:Morph(pill.Type,pill.Variant,mod:tryGetHorsepillSubType(PILL_DROP_RNG, pill.SubType, 1))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, enemyDie)