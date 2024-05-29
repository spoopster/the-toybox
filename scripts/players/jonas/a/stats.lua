local mod = MilcomMOD

---@param player EntityPlayer
local function jonasAInit(_, player)
    if(player:GetPlayerType()==mod.PLAYER_JONAS_A) then
        player:AddMaxHearts(6)
        player:AddHearts(6)
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end
mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, jonasAInit)