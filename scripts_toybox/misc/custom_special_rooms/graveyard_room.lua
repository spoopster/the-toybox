local BASE_CHANCE = 0.1
local INCREMENT_PER_EMPTY_HEART = 0.05
local MAX_CHANCE = 0.5
local LOST_CHANCE_INCREMENT = 0.1

local function getGraveyardChance()
    local chance = BASE_CHANCE
    local players = PlayerManager.GetPlayers()
    local nump = #players
    for _, pl in ipairs(players) do
        local addedChance = 0
        local emptyHearts = (pl:GetEffectiveMaxHearts()-pl:GetHearts())//2
        addedChance = addedChance+emptyHearts*INCREMENT_PER_EMPTY_HEART
        if(pl:GetHealthType()==HealthType.LOST) then
            addedChance = addedChance+LOST_CHANCE_INCREMENT
        elseif(pl:GetSoulHearts()+pl:GetHearts()<=2) then
            addedChance = 1
        end

        chance = chance+addedChance/nump
    end
    chance = math.min(chance, MAX_CHANCE)

    return 0
end

local function addNewBossRoom(_)
    local level = Game():GetLevel()
    local stage = level:GetAbsoluteStage()+(level:GetStageType()>=StageType.STAGETYPE_REPENTANCE and 1 or 0)
    if(stage%2==0) then return end -- only odd stages
    local rng = level:GetGenerationRNG()
    local chance = getGraveyardChance()
    if(rng:RandomFloat()<chance) then
        local newBossRoom = RoomConfigHolder.GetRandomRoom(Random(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_TELEPORTER, nil, nil, nil, nil, nil, nil, 100)
        local possibleRooms = level:FindValidRoomPlacementLocations(newBossRoom, -1, false, false)

        local finalRoom
        while(#possibleRooms>0 and not finalRoom) do
            local idx = rng:RandomInt(#possibleRooms)+1
        
            finalRoom = level:TryPlaceRoom(newBossRoom, possibleRooms[idx], -1, 0, true, true, false)
            table.remove(possibleRooms, idx)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, addNewBossRoom)

local function gggg(_)
    local iconssprite = Minimap.GetIconsSprite()
    iconssprite.Rotation = 0
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_MINIMAP_RENDER, gggg)