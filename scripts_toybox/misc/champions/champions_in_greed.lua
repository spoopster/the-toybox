local PENTAGRAM_INDEXES = {}

---@param npc EntityNPC
local function tryMakeChampionsInGreed(_, npc)
    --print("G2")

    if(CANCEL_INIT) then return end
    if(not ToyboxMod.CONFIG.CHAMPIONS_IN_GREED) then return end
    if(PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_MALICE)) then return end
    if(not ToyboxMod.GAME:IsGreedMode()) then return end
    if(not ToyboxMod:isValidEnemy(npc) or npc:IsBoss()) then return end
    if(npc.FrameCount>=ToyboxMod.GAME:GetRoom():GetFrameCount()) then return end
    if(not PENTAGRAM_INDEXES[ToyboxMod.GAME:GetRoom():GetGridIndex(npc.Position)]) then return end
    if(npc:IsChampion() or ToyboxMod:isModChampion(npc)) then return end

    local conf = EntityConfig.GetEntity(npc.Type, npc.Variant, npc.SubType)
    local shouldMakeChampion = conf:CanBeChampion()

    if(not shouldMakeChampion) then return end

    local champChance = ToyboxMod:getChampionChance()+1
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

---@param effect EntityEffect
local function pentagramRemoveMark(_, effect)
    local sp = effect:GetSprite()
    if(sp:GetAnimation()=="Summon" and sp:GetFrame()==sp:GetCurrentAnimationData():GetLength()-1) then
        PENTAGRAM_INDEXES[ToyboxMod.GAME:GetRoom():GetGridIndex(effect.Position)] = true
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, pentagramRemoveMark, EffectVariant.SPAWN_PENTAGRAM)

local function clearPentagrams(_)
    PENTAGRAM_INDEXES = {}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, clearPentagrams)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, clearPentagrams)