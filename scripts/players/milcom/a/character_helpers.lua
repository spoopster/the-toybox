local mod = MilcomMOD

--#region DATA

---@param player EntityPlayer
function mod:getMilcomATable(player)
    return mod.MILCOM_A_DATA[player.InitSeed]
end
---@param player EntityPlayer
---@param key string
function mod:getMilcomAData(player, key)
    return mod.MILCOM_A_DATA[player.InitSeed][key]
end
---@param player EntityPlayer
---@param key string
function mod:setMilcomAData(player, key, val)
    mod.MILCOM_A_DATA[player.InitSeed][key] = val
end

--#endregion