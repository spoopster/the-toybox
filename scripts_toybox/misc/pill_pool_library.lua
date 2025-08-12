

local jerkinOff = false

ToyboxMod.PHD_TYPE = {
    NEUTRAL=1<<1,
    GOOD=1<<2,
    BAD=1<<3,
    NONE=1<<1|1<<2|1<<3,
}
ToyboxMod.PILL_SUBCLASS = {
    NEUTRAL = 0,
    GOOD = 1,
    BAD = 2,
}
ToyboxMod.PHD_PILLCONVERSION = {
    [PillEffect.PILLEFFECT_TEARS_DOWN] = PillEffect.PILLEFFECT_TEARS_UP,
    [PillEffect.PILLEFFECT_LUCK_DOWN] = PillEffect.PILLEFFECT_LUCK_UP,
    [PillEffect.PILLEFFECT_RANGE_DOWN] = PillEffect.PILLEFFECT_RANGE_UP,
    [PillEffect.PILLEFFECT_HEALTH_DOWN] = PillEffect.PILLEFFECT_HEALTH_UP,
    [PillEffect.PILLEFFECT_SHOT_SPEED_DOWN] = PillEffect.PILLEFFECT_SHOT_SPEED_UP,
    [PillEffect.PILLEFFECT_SPEED_DOWN] = PillEffect.PILLEFFECT_SPEED_UP,

    [PillEffect.PILLEFFECT_AMNESIA] = PillEffect.PILLEFFECT_SEE_FOREVER,
    [PillEffect.PILLEFFECT_QUESTIONMARK] = PillEffect.PILLEFFECT_TELEPILLS,
    [PillEffect.PILLEFFECT_ADDICTED] = PillEffect.PILLEFFECT_PERCS,
    [PillEffect.PILLEFFECT_IM_EXCITED] = PillEffect.PILLEFFECT_IM_DROWSY,
    [PillEffect.PILLEFFECT_PARALYSIS] = PillEffect.PILLEFFECT_PHEROMONES,
    [PillEffect.PILLEFFECT_RETRO_VISION] = PillEffect.PILLEFFECT_SEE_FOREVER,
    [PillEffect.PILLEFFECT_WIZARD] = PillEffect.PILLEFFECT_POWER,
    [PillEffect.PILLEFFECT_X_LAX] = PillEffect.PILLEFFECT_SOMETHINGS_WRONG,
    [PillEffect.PILLEFFECT_BAD_TRIP] = PillEffect.PILLEFFECT_BALLS_OF_STEEL,

    [ToyboxMod.PILL_EFFECT.DMG_DOWN] = ToyboxMod.PILL_EFFECT.DMG_UP,
    [ToyboxMod.PILL_EFFECT.OSSIFICATION] = ToyboxMod.PILL_EFFECT.YOUR_SOUL_IS_MINE,
    [ToyboxMod.PILL_EFFECT.FOOD_POISONING] = ToyboxMod.PILL_EFFECT.VITAMINS,
    [ToyboxMod.PILL_EFFECT.HEARTBURN] = ToyboxMod.PILL_EFFECT.COAGULANT,
    [ToyboxMod.PILL_EFFECT.DYSLEXIA] = ToyboxMod.PILL_EFFECT.FENT,
    [ToyboxMod.PILL_EFFECT.MUSCLE_ATROPHY] = ToyboxMod.PILL_EFFECT.VITAMINS,
}
ToyboxMod.FALSEPHD_PILLCONVERSION = {
    [PillEffect.PILLEFFECT_TEARS_UP] = PillEffect.PILLEFFECT_TEARS_DOWN,
    [PillEffect.PILLEFFECT_LUCK_UP] = PillEffect.PILLEFFECT_LUCK_DOWN,
    [PillEffect.PILLEFFECT_RANGE_UP] = PillEffect.PILLEFFECT_RANGE_DOWN,
    [PillEffect.PILLEFFECT_HEALTH_UP] = PillEffect.PILLEFFECT_HEALTH_DOWN,
    [PillEffect.PILLEFFECT_SHOT_SPEED_UP] = PillEffect.PILLEFFECT_SHOT_SPEED_DOWN,
    [PillEffect.PILLEFFECT_SPEED_UP] = PillEffect.PILLEFFECT_SPEED_DOWN,

    [PillEffect.PILLEFFECT_SEE_FOREVER] = PillEffect.PILLEFFECT_AMNESIA,
    [PillEffect.PILLEFFECT_LEMON_PARTY] = PillEffect.PILLEFFECT_AMNESIA,
    [PillEffect.PILLEFFECT_EXPLOSIVE_DIARRHEA] = PillEffect.PILLEFFECT_RANGE_DOWN,
    [PillEffect.PILLEFFECT_LARGER] = PillEffect.PILLEFFECT_RANGE_DOWN,
    [PillEffect.PILLEFFECT_BOMBS_ARE_KEYS] = PillEffect.PILLEFFECT_TEARS_DOWN,
    [PillEffect.PILLEFFECT_INFESTED_EXCLAMATION] = PillEffect.PILLEFFECT_TEARS_DOWN,
    [PillEffect.PILLEFFECT_48HOUR_ENERGY] = PillEffect.PILLEFFECT_SPEED_DOWN,
    [PillEffect.PILLEFFECT_SMALLER] = PillEffect.PILLEFFECT_SPEED_DOWN,
    [PillEffect.PILLEFFECT_PRETTY_FLY] = PillEffect.PILLEFFECT_LUCK_DOWN,
    [PillEffect.PILLEFFECT_INFESTED_QUESTION] = PillEffect.PILLEFFECT_LUCK_DOWN,
    [PillEffect.PILLEFFECT_BALLS_OF_STEEL] = PillEffect.PILLEFFECT_BAD_TRIP,
    [PillEffect.PILLEFFECT_FULL_HEALTH] = PillEffect.PILLEFFECT_BAD_TRIP,
    [PillEffect.PILLEFFECT_HEMATEMESIS] = PillEffect.PILLEFFECT_BAD_TRIP,
    [PillEffect.PILLEFFECT_SMALLER] = PillEffect.PILLEFFECT_SPEED_DOWN,
    [PillEffect.PILLEFFECT_PRETTY_FLY] = PillEffect.PILLEFFECT_LUCK_DOWN,
    [PillEffect.PILLEFFECT_INFESTED_QUESTION] = PillEffect.PILLEFFECT_LUCK_DOWN,

    [ToyboxMod.PILL_EFFECT.VITAMINS] = ToyboxMod.PILL_EFFECT.MUSCLE_ATROPHY,
    [ToyboxMod.PILL_EFFECT.DMG_UP] = ToyboxMod.PILL_EFFECT.DMG_DOWN,
    [ToyboxMod.PILL_EFFECT.YOUR_SOUL_IS_MINE] = ToyboxMod.PILL_EFFECT.OSSIFICATION,
    [ToyboxMod.PILL_EFFECT.PARASITE] = ToyboxMod.PILL_EFFECT.FOOD_POISONING,
    [ToyboxMod.PILL_EFFECT.CAPSULE] = ToyboxMod.PILL_EFFECT.FOOD_POISONING,
    [ToyboxMod.PILL_EFFECT.COAGULANT] = ToyboxMod.PILL_EFFECT.HEARTBURN,
    [ToyboxMod.PILL_EFFECT.FENT] = ToyboxMod.PILL_EFFECT.DYSLEXIA,
    [ToyboxMod.PILL_EFFECT.I_BELIEVE] = ToyboxMod.PILL_EFFECT.ARTHRITIS,
}
ToyboxMod.PILL_EFFECT.ACHIEVEMENTS = {
    [PillEffect.PILLEFFECT_GULP] = Achievement.GULP_PILL,
    [PillEffect.PILLEFFECT_HORF] = Achievement.HORF,
    [PillEffect.PILLEFFECT_SUNSHINE] = Achievement.SUNSHINE_PILL,
    [PillEffect.PILLEFFECT_VURP] = Achievement.VURP,

    [ToyboxMod.PILL_EFFECT.I_BELIEVE] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.DYSLEXIA] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.DMG_UP] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.DMG_DOWN] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.DEMENTIA] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.PARASITE] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.FENT] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.YOUR_SOUL_IS_MINE] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.ARTHRITIS] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.OSSIFICATION] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.VITAMINS] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.COAGULANT] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.FOOD_POISONING] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.HEARTBURN] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.MUSCLE_ATROPHY] = ToyboxMod.ACHIEVEMENT.PILLS,
    [ToyboxMod.PILL_EFFECT.CAPSULE] = ToyboxMod.ACHIEVEMENT.PILLS,
}

--! ff pill conversions
if(FiendFolio) then
    ToyboxMod.PHD_PILLCONVERSION[FiendFolio.ITEM.PILL.HAEMORRHOIDS] = FiendFolio.ITEM.PILL.HOLY_SHIT
    ToyboxMod.PHD_PILLCONVERSION[FiendFolio.ITEM.PILL.EPIDERMOLYSIS] = PillEffect.PILLEFFECT_PERCS
    ToyboxMod.PHD_PILLCONVERSION[FiendFolio.ITEM.PILL.LEMON_JUICE] = FiendFolio.ITEM.PILL.FISH_OIL

    ToyboxMod.FALSEPHD_PILLCONVERSION[FiendFolio.ITEM.PILL.HOLY_SHIT] = FiendFolio.ITEM.PILL.HAEMORRHOIDS
    ToyboxMod.FALSEPHD_PILLCONVERSION[FiendFolio.ITEM.PILL.CLAIRVOYANCE] = PillEffect.PILLEFFECT_AMNESIA
    ToyboxMod.FALSEPHD_PILLCONVERSION[FiendFolio.ITEM.PILL.MELATONIN] = PillEffect.PILLEFFECT_PARALYSIS
    ToyboxMod.FALSEPHD_PILLCONVERSION[FiendFolio.ITEM.PILL.FISH_OIL] = FiendFolio.ITEM.PILL.LEMON_JUICE

    ToyboxMod.PILL_EFFECT.ACHIEVEMENTS[FiendFolio.ITEM.PILL.CYANIDE] = -1
end

function ToyboxMod:getAllPillEffects(phdEffect)
    local itemConf = Isaac.GetItemConfig()

    phdEffect = phdEffect or ToyboxMod.PHD_TYPE.NONE

    local pillEffects = {}
    local currentpill = itemConf:GetPillEffect(0)
    while(currentpill) do
        if((phdEffect & ToyboxMod.PHD_TYPE.NEUTRAL~=0 and currentpill.EffectSubClass==ToyboxMod.PILL_SUBCLASS.NEUTRAL)
        or (phdEffect & ToyboxMod.PHD_TYPE.GOOD~=0 and currentpill.EffectSubClass==ToyboxMod.PILL_SUBCLASS.GOOD)
        or (phdEffect & ToyboxMod.PHD_TYPE.BAD~=0 and currentpill.EffectSubClass==ToyboxMod.PILL_SUBCLASS.BAD)) then
            local ach = ToyboxMod.PILL_EFFECT.ACHIEVEMENTS[currentpill.ID]

            local shouldAdd = false
            if(ach==nil) then
                shouldAdd = true
            elseif(ach~=-1) then
                if(Isaac.GetPersistentGameData():Unlocked(ach)) then
                    shouldAdd = true
                elseif(ach==ToyboxMod.ACHIEVEMENT.PILLS and PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_TYPE.JONAS_A)) then
                    shouldAdd = true
                end
            end

            if(shouldAdd) then
                table.insert(pillEffects,
                    {
                        ID = currentpill.ID,
                        CLASS = currentpill.EffectClass,
                        SUBCLASS = currentpill.EffectSubClass,
                        NAME = currentpill.Name,
                    }
                )
            end
        end
        currentpill = itemConf:GetPillEffect(currentpill.ID+1)
    end

    return pillEffects
end
function ToyboxMod:getPillColorsInRun()
    local itemConf = Isaac.GetItemConfig()
    local itemPool = Game():GetItemPool()

    local pillColorsInPool = {}
    local currentpill = itemConf:GetPillEffect(0)
    while(currentpill) do
        local assocCol = itemPool:GetPillColor(currentpill.ID)
        if(assocCol~=-1 and assocCol~=PillColor.PILL_GOLD) then
            table.insert(pillColorsInPool,
                {
                    COLOR = assocCol,
                    EFFECT_NAME = currentpill.Name,
                    BASE_EFFECT_ID = currentpill.ID,
                }
            )
        end
        currentpill = itemConf:GetPillEffect(currentpill.ID+1)
    end

    return pillColorsInPool
end
function ToyboxMod:calcBasePillPool()
    local pool = {}
    local colors = ToyboxMod:getPillColorsInRun()

    local invalidTb = {[ToyboxMod.PILL_SUBCLASS.GOOD]={},[ToyboxMod.PILL_SUBCLASS.NEUTRAL]={},[ToyboxMod.PILL_SUBCLASS.BAD]={}}
    
    for _, cData in ipairs(colors) do
        pool[cData.COLOR] = {DEFAULT=cData.BASE_EFFECT_ID}
        for key, _ in pairs(invalidTb) do
            invalidTb[key][cData.BASE_EFFECT_ID] = 0
        end
    end

    for color, dat in pairs(pool) do
        dat.NEUTRAL = ToyboxMod:convertPhdPillEffect(nil, dat.DEFAULT, ToyboxMod.PHD_TYPE.NEUTRAL, rng, invalidTb[ToyboxMod.PILL_SUBCLASS.NEUTRAL])
        invalidTb[ToyboxMod.PILL_SUBCLASS.NEUTRAL][dat.NEUTRAL] = 0

        dat.GOOD = ToyboxMod:convertPhdPillEffect(nil, dat.DEFAULT, ToyboxMod.PHD_TYPE.GOOD, rng, invalidTb[ToyboxMod.PILL_SUBCLASS.GOOD])
        invalidTb[ToyboxMod.PILL_SUBCLASS.GOOD][dat.GOOD] = 0

        dat.BAD = ToyboxMod:convertPhdPillEffect(nil, dat.DEFAULT, ToyboxMod.PHD_TYPE.BAD, rng, invalidTb[ToyboxMod.PILL_SUBCLASS.BAD])
        invalidTb[ToyboxMod.PILL_SUBCLASS.BAD][dat.BAD] = 0
    end

    return pool
end
function ToyboxMod:getNumPillsOfSubClass(pool, subclass)
    local itemConf = Isaac.GetItemConfig()
    local count = 0
    for color, dat in pairs(pool) do
        local eff = itemConf:GetPillEffect(dat.DEFAULT)
        if(eff and eff.EffectSubClass==subclass) then count = count+1 end
    end
    return count
end
function ToyboxMod:createPillTables()
    local dataTable = ToyboxMod:getExtraDataTable()
    dataTable.PILL_TABLES_CALCULATED = 1
    dataTable.PILLS_TOTAL = ToyboxMod:getAllPillEffects()
    dataTable.PILLS_GOOD = ToyboxMod:getAllPillEffects(ToyboxMod.PHD_TYPE.GOOD)
    dataTable.PILLS_NEUTRAL = ToyboxMod:getAllPillEffects(ToyboxMod.PHD_TYPE.NEUTRAL)
    dataTable.PILLS_BAD = ToyboxMod:getAllPillEffects(ToyboxMod.PHD_TYPE.BAD)
    dataTable.PILL_COLORS = ToyboxMod:getPillColorsInRun()

    dataTable.CUSTOM_PILL_POOL = ToyboxMod:calcBasePillPool()
    dataTable.PILLS_BAD_NUM = ToyboxMod:getNumPillsOfSubClass(dataTable.CUSTOM_PILL_POOL, ToyboxMod.PILL_SUBCLASS.BAD)
    dataTable.PILLS_NEUTRAL_NUM = ToyboxMod:getNumPillsOfSubClass(dataTable.CUSTOM_PILL_POOL, ToyboxMod.PILL_SUBCLASS.NEUTRAL)
    dataTable.PILLS_GOOD_NUM = ToyboxMod:getNumPillsOfSubClass(dataTable.CUSTOM_PILL_POOL, ToyboxMod.PILL_SUBCLASS.GOOD)
end

--! really fucking hacky and i wanna kms
function ToyboxMod:convertPhdPillEffect(player, pilleffect, phdMask, rng, invalidPills)
    invalidPills = invalidPills or {}
    rng = rng or ToyboxMod:generateRng()
    phdMask = phdMask or ToyboxMod.PHD_TYPE.NONE
    pilleffect = pilleffect or PillEffect.PILLEFFECT_BAD_GAS

    local dTable = ToyboxMod:getExtraDataTable()
    if(phdMask == ToyboxMod.PHD_TYPE.NONE) then
        --return pilleffect
        -- [[
        if(player) then
            if(pilleffect==PillEffect.PILLEFFECT_BAD_TRIP and not player:CanUsePill(pilleffect)) then return PillEffect.PILLEFFECT_FULL_HEALTH end
            if(pilleffect==PillEffect.PILLEFFECT_HEALTH_DOWN and not player:CanUsePill(pilleffect)) then return PillEffect.PILLEFFECT_HEALTH_UP end
            return pilleffect
        end
        return pilleffect
        --]]
    elseif(phdMask == ToyboxMod.PHD_TYPE.NEUTRAL) then
        --return pilleffect
        -- [[
        if(player) then return pilleffect end

        local config = Isaac.GetItemConfig():GetPillEffect(pilleffect)
        if(config.EffectSubClass==ToyboxMod.PILL_SUBCLASS.NEUTRAL) then
            return pilleffect
        end

        local canGetNeutralPill = 0
        if(not dTable.PILLS_NEUTRAL) then ToyboxMod:createPillTables() end
        for _, pill in ipairs(dTable.PILLS_NEUTRAL) do
            if(invalidPills[pill.ID]~=nil) then canGetNeutralPill = canGetNeutralPill+1 end
        end
        if(canGetNeutralPill == #dTable.PILLS_NEUTRAL) then return dTable.PILLS_NEUTRAL[rng:RandomInt(#dTable.PILLS_NEUTRAL)+1].ID end

        local chosenPill
        while(not (chosenPill and invalidPills[chosenPill]~=0)) do
            chosenPill = dTable.PILLS_NEUTRAL[rng:RandomInt(#dTable.PILLS_NEUTRAL)+1].ID
        end
        return chosenPill
        --]]
    elseif(phdMask == ToyboxMod.PHD_TYPE.GOOD) then
        -- [[
        if(player) then return pilleffect end

        local config = Isaac.GetItemConfig():GetPillEffect(pilleffect)
        if(config.EffectSubClass==ToyboxMod.PILL_SUBCLASS.GOOD) then
            return pilleffect
        end
        if(ToyboxMod.PHD_PILLCONVERSION[pilleffect]) then return ToyboxMod.PHD_PILLCONVERSION[pilleffect] end
        return pilleffect
        --[[
        if(config.EffectSubClass~=ToyboxMod.PILL_SUBCLASS.BAD) then return pilleffect end

        --* count number of valid good pills to see if theres any valid ones to pull from
        local canGetGoodPill = 0
        for _, pill in ipairs(dTable.PILLS_GOOD) do
            if(invalidPills[pill.ID]~=nil) then canGetGoodPill = canGetGoodPill+1 end
        end
        if(canGetGoodPill == #dTable.PILLS_GOOD) then return dTable.PILLS_GOOD[rng:RandomInt(#dTable.PILLS_GOOD)+1].ID end

        local chosenPill
        while(not (chosenPill and invalidPills[chosenPill]~=0)) do
            chosenPill = dTable.PILLS_GOOD[rng:RandomInt(#dTable.PILLS_GOOD)+1].ID
        end
        return chosenPill
        --]]
    elseif(phdMask == ToyboxMod.PHD_TYPE.BAD) then
        --return pilleffect
        -- [[
        if(player) then
            if(pilleffect==PillEffect.PILLEFFECT_BAD_TRIP and not player:CanUsePill(pilleffect)) then return PillEffect.PILLEFFECT_I_FOUND_PILLS end
            if(pilleffect==PillEffect.PILLEFFECT_HEALTH_DOWN and not player:CanUsePill(pilleffect)) then return PillEffect.PILLEFFECT_I_FOUND_PILLS end
            return pilleffect
        end

        local config = Isaac.GetItemConfig():GetPillEffect(pilleffect)
        if(config.EffectSubClass==ToyboxMod.PILL_SUBCLASS.BAD) then
            return pilleffect
        end
        if(ToyboxMod.FALSEPHD_PILLCONVERSION[pilleffect]) then return ToyboxMod.FALSEPHD_PILLCONVERSION[pilleffect] end
        return pilleffect
        --[[
        if(config.EffectSubClass~=ToyboxMod.PILL_SUBCLASS.GOOD) then return pilleffect end

        local canGetBadPill = 0
        for _, pill in ipairs(dTable.PILLS_BAD) do
            if(invalidPills[pill.ID]~=nil) then canGetBadPill = canGetBadPill+1 end
        end
        if(canGetBadPill == #dTable.PILLS_BAD) then return dTable.PILLS_BAD[rng:RandomInt(#dTable.PILLS_BAD)+1].ID end

        local chosenPill
        while(not (chosenPill and invalidPills[chosenPill]~=0)) do
            chosenPill = dTable.PILLS_BAD[rng:RandomInt(#dTable.PILLS_BAD)+1].ID
        end
        return chosenPill
        --]]
    end

    return pilleffect
end
function ToyboxMod:getRandomPillEffect(rng, player, phdVal, baseBlacklist)
    local dataTable = ToyboxMod:getExtraDataTable()
    rng = rng or ToyboxMod:generateRng()
    baseBlacklist = baseBlacklist or {}
    phdVal = phdVal or ToyboxMod.PHD_TYPE.NONE
    if(dataTable.PILLS_TOTAL==nil or dataTable.PILLS_TOTAL==0) then ToyboxMod:createPillTables() end

    local pillTable = dataTable.PILLS_TOTAL
    if(phdVal~=ToyboxMod.PHD_TYPE.NONE) then pillTable = ToyboxMod:getAllPillEffects(phdVal) end

    local chosenPill
    while(not (chosenPill and baseBlacklist[chosenPill]~=0)) do
        chosenPill = pillTable[rng:RandomInt(#pillTable)+1].ID
        --print(chosenPill)
    end
    chosenPill = ToyboxMod:convertPhdPillEffect(nil, chosenPill, phdVal, rng, {})
    if(player) then chosenPill = ToyboxMod:convertPhdPillEffect(player, chosenPill, phdVal) end

    return chosenPill
end

function ToyboxMod:unidentifyPill(color)
    Game():GetItemPool():UnidentifyPill(color)
    if(EID) then
        EID.UsedPillColors[tostring(color)] = nil end
    if(FiendFolio) then
        local pillIdx = color % PillColor.PILL_GIANT_FLAG
        FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillIdx)] = false
    end
end
function ToyboxMod:unidentifyPillPool()
    local dataTable = ToyboxMod:getExtraDataTable()
    if(not dataTable.PILL_COLORS) then dataTable.PILL_COLORS = ToyboxMod:getPillColorsInRun() end

    for i=1,PillColor.PILL_GIANT_FLAG-1 do
        ToyboxMod:unidentifyPill(i)
    end
end

--#region --! PHD MASK FUNCTIONS
function ToyboxMod:calcPhdMask(hasGood, hasNeutral, hasBad)
    if(hasNeutral) then return ToyboxMod.PHD_TYPE.NEUTRAL end
    if(hasGood and hasBad) then return ToyboxMod.PHD_TYPE.NONE end
    if(hasGood) then return ToyboxMod.PHD_TYPE.GOOD end
    if(hasBad) then return ToyboxMod.PHD_TYPE.BAD end
    return ToyboxMod.PHD_TYPE.NONE
end
function ToyboxMod:getPlayerPhdValues(player)
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType()==ToyboxMod.PLAYER_TYPE.JONAS_A) then return {GOOD=true, NEUTRAL=false, BAD=false} end

    local hasGoodPhd = false
    local hasNeutralPhd = false
    local hasBadPhd = false

    if(player:HasCollectible(CollectibleType.COLLECTIBLE_PHD)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_VIRGO)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
    or player:HasCollectible(ToyboxMod.COLLECTIBLE_CLOWN_PHD)) then
        hasGoodPhd = true
    end
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD)) then
        hasBadPhd = true
    end

    return {GOOD=hasGoodPhd, NEUTRAL=hasNeutralPhd, BAD=hasBadPhd}
end
function ToyboxMod:getPlayerPhdMask(player)
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType()==ToyboxMod.PLAYER_TYPE.JONAS_A) then return ToyboxMod.PHD_TYPE.GOOD end

    local phdVals = ToyboxMod:getPlayerPhdValues(player)
    return ToyboxMod:calcPhdMask(phdVals.GOOD, phdVals.NEUTRAL, phdVals.BAD)
end
function ToyboxMod:getTotalPhdMask()
    local hasGoodPhd = false
    local hasNeutralPhd = false
    local hasBadPhd = false

    local mask
    for i, player in ipairs(Isaac.FindByType(1,0)) do
        mask = ToyboxMod:getPlayerPhdMask(player:ToPlayer())
        hasGoodPhd = hasGoodPhd or (mask == ToyboxMod.PHD_TYPE.GOOD)
        hasNeutralPhd = hasNeutralPhd or (mask == ToyboxMod.PHD_TYPE.NEUTRAL)
        hasBadPhd = hasBadPhd or (mask == ToyboxMod.PHD_TYPE.BAD)
    end
    return ToyboxMod:calcPhdMask(hasGoodPhd, hasNeutralPhd, hasBadPhd)
end
--#endregion

local function forceAddPillEffect(_, effect, col)
    local dataTable = ToyboxMod:getExtraDataTable()
    local pillpool = dataTable.CUSTOM_PILL_POOL
    
    if(not (pillpool and pillpool~=0)) then return end

    if(col==nil or col<=0 and dataTable.PILL_COLORS and dataTable.PILL_COLORS~=0) then
        local rng = ToyboxMod:generateRng()
        repeat
            col = dataTable.PILL_COLORS[rng:RandomInt(1, #dataTable.PILL_COLORS)].COLOR
        until(col and pillpool[col])
    end

    local baseEffect = pillpool[col]
    if(baseEffect.DEFAULT==effect) then return end

    local invalidTb = {[ToyboxMod.PILL_SUBCLASS.GOOD]={},[ToyboxMod.PILL_SUBCLASS.NEUTRAL]={},[ToyboxMod.PILL_SUBCLASS.BAD]={}}
    local existingCol
    for k, pd in pairs(pillpool) do
        if(pd.DEFAULT==effect) then
            existingCol = k
        end
        for key, _ in pairs(invalidTb) do
            for _, jfhdjfhdfh in pairs(pd) do
                invalidTb[key][jfhdjfhdfh] = 0
            end
        end
    end
    if(existingCol) then
        local oldt = ToyboxMod:cloneTable(pillpool[existingCol])
        pillpool[existingCol] = ToyboxMod:cloneTable(pillpool[col])
        pillpool[col] = oldt
    else
        pillpool[col] = {
            DEFAULT = effect,
            NEUTRAL = ToyboxMod:convertPhdPillEffect(nil, effect, ToyboxMod.PHD_TYPE.NEUTRAL, rng, invalidTb[ToyboxMod.PILL_SUBCLASS.NEUTRAL]),
            GOOD = ToyboxMod:convertPhdPillEffect(nil, effect, ToyboxMod.PHD_TYPE.GOOD, rng, invalidTb[ToyboxMod.PILL_SUBCLASS.GOOD]),
            BAD = ToyboxMod:convertPhdPillEffect(nil, effect, ToyboxMod.PHD_TYPE.BAD, rng, invalidTb[ToyboxMod.PILL_SUBCLASS.BAD]),
        }
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_FORCE_ADD_PILL_EFFECT, CallbackPriority.LATE, forceAddPillEffect)

-- base game is approx bad=4-5, neutral=2-3, good=6-7, 
function ToyboxMod:calcPillPool(rng, numBadPills, numNeutralPills, numGoodPills)
    local dataTable = ToyboxMod:getExtraDataTable()

    rng = rng or ToyboxMod:generateRng()
    ToyboxMod:createPillTables()
    --print(#dataTable.PILL_COLORS, #dataTable.PILLS_GOOD, #dataTable.PILLS_NEUTRAL, #dataTable.PILLS_BAD)

    local pillQualityData = {
        [ToyboxMod.PILL_SUBCLASS.GOOD]={NUM=(numGoodPills or dataTable.PILLS_BAD_NUM), TB=dataTable.PILLS_GOOD, INVTB={}},
        [ToyboxMod.PILL_SUBCLASS.NEUTRAL]={NUM=(numNeutralPills or dataTable.PILLS_NEUTRAL_NUM), TB=dataTable.PILLS_NEUTRAL, INVTB={}},
        [ToyboxMod.PILL_SUBCLASS.BAD]={NUM=(numBadPills or dataTable.PILLS_GOOD_NUM), TB=dataTable.PILLS_BAD, INVTB={}},
    }
    local numPillsTotal = 0
    for _, d in pairs(pillQualityData) do
        numPillsTotal = numPillsTotal+d.NUM
        if(d.NUM>#d.TB) then return end
    end
    if(numPillsTotal>#dataTable.PILL_COLORS) then return end

    local finalPool = {}

    local pillColIdx = 1
    for _, d in pairs(pillQualityData) do
        for _=1, d.NUM do
            local chosenPillEffect
            while(not (chosenPillEffect and d.INVTB[chosenPillEffect]==nil)) do
                chosenPillEffect = d.TB[rng:RandomInt(#d.TB)+1].ID
            end

            d.INVTB[chosenPillEffect]=0

            local chosenCol = dataTable.PILL_COLORS[pillColIdx].COLOR
            finalPool[chosenCol]={DEFAULT=chosenPillEffect}
            pillColIdx = pillColIdx+1
        end
    end

    for color, dat in pairs(finalPool) do
        dat.NEUTRAL = ToyboxMod:convertPhdPillEffect(nil, dat.DEFAULT, ToyboxMod.PHD_TYPE.NEUTRAL, rng, pillQualityData[ToyboxMod.PILL_SUBCLASS.NEUTRAL].INVTB)
        pillQualityData[ToyboxMod.PILL_SUBCLASS.NEUTRAL].INVTB[dat.NEUTRAL] = 0

        dat.GOOD = ToyboxMod:convertPhdPillEffect(nil, dat.DEFAULT, ToyboxMod.PHD_TYPE.GOOD, rng, pillQualityData[ToyboxMod.PILL_SUBCLASS.GOOD].INVTB)
        pillQualityData[ToyboxMod.PILL_SUBCLASS.GOOD].INVTB[dat.GOOD] = 0

        dat.BAD = ToyboxMod:convertPhdPillEffect(nil, dat.DEFAULT, ToyboxMod.PHD_TYPE.BAD, rng, pillQualityData[ToyboxMod.PILL_SUBCLASS.BAD].INVTB)
        pillQualityData[ToyboxMod.PILL_SUBCLASS.BAD].INVTB[dat.BAD] = 0
    end

    dataTable.CUSTOM_PILL_POOL = finalPool
end

local function replacePillEffect(_, pilleffect, color)
    if(jerkinOff) then return end

    local dataTable = ToyboxMod:getExtraDataTable()
    local pillpool = dataTable.CUSTOM_PILL_POOL
    if(pillpool and pillpool~=0) then
        local chosenPlayer = Isaac.GetPlayer()
        local phdVal = ToyboxMod:getTotalPhdMask()

        if(color==PillColor.PILL_GOLD or color==PillColor.PILL_GOLD|PillColor.PILL_GIANT_FLAG) then
            --print("x")
            local rng = ToyboxMod:generateRng()
            local invalidPills = {}
            for _, pDat in pairs(pillpool) do invalidPills[pDat.DEFAULT]=0 end

            return ToyboxMod:getRandomPillEffect(rng, chosenPlayer, phdVal, invalidPills)
        end
        if(pillpool[color]) then
            local cKey = "DEFAULT"
            if(phdVal==ToyboxMod.PHD_TYPE.GOOD) then cKey="GOOD"
            elseif(phdVal==ToyboxMod.PHD_TYPE.NEUTRAL) then cKey="NEUTRAL"
            elseif(phdVal==ToyboxMod.PHD_TYPE.BAD) then cKey="BAD" end

            local effect = pillpool[color][cKey]
            --print(effect, phdVal)

            return ToyboxMod:convertPhdPillEffect(chosenPlayer, effect, phdVal)
        end
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_GET_PILL_EFFECT, CallbackPriority.LATE, replacePillEffect)

local function makeBaseDatas(_, player)
    if(#Isaac.FindByType(1)==0 and Game():GetFrameCount()==0) then
        --print("Yea")
        ToyboxMod:calcPillPool()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, makeBaseDatas)

local BASE_GOLDEN_CHANCE = 0.7/100
local BASE_HORSE_CHANCE = 1.43/100

local GOLDEN_CHANCES = {}
local HORSE_CHANCES = {}

function ToyboxMod:addGoldenChance(val, condition)
    table.insert(GOLDEN_CHANCES, {Amount=val, Condition=condition})
end
function ToyboxMod:addHorseChance(val, condition)
    table.insert(HORSE_CHANCES, {Amount=val, Condition=condition})
end
function ToyboxMod:getGoldenChance()
    local baseChance = BASE_GOLDEN_CHANCE
    for _, data in ipairs(GOLDEN_CHANCES) do
        if(data.Condition==nil or (data.Condition and type(data.Condition)=="function" and data.Condition())) then
            if(type(data.Amount)=="number") then baseChance = baseChance+data.Amount
            elseif(type(data.Amount)=="function") then baseChance = data.Amount(baseChance) end
        end
    end
    return baseChance
end
function ToyboxMod:getHorseChance()
    local baseChance = BASE_HORSE_CHANCE
    for _, data in ipairs(HORSE_CHANCES) do
        if(data.Condition==nil or (data.Condition and type(data.Condition)=="function" and data.Condition())) then
            if(type(data.Amount)=="number") then baseChance = baseChance+data.Amount
            elseif(type(data.Amount)=="function") then baseChance = data.Amount(baseChance) end
        end
    end
    return baseChance
end

local isRecalc = false
local function recalcPillColor(_, seed)
    if(isRecalc) then return end
    isRecalc = true
    local col = Game():GetItemPool():GetPill(seed)

    local isHorse = (col & PillColor.PILL_GIANT_FLAG ~= 0)
    col = col & ~PillColor.PILL_GIANT_FLAG
    local isGolden = (col == PillColor.PILL_GOLD)

    local goldChance = ToyboxMod:getGoldenChance()
    local horseChance = ToyboxMod:getHorseChance()
    local rng = ToyboxMod:generateRng(math.max(1,seed))
    local pool = Game():GetItemPool()

    if(Isaac.GetPersistentGameData():Unlocked(Achievement.GOLDEN_PILLS)) then
        if(goldChance<BASE_GOLDEN_CHANCE and isGolden) then
            goldChance = goldChance/BASE_GOLDEN_CHANCE
            if(not (rng:RandomFloat()<goldChance)) then
                while((col & ~PillColor.PILL_GIANT_FLAG)==PillColor.PILL_GOLD) do
                    col = pool:GetPill(math.max(1,Random()))
                end
            end
        elseif(goldChance>BASE_GOLDEN_CHANCE and not isGolden) then
            goldChance = (goldChance-BASE_GOLDEN_CHANCE)/(1-BASE_GOLDEN_CHANCE)
            if(rng:RandomFloat()<goldChance) then col = PillColor.PILL_GOLD end
        end
    else
        while((col & ~PillColor.PILL_GIANT_FLAG)==PillColor.PILL_GOLD) do
            col = pool:GetPill(math.max(1,Random()))
        end
    end

    if(Isaac.GetPersistentGameData():Unlocked(Achievement.HORSE_PILLS)) then
        if(horseChance<BASE_HORSE_CHANCE and isHorse) then
            horseChance = horseChance/BASE_HORSE_CHANCE
            if(rng:RandomFloat()<horseChance) then
                col = col | PillColor.PILL_GIANT_FLAG
            end
        elseif(horseChance>BASE_HORSE_CHANCE and not isGolden) then
            horseChance = (horseChance-BASE_HORSE_CHANCE)/(1-BASE_HORSE_CHANCE)
            if(rng:RandomFloat()<horseChance) then col = col | PillColor.PILL_GIANT_FLAG end
        end
    else
        col = (col & ~PillColor.PILL_GIANT_FLAG)
    end
    isRecalc = false

    return col
end
ToyboxMod:AddCallback(ModCallbacks.MC_GET_PILL_COLOR, recalcPillColor)

--! RENDER TEST STUFF
--[[
local function convertPillName(s)
    s = string.sub(s,2)
    s = string.gsub(s, "_", " ")
    s = string.lower(s)

    local news = ""
    for w in string.gmatch(s, "[^%s]+") do
        news = news..string.upper(string.sub(w,1,1))..string.sub(w,2).." "
    end
    news = string.sub(news,1,-7)
    return news
end

local pilltypeorder = {
    "DEFAULT", "GOOD", "NEUTRAL", "BAD"
}

ToyboxMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    local dataTable = ToyboxMod:getExtraDataTable()
    if(dataTable.CUSTOM_PILL_POOL and dataTable.CUSTOM_PILL_POOL~=0) then
        local y = 45
        local totaleff = ToyboxMod:getAllPillEffects()
        for i, pData in ipairs(dataTable.CUSTOM_PILL_POOL) do
            local isFirst = true

            local highLightName = "DEFAULT"
            local phdMask = ToyboxMod:getTotalPhdMask()
            if(phdMask == ToyboxMod.PHD_TYPE.GOOD) then highLightName = "GOOD"
            elseif(phdMask == ToyboxMod.PHD_TYPE.NEUTRAL) then highLightName = "NEUTRAL"
            elseif(phdMask == ToyboxMod.PHD_TYPE.BAD) then highLightName = "BAD" end

            Isaac.RenderScaledText(tostring(i)..":", 505, y, 0.5,0.5,0.75,0.75,0.75,0.8)

            for _, n in ipairs(pilltypeorder) do
                local s = ""
                if(not isFirst) then s = s.."  " end

                local conf = Isaac.GetItemConfig():GetPillEffect(pData[n])
                local formName = conf.Name
                if(string.sub(formName,1,1)=="#") then
                    formName = convertPillName(formName)
                end
                s = s..n.." "
                for _=string.len(n), 7 do s=s.." " end
                s = s.."= "..formName

                local colMod = 1
                if(n~=highLightName) then colMod = 0.5 end
                Isaac.RenderScaledText(s, 518, y, 0.5,0.5,colMod,colMod,colMod,0.8)
                isFirst = false
                y = y+5
            end
            y = y+2
        end
        if(Isaac.GetPlayer():GetPlayerType()~=ToyboxMod.PLAYER_TYPE.JONAS_A) then return end
        local data = ToyboxMod:getJonasATable(Isaac.GetPlayer())
        Isaac.RenderText((data.PILLS_POPPED or 0).." "..(data.PILL_BONUS_COUNT or 0).." "..(data.PILLS_FOR_NEXT_BONUS or 0).." "..(data.RESET_BOOST_ROOMS or 0), 505, y, 1,1,1,1)
    end
end)
--]]