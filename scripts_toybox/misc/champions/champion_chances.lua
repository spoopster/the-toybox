

function ToyboxMod:getVanillaChampionChance()
    local beltNum = PlayerManager.GetNumCollectibles(CollectibleType.COLLECTIBLE_CHAMPION_BELT)
    local heartNum = PlayerManager.GetTotalTrinketMultiplier(TrinketType.TRINKET_PURPLE_HEART)

    local baseChance = (beltNum>0 and 0.2 or 0.05)
    if(Game():GetLevel():GetStage()==LevelStage.STAGE_7) then -- void
        baseChance = 0.75
    end
    baseChance = baseChance*math.max(1, 2*heartNum-1)

    return baseChance
end
function ToyboxMod:getChampionChance()
    local baseChance = ToyboxMod:getVanillaChampionChance()

    local numMilcoms = #Isaac.FindByType(1,0,ToyboxMod.PLAYER_TYPE.MILCOM_A)
    baseChance = baseChance*(1+ToyboxMod.MILCOM_CHAMPION_CHANCE_INC*numMilcoms)
    --print(baseChance)

    return baseChance
end



ToyboxMod.DENY_CHAMP_ROLL = false

---@param npc EntityNPC
local function tryMakeModChampion(npc)
    if(ToyboxMod.DENY_CHAMP_ROLL) then return end
    if(not EntityConfig.GetEntity(npc.Type, npc.Variant, npc.SubType):CanBeChampion()) then return end

    local vanillaChance = ToyboxMod:getVanillaChampionChance()
    local chanceDif = ToyboxMod:getChampionChance()-vanillaChance
    if(npc:GetDropRNG():RandomFloat()<chanceDif/(1-vanillaChance)) then
        npc:MakeChampion(math.max(Random(),1), -1, true)
    end
end

local function makeModChampions(_)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ent:ToNPC()) then
            tryMakeModChampion(ent:ToNPC())
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, makeModChampions)