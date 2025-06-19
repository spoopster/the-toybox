

if(CustomHealthAPI) then
    local function addHealth(p, k, n)
        if(ToyboxMod:isAtlasA(p) and not ToyboxMod.DONT_IGNORE_ATLAS_HEALING and p.FrameCount>0) then
            return true
        end
    end
    CustomHealthAPI.Library.AddCallback(ToyboxMod, CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, -math.huge, addHealth)
else
    local function helpmehelpme(_, player, num, type, arg)
        if(ToyboxMod:isAtlasA(player) and not ToyboxMod.DONT_IGNORE_ATLAS_HEALING) then
            return 0
        end
    end
    ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, math.huge, helpmehelpme)
end