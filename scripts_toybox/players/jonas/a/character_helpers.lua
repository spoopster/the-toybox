
local sfx = SFXManager()

--#region DATA

---@param player EntityPlayer
function ToyboxMod:getJonasATable(player)
    local tb = ToyboxMod:getEntityDataTable(player).JONAS_A_DATA
    if(type(tb)~="table") then
	ToyboxMod:setEntityData(player, "JONAS_A_DATA", ToyboxMod:cloneTable(ToyboxMod.JONAS_A_BASEDATA))
    end

    return ToyboxMod:getEntityDataTable(player).JONAS_A_DATA or {}
end
---@param player EntityPlayer
---@param key string
function ToyboxMod:getJonasAData(player, key)
    return ToyboxMod:getJonasATable(player)[key]
end
---@param player EntityPlayer
---@param key string
function ToyboxMod:setJonasAData(player, key, val)
    ToyboxMod:getJonasATable(player)[key] = val
end

--#endregion

function ToyboxMod:tryGetHorsepillSubType(rng, stype, horseChance)
    stype = stype or PillColor.PILL_NULL
    if(not Isaac.GetPersistentGameData():Unlocked(Achievement.HORSE_PILLS)) then return (stype & ~PillColor.PILL_GIANT_FLAG) end

    rng = rng or ToyboxMod:generateRng()
    if(rng:RandomFloat()<(horseChance or 0.0143)) then return stype | PillColor.PILL_GIANT_FLAG end
end