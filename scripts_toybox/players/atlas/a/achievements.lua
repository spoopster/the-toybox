

local function checkMark(_, mark)
    if(not ToyboxMod:isAtlasA(Isaac.GetPlayer())) then return end
    local compVal = Isaac.GetCompletionMark(Isaac.GetPlayer():GetPlayerType(), mark)
    Isaac.SetCompletionMark(ToyboxMod.PLAYER_ATLAS_A, mark, compVal)
    Isaac.SetCompletionMark(ToyboxMod.PLAYER_ATLAS_A_TAR, mark, compVal)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, CallbackPriority.IMPORTANT, checkMark)