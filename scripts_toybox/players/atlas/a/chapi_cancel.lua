local mod = ToyboxMod

if(not CustomHealthAPI) then return end

local ogFunc = CustomHealthAPI.Helper.PlayerIsIgnored

function CustomHealthAPI.Helper.PlayerIsIgnored(player)
    if(mod:isAtlasA(player)) then
        return true
    else
        return ogFunc(player)
    end
end