local mod = MilcomMOD

---@param player EntityPlayer
local function atlasAInit(_, player)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        player:AddSoulHearts(1)
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end
mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, atlasAInit)

local function changeAtlasHealthType(_, player)
    return HealthType.NO_HEALTH
end
mod:AddCallback(ModCallbacks.MC_PLAYER_GET_HEALTH_TYPE, changeAtlasHealthType, mod.PLAYER_ATLAS_A)
local function changeAtlasHealthLimit(_, player)
    return 1
end
mod:AddCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, changeAtlasHealthLimit, mod.PLAYER_ATLAS_A)