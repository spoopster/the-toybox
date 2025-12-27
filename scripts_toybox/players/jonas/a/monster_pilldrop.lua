

local PILL_DROP_RNG

---@param npc EntityNPC
local function enemyDie(_, npc)
    if(not npc:IsEnemy()) then return end
    if(not PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_JONAS_A)) then return end

    local cardReplaceTotal = 0
    local cardReplaceChance = 0

    local chance = 0
    for _, player in ipairs(Isaac.FindByType(1,0,ToyboxMod.PLAYER_JONAS_A)) do
        local jonasData = ToyboxMod:getJonasATable(player:ToPlayer())
        if(player:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            cardReplaceChance = cardReplaceChance+(jonasData.BIRTHRIGHT_CARD_CHANCE or 0.2)
            chance = chance+(jonasData.BIRTHRIGHT_PILLDROP_CHANCE or 0.075)
        else
            chance = chance+(jonasData.MONSTER_PILLDROP_CHANCE or 0.05)
        end

        cardReplaceTotal = cardReplaceTotal+1
    end

    PILL_DROP_RNG = PILL_DROP_RNG or ToyboxMod:generateRng()
    if(PILL_DROP_RNG:RandomFloat()<chance) then
        local isHorsePill = false
        if(npc:ToNPC():IsBoss()) then isHorsePill=true end

        local spawnPos = npc.Position
        spawnPos = Game():GetRoom():FindFreePickupSpawnPosition(spawnPos)

        if(PILL_DROP_RNG:RandomFloat()<cardReplaceChance/cardReplaceTotal) then
            local card = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0, spawnPos, Vector.Zero, nil):ToPickup()
        else
            local pill = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, spawnPos,Vector.Zero,nil):ToPickup()
            if(isHorsePill) then
                pill:Morph(pill.Type,pill.Variant,ToyboxMod:tryGetHorsepillSubType(PILL_DROP_RNG, pill.SubType, 1))
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, enemyDie)