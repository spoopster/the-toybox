

--#region DATA

---@param player EntityPlayer
function ToyboxMod:getMilcomATable(player)
    local tb = ToyboxMod:getEntityDataTable(player).MILCOM_A_DATA
    if(tb==nil) then ToyboxMod:setEntityData(player, "MILCOM_A_DATA", ToyboxMod:cloneTable(ToyboxMod.MILCOM_A_BASEDATA)) end

    return ToyboxMod:getEntityDataTable(player).MILCOM_A_DATA or {}
end
---@param player EntityPlayer
---@param key string
function ToyboxMod:getMilcomAData(player, key)
    return ToyboxMod:getMilcomATable(player)[key]
end
---@param player EntityPlayer
---@param key string
function ToyboxMod:setMilcomAData(player, key, val)
    ToyboxMod:getMilcomATable(player)[key] = val
end

--#endregion