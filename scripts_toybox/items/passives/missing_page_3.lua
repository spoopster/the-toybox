

local DEATH_CHAMP_CHANCE = 4*0.01 --4%
local HARD_BLACK_CHANCE = 0.33

---@param npc EntityNPC
local function npcInit(_, npc)
    if(npc:IsBoss() or npc:IsChampion() or (not npc:IsEnemy())) then return end
    local conf = EntityConfig.GetEntity(npc.Type, npc.Variant, npc.SubType)
    if(not (conf and conf:CanBeChampion())) then return end

    local pageNum = PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_MISSING_PAGE_3)
    if(pageNum<=0) then return end

    local rng = npc:GetDropRNG()
    if(rng:RandomFloat()<(DEATH_CHAMP_CHANCE*pageNum)) then
        local oldHits = npc.MaxHitPoints
        npc:MakeChampion(math.max(Random(),1), ChampionColor.DEATH, true)
        if(pageNum==1) then
            npc.HitPoints = npc.MaxHitPoints
        else
            npc.MaxHitPoints = oldHits
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, npcInit)

---@param npc EntityNPC
local function npcDeath(_, npc)
    if(not (npc:IsChampion() and npc:GetChampionColorIdx()==ChampionColor.DEATH)) then return end

    if(PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_MISSING_PAGE_3)) then
        local chance = 1
        if(Game():IsHardMode()) then chance = HARD_BLACK_CHANCE end

        if(npc:GetDropRNG():RandomFloat()<chance) then
            local heart = Isaac.Spawn(5,10,HeartSubType.HEART_BLACK,Game():GetRoom():FindFreePickupSpawnPosition(npc.Position),Vector.Zero,nil):ToPickup()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, npcDeath)