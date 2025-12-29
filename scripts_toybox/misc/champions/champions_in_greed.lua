---@param npc EntityNPC
local function tryMakeChampionsInGreed(_, npc)
    if(CANCEL_INIT) then return end
    if(not ToyboxMod.CONFIG.CHAMPIONS_IN_GREED) then return end
    if(PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_MALICE)) then return end
    if(not Game():IsGreedMode()) then return end
    if(not ToyboxMod:isValidEnemy(npc) or npc:IsBoss()) then return end
    if(npc:IsChampion() or ToyboxMod:isModChampion(npc)) then return end

    local conf = EntityConfig.GetEntity(npc.Type, npc.Variant, npc.SubType)
    local shouldMakeChampion = conf:CanBeChampion()

    if(not shouldMakeChampion) then return end

    local champChance = ToyboxMod:getChampionChance()
    local rng = npc:GetDropRNG()

    if(rng:RandomFloat()<champChance) then
        CANCEL_INIT = true

        if(rng:RandomFloat()<ToyboxMod.CONFIG.MOD_CHAMPION_CHANCE) then
            npc = ToyboxMod:MakeModChampion(npc)
        else
            npc:MakeChampion(npc.InitSeed, -1, true)
        end

        CANCEL_INIT = false
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, CallbackPriority.LATE, tryMakeChampionsInGreed)