local mod = MilcomMOD

if(CustomHealthAPI) then
    local function addHealth(p, k, n)
        if(mod:isAtlasA(p) and not mod.DONT_IGNORE_ATLAS_HEALING and p.FrameCount>0) then
            return true
        end
    end
    CustomHealthAPI.Library.AddCallback(mod, CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, -math.huge, addHealth)
else
    local function helpmehelpme(_, player, num, type, arg)
        if(mod:isAtlasA(player) and not mod.DONT_IGNORE_ATLAS_HEALING) then
            return 0
        end
    end
    mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, math.huge, helpmehelpme)
end