local COMMANDS = {
    {
        Name = "evalcache",
        Description = "Re-evaluates cache for all players",
        Function = function()
            for _, pl in ipairs(PlayerManager.GetPlayers()) do
                pl:AddCacheFlags(CacheFlag.CACHE_ALL)
                pl:EvaluateItems()
            end
        end
    }
}

for _, data in ipairs(COMMANDS) do
    Console.RegisterCommand(data.Name, data.Description or "", data.Description or "", true, AutocompleteType.NONE)
end

local function executeCmd(_, cmd, params)
    for _, data in ipairs(COMMANDS) do
        if(cmd==data.Name) then
            data.Function()
            return
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, executeCmd)