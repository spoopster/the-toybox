local mod = MilcomMOD

local function postPlayerUpdate(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    if(not mod:playerHasCraftable(player, "MAKESHIFT_BOMBS")) then return end


end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate)