local mod = MilcomMOD
local sfx = SFXManager()

--#region DATA

---@param player EntityPlayer
function mod:getJonasATable(player)
    return mod.JONAS_A_DATA[player.InitSeed]
end
---@param player EntityPlayer
---@param key string
function mod:getJonasAData(player, key)
    return mod.JONAS_A_DATA[player.InitSeed][key]
end
---@param player EntityPlayer
---@param key string
function mod:setJonasAData(player, key, val)
    mod.JONAS_A_DATA[player.InitSeed][key] = val
end

--#endregion

function mod:tryGetHorsepillSubType(rng, stype, horseChance)
    stype = stype or PillColor.PILL_NULL
    if(not Isaac.GetPersistentGameData():Unlocked(Achievement.HORSE_PILLS)) then return (stype & ~PillColor.PILL_GIANT_FLAG) end

    rng = rng or mod:generateRng()
    if(rng:RandomFloat()<(horseChance or 0.0143)) then return stype | PillColor.PILL_GIANT_FLAG end
end