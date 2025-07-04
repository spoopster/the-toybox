

local INK_NUM_PICKER = WeightedOutcomePicker()
INK_NUM_PICKER:AddOutcomeWeight(2, 10)
INK_NUM_PICKER:AddOutcomeWeight(3, 100)
INK_NUM_PICKER:AddOutcomeWeight(4, 50)
INK_NUM_PICKER:AddOutcomeWeight(5, 15)
INK_NUM_PICKER:AddOutcomeWeight(6, 1)

local function spawnInk(npc)
    local rng = npc:GetDropRNG()
    local numToSpawn = INK_NUM_PICKER:PickOutcome(rng)

    while(numToSpawn>0) do
        local subToSpawn = ToyboxMod.PICKUP_SUBTYPE.COIN_INK_1
        if(numToSpawn>1 and rng:RandomFloat()<0.33) then
            subToSpawn = ToyboxMod.PICKUP_SUBTYPE.COIN_INK_2
            numToSpawn = numToSpawn-1
        end
        numToSpawn = numToSpawn-1

        local dir = Vector.FromAngle(rng:RandomInt(360)):Resized(4)
        local ink = Isaac.Spawn(5,20,subToSpawn,npc.Position,dir,npc):ToPickup()
    end
end

local function championDeath(_, npc)
    if(not PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_TYPE.MILCOM_A)) then return end
    if(npc:IsChampion()) then
        spawnInk(npc)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, championDeath)

local function modChampionDeath(_, npc)
    if(not PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_TYPE.MILCOM_A)) then return end
    spawnInk(npc)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_CUSTOM_CHAMPION_DEATH, modChampionDeath)