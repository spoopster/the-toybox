local mod = ToyboxMod

--#region DATA

---@param player EntityPlayer
function mod:getMilcomATable(player)
    local tb = mod:getEntityDataTable(player).MILCOM_A_DATA
    if(tb==nil) then mod:setEntityData(player, "MILCOM_A_DATA", mod:cloneTable(mod.MILCOM_A_BASEDATA)) end

    return mod:getEntityDataTable(player).MILCOM_A_DATA or {}
end
---@param player EntityPlayer
---@param key string
function mod:getMilcomAData(player, key)
    return mod:getMilcomATable(player)[key]
end
---@param player EntityPlayer
---@param key string
function mod:setMilcomAData(player, key, val)
    mod:getMilcomATable(player)[key] = val
end

--#endregion