local mod = MilcomMOD

local function checkMark(_, mark)
    if(not mod:isAtlasA(Isaac.GetPlayer())) then return end
    local compVal = Isaac.GetCompletionMark(Isaac.GetPlayer():GetPlayerType(), mark)
    Isaac.SetCompletionMark(mod.PLAYER_ATLAS_A, mark, compVal)
    Isaac.SetCompletionMark(mod.PLAYER_ATLAS_A_TAR, mark, compVal)
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, CallbackPriority.IMPORTANT, checkMark)