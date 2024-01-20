local mod = MilcomMOD

--#region DATA

---@param player EntityPlayer
function mod:getAtlasATable(player)
    return mod.ATLAS_A_DATA[player.InitSeed]
end
---@param player EntityPlayer
---@param key string
function mod:getAtlasAData(player, key)
    return mod.ATLAS_A_DATA[player.InitSeed][key]
end
---@param player EntityPlayer
---@param key string
function mod:setAtlasAData(player, key, val)
    mod.ATLAS_A_DATA[player.InitSeed][key] = val
end

--#endregion

function mod:isAnyPlayerAtlasA()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        if(player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A) then return true end
    end
    return false
end

function mod:getFirstAtlasA()
    for _, player in ipairs(Isaac.FindByType(1,0,mod.PLAYER_ATLAS_A)) do
        return player
    end
    return nil
end