local mod = MilcomMOD

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

function mod:getVanillaChampionChance()
    local beltNum = PlayerManager.GetNumCollectibles(CollectibleType.COLLECTIBLE_CHAMPION_BELT)
    local heartNum = PlayerManager.GetTotalTrinketMultiplier(TrinketType.TRINKET_PURPLE_HEART)

    local baseChance = (beltNum>0 and 0.2 or 0.05)
    if(Game():GetLevel():GetStage()==LevelStage.STAGE_7) then -- void
        baseChance = 0.75
    end
    baseChance = baseChance*math.max(1, 2*heartNum-1)

    return baseChance
end
function mod:getChampionChance()
    local baseChance = mod:getVanillaChampionChance()

    local numMilcoms = #Isaac.FindByType(1,0,mod.PLAYER_TYPE.MILCOM_A)
    baseChance = baseChance*(1+mod.MILCOM_CHAMPION_CHANCE_INC*numMilcoms)
    --print(baseChance)

    return baseChance
end