local mod = MilcomMOD

local function forceSplit(_, npc, isBlacklisted)
    return false
end
--mod:AddCallback(ModCallbacks.MC_PRE_NPC_SPLIT, forceSplit)