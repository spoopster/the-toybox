local mod = MilcomMOD

---@param player EntityPlayer
local function atlasAInit(_, player)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end
mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, atlasAInit)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    
    if(flag==CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = Color(0.15,0.15,0.15,1,0,0,0)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function changeAtlasHealthType(_, player)
    return HealthType.DEFAULT
end
mod:AddPriorityCallback(ModCallbacks.MC_PLAYER_GET_HEALTH_TYPE, 1e6+1, changeAtlasHealthType, mod.PLAYER_ATLAS_A)
local function changeAtlasHealthLimit(_, player)
    return 2
end
mod:AddPriorityCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, 1e6+1, changeAtlasHealthLimit, mod.PLAYER_ATLAS_A)

---@param player EntityPlayer
local function forceHealth(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    print(player:GetHearts())
    if(player:GetHearts()<2) then
        print("Hi")
        player:AddHearts(0.5)
    end
end
--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, forceHealth, 0)