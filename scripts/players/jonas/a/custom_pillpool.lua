local mod = MilcomMOD

local jerkinOff = false

mod.PHD_TYPE = {
    NEUTRAL=1<<1,
    GOOD=1<<2,
    BAD=1<<3,
    NONE=1<<1|1<<2|1<<3,
}
mod.PILL_SUBCLASS = {
    NEUTRAL = 0,
    GOOD = 1,
    BAD = 2,
}
mod.PHD_PILLCONVERSION = {
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

    [mod.PILL_EFFECT.DMG_DOWN] = mod.PILL_EFFECT.DMG_UP,
    [mod.PILL_EFFECT.OSSIFICATION] = mod.PILL_EFFECT.YOUR_SOUL_IS_MINE,
    [mod.PILL_EFFECT.FOOD_POISONING] = mod.PILL_EFFECT.VITAMINS,
    [mod.PILL_EFFECT.HEARTBURN] = mod.PILL_EFFECT.COAGULANT,
    [mod.PILL_EFFECT.DYSLEXIA] = mod.PILL_EFFECT.FENT,
    [mod.PILL_EFFECT.MUSCLE_ATROPHY] = mod.PILL_EFFECT.VITAMINS,
}
mod.FALSEPHD_PILLCONVERSION = {
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

    [mod.PILL_EFFECT.VITAMINS] = mod.PILL_EFFECT.MUSCLE_ATROPHY,
    [mod.PILL_EFFECT.DMG_UP] = mod.PILL_EFFECT.DMG_DOWN,
    [mod.PILL_EFFECT.YOUR_SOUL_IS_MINE] = mod.PILL_EFFECT.OSSIFICATION,
    [mod.PILL_EFFECT.PARASITE] = mod.PILL_EFFECT.FOOD_POISONING,
    [mod.PILL_EFFECT.CAPSULE] = mod.PILL_EFFECT.FOOD_POISONING,
    [mod.PILL_EFFECT.COAGULANT] = mod.PILL_EFFECT.HEARTBURN,
    [mod.PILL_EFFECT.FENT] = mod.PILL_EFFECT.DYSLEXIA,
    [mod.PILL_EFFECT.I_BELIEVE] = mod.PILL_EFFECT.ARTHRITIS,
}
mod.PILL_EFFECT.ACHIEVEMENTS = {
    [PillEffect.PILLEFFECT_GULP] = Achievement.GULP_PILL,
    [PillEffect.PILLEFFECT_HORF] = Achievement.HORF,
    [PillEffect.PILLEFFECT_SUNSHINE] = Achievement.SUNSHINE_PILL,
    [PillEffect.PILLEFFECT_VURP] = Achievement.VURP,

    [mod.PILL_EFFECT.I_BELIEVE] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.DYSLEXIA] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.DMG_UP] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.DMG_DOWN] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.DEMENTIA] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.PARASITE] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.FENT] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.YOUR_SOUL_IS_MINE] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.ARTHRITIS] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.OSSIFICATION] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.VITAMINS] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.COAGULANT] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.FOOD_POISONING] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.HEARTBURN] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.MUSCLE_ATROPHY] = mod.ACHIEVEMENT.PILLS,
    [mod.PILL_EFFECT.CAPSULE] = mod.ACHIEVEMENT.PILLS,
}

--! ff pill conversions
if(FiendFolio) then
    mod.PHD_PILLCONVERSION[FiendFolio.ITEM.PILL.HAEMORRHOIDS] = FiendFolio.ITEM.PILL.HOLY_SHIT
    mod.PHD_PILLCONVERSION[FiendFolio.ITEM.PILL.EPIDERMOLYSIS] = PillEffect.PILLEFFECT_PERCS
    mod.PHD_PILLCONVERSION[FiendFolio.ITEM.PILL.LEMON_JUICE] = FiendFolio.ITEM.PILL.FISH_OIL

    mod.FALSEPHD_PILLCONVERSION[FiendFolio.ITEM.PILL.HOLY_SHIT] = FiendFolio.ITEM.PILL.HAEMORRHOIDS
    mod.FALSEPHD_PILLCONVERSION[FiendFolio.ITEM.PILL.CLAIRVOYANCE] = PillEffect.PILLEFFECT_AMNESIA
    mod.FALSEPHD_PILLCONVERSION[FiendFolio.ITEM.PILL.MELATONIN] = PillEffect.PILLEFFECT_PARALYSIS
    mod.FALSEPHD_PILLCONVERSION[FiendFolio.ITEM.PILL.FISH_OIL] = FiendFolio.ITEM.PILL.LEMON_JUICE

    mod.PILL_EFFECT.ACHIEVEMENTS[FiendFolio.ITEM.PILL.CYANIDE] = -1
end

function mod:getAllPillEffects(phdEffect)
    local itemConf = Isaac.GetItemConfig()

    phdEffect = phdEffect or mod.PHD_TYPE.NONE

    local pillEffects = {}
    local currentpill = itemConf:GetPillEffect(0)
    while(currentpill) do
        if((phdEffect & mod.PHD_TYPE.NEUTRAL~=0 and currentpill.EffectSubClass==mod.PILL_SUBCLASS.NEUTRAL)
        or (phdEffect & mod.PHD_TYPE.GOOD~=0 and currentpill.EffectSubClass==mod.PILL_SUBCLASS.GOOD)
        or (phdEffect & mod.PHD_TYPE.BAD~=0 and currentpill.EffectSubClass==mod.PILL_SUBCLASS.BAD)) then
            local ach = mod.PILL_EFFECT.ACHIEVEMENTS[currentpill.ID]

            local shouldAdd = false
            if(ach==nil) then
                shouldAdd = true
            elseif(ach~=-1) then
                if(Isaac.GetPersistentGameData():Unlocked(ach)) then
                    shouldAdd = true
                elseif(ach==mod.ACHIEVEMENT.PILLS and PlayerManager.AnyoneIsPlayerType(mod.PLAYER_TYPE.JONAS_A)) then
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
function mod:getPillColorsInRun()
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
function mod:calcBasePillPool()
    local pool = {}
    local colors = mod:getPillColorsInRun()

    local invalidTb = {[mod.PILL_SUBCLASS.GOOD]={},[mod.PILL_SUBCLASS.NEUTRAL]={},[mod.PILL_SUBCLASS.BAD]={}}
    
    for _, cData in ipairs(colors) do
        pool[cData.COLOR] = {DEFAULT=cData.BASE_EFFECT_ID}
        for key, _ in pairs(invalidTb) do
            invalidTb[key][cData.BASE_EFFECT_ID] = 0
        end
    end

    for color, dat in pairs(pool) do
        dat.NEUTRAL = mod:convertPhdPillEffect(nil, dat.DEFAULT, mod.PHD_TYPE.NEUTRAL, rng, invalidTb[mod.PILL_SUBCLASS.NEUTRAL])
        invalidTb[mod.PILL_SUBCLASS.NEUTRAL][dat.NEUTRAL] = 0

        dat.GOOD = mod:convertPhdPillEffect(nil, dat.DEFAULT, mod.PHD_TYPE.GOOD, rng, invalidTb[mod.PILL_SUBCLASS.GOOD])
        invalidTb[mod.PILL_SUBCLASS.GOOD][dat.GOOD] = 0

        dat.BAD = mod:convertPhdPillEffect(nil, dat.DEFAULT, mod.PHD_TYPE.BAD, rng, invalidTb[mod.PILL_SUBCLASS.BAD])
        invalidTb[mod.PILL_SUBCLASS.BAD][dat.BAD] = 0
    end

    return pool
end
function mod:getNumPillsOfSubClass(pool, subclass)
    local itemConf = Isaac.GetItemConfig()
    local count = 0
    for color, dat in pairs(pool) do
        local eff = itemConf:GetPillEffect(dat.DEFAULT)
        if(eff and eff.EffectSubClass==subclass) then count = count+1 end
    end
    return count
end
function mod:createPillTables()
    local dataTable = mod:getExtraDataTable()
    dataTable.PILL_TABLES_CALCULATED = 1
    dataTable.PILLS_TOTAL = mod:getAllPillEffects()
    dataTable.PILLS_GOOD = mod:getAllPillEffects(mod.PHD_TYPE.GOOD)
    dataTable.PILLS_NEUTRAL = mod:getAllPillEffects(mod.PHD_TYPE.NEUTRAL)
    dataTable.PILLS_BAD = mod:getAllPillEffects(mod.PHD_TYPE.BAD)
    dataTable.PILL_COLORS = mod:getPillColorsInRun()

    dataTable.CUSTOM_PILL_POOL = mod:calcBasePillPool()
    dataTable.PILLS_BAD_NUM = mod:getNumPillsOfSubClass(dataTable.CUSTOM_PILL_POOL, mod.PILL_SUBCLASS.BAD)
    dataTable.PILLS_NEUTRAL_NUM = mod:getNumPillsOfSubClass(dataTable.CUSTOM_PILL_POOL, mod.PILL_SUBCLASS.NEUTRAL)
    dataTable.PILLS_GOOD_NUM = mod:getNumPillsOfSubClass(dataTable.CUSTOM_PILL_POOL, mod.PILL_SUBCLASS.GOOD)
end

--! really fucking hacky and i wanna kms
function mod:convertPhdPillEffect(player, pilleffect, phdMask, rng, invalidPills)
    invalidPills = invalidPills or {}
    rng = rng or mod:generateRng()
    phdMask = phdMask or mod.PHD_TYPE.NONE
    pilleffect = pilleffect or PillEffect.PILLEFFECT_BAD_GAS

    local dTable = mod:getExtraDataTable()
    if(phdMask == mod.PHD_TYPE.NONE) then
        --return pilleffect
        -- [[
        if(player) then
            if(pilleffect==PillEffect.PILLEFFECT_BAD_TRIP and not player:CanUsePill(pilleffect)) then return PillEffect.PILLEFFECT_FULL_HEALTH end
            if(pilleffect==PillEffect.PILLEFFECT_HEALTH_DOWN and not player:CanUsePill(pilleffect)) then return PillEffect.PILLEFFECT_HEALTH_UP end
            return pilleffect
        end
        return pilleffect
        --]]
    elseif(phdMask == mod.PHD_TYPE.NEUTRAL) then
        --return pilleffect
        -- [[
        if(player) then return pilleffect end

        local config = Isaac.GetItemConfig():GetPillEffect(pilleffect)
        if(config.EffectSubClass==mod.PILL_SUBCLASS.NEUTRAL) then
            return pilleffect
        end

        local canGetNeutralPill = 0
        if(not dTable.PILLS_NEUTRAL) then mod:createPillTables() end
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
    elseif(phdMask == mod.PHD_TYPE.GOOD) then
        -- [[
        if(player) then return pilleffect end

        local config = Isaac.GetItemConfig():GetPillEffect(pilleffect)
        if(config.EffectSubClass==mod.PILL_SUBCLASS.GOOD) then
            return pilleffect
        end
        if(mod.PHD_PILLCONVERSION[pilleffect]) then return mod.PHD_PILLCONVERSION[pilleffect] end
        return pilleffect
        --[[
        if(config.EffectSubClass~=mod.PILL_SUBCLASS.BAD) then return pilleffect end

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
    elseif(phdMask == mod.PHD_TYPE.BAD) then
        --return pilleffect
        -- [[
        if(player) then
            if(pilleffect==PillEffect.PILLEFFECT_BAD_TRIP and not player:CanUsePill(pilleffect)) then return PillEffect.PILLEFFECT_I_FOUND_PILLS end
            if(pilleffect==PillEffect.PILLEFFECT_HEALTH_DOWN and not player:CanUsePill(pilleffect)) then return PillEffect.PILLEFFECT_I_FOUND_PILLS end
            return pilleffect
        end

        local config = Isaac.GetItemConfig():GetPillEffect(pilleffect)
        if(config.EffectSubClass==mod.PILL_SUBCLASS.BAD) then
            return pilleffect
        end
        if(mod.FALSEPHD_PILLCONVERSION[pilleffect]) then return mod.FALSEPHD_PILLCONVERSION[pilleffect] end
        return pilleffect
        --[[
        if(config.EffectSubClass~=mod.PILL_SUBCLASS.GOOD) then return pilleffect end

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
function mod:getRandomPillEffect(rng, player, phdVal, baseBlacklist)
    local dataTable = mod:getExtraDataTable()
    rng = rng or mod:generateRng()
    baseBlacklist = baseBlacklist or {}
    phdVal = phdVal or mod.PHD_TYPE.NONE
    if(dataTable.PILLS_TOTAL==nil or dataTable.PILLS_TOTAL==0) then mod:createPillTables() end

    local pillTable = dataTable.PILLS_TOTAL
    if(phdVal~=mod.PHD_TYPE.NONE) then pillTable = mod:getAllPillEffects(phdVal) end

    local chosenPill
    while(not (chosenPill and baseBlacklist[chosenPill]~=0)) do
        chosenPill = pillTable[rng:RandomInt(#pillTable)+1].ID
        --print(chosenPill)
    end
    chosenPill = mod:convertPhdPillEffect(nil, chosenPill, phdVal, rng, {})
    if(player) then chosenPill = mod:convertPhdPillEffect(player, chosenPill, phdVal) end

    return chosenPill
end

function mod:unidentifyPill(color)
    Game():GetItemPool():UnidentifyPill(color)
    if(EID) then EID.UsedPillColors[tostring(color)] = nil end
end
function mod:unidentifyPillPool()
    local dataTable = mod:getExtraDataTable()
    if(not dataTable.PILL_COLORS) then dataTable.PILL_COLORS = mod:getPillColorsInRun() end

    for _, val in ipairs(dataTable.PILL_COLORS) do mod:unidentifyPill(val.COLOR) end
end

--#region --! PHD MASK FUNCTIONS
function mod:calcPhdMask(hasGood, hasNeutral, hasBad)
    if(hasNeutral) then return mod.PHD_TYPE.NEUTRAL end
    if(hasGood and hasBad) then return mod.PHD_TYPE.NONE end
    if(hasGood) then return mod.PHD_TYPE.GOOD end
    if(hasBad) then return mod.PHD_TYPE.BAD end
    return mod.PHD_TYPE.NONE
end
function mod:getPlayerPhdValues(player)
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType()==mod.PLAYER_TYPE.JONAS_A) then return {GOOD=true, NEUTRAL=false, BAD=false} end

    local hasGoodPhd = false
    local hasNeutralPhd = false
    local hasBadPhd = false

    if(player:HasCollectible(CollectibleType.COLLECTIBLE_PHD)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_VIRGO)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)
    or player:HasCollectible(mod.COLLECTIBLE.CLOWN_PHD)) then
        hasGoodPhd = true
    end
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD)) then
        hasBadPhd = true
    end

    return {GOOD=hasGoodPhd, NEUTRAL=hasNeutralPhd, BAD=hasBadPhd}
end
function mod:getPlayerPhdMask(player)
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType()==mod.PLAYER_TYPE.JONAS_A) then return mod.PHD_TYPE.GOOD end

    local phdVals = mod:getPlayerPhdValues(player)
    return mod:calcPhdMask(phdVals.GOOD, phdVals.NEUTRAL, phdVals.BAD)
end
function mod:getTotalPhdMask()
    local hasGoodPhd = false
    local hasNeutralPhd = false
    local hasBadPhd = false

    local mask
    for i, player in ipairs(Isaac.FindByType(1,0)) do
        mask = mod:getPlayerPhdMask(player:ToPlayer())
        hasGoodPhd = hasGoodPhd or (mask == mod.PHD_TYPE.GOOD)
        hasNeutralPhd = hasNeutralPhd or (mask == mod.PHD_TYPE.NEUTRAL)
        hasBadPhd = hasBadPhd or (mask == mod.PHD_TYPE.BAD)
    end
    return mod:calcPhdMask(hasGoodPhd, hasNeutralPhd, hasBadPhd)
end
--#endregion

local function forceAddPillEffect(_, effect, col)
    local dataTable = mod:getExtraDataTable()
    local pillpool = dataTable.CUSTOM_PILL_POOL
    if(not (pillpool and pillpool~=0)) then return end

    local baseEffect = pillpool[col]
    if(baseEffect.DEFAULT==effect) then return end

    local invalidTb = {[mod.PILL_SUBCLASS.GOOD]={},[mod.PILL_SUBCLASS.NEUTRAL]={},[mod.PILL_SUBCLASS.BAD]={}}
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
        local oldt = mod:cloneTable(pillpool[existingCol])
        pillpool[existingCol] = mod:cloneTable(pillpool[col])
        pillpool[col] = oldt
    else
        pillpool[col] = {
            DEFAULT = effect,
            NEUTRAL = mod:convertPhdPillEffect(nil, effect, mod.PHD_TYPE.NEUTRAL, rng, invalidTb[mod.PILL_SUBCLASS.NEUTRAL]),
            GOOD = mod:convertPhdPillEffect(nil, effect, mod.PHD_TYPE.GOOD, rng, invalidTb[mod.PILL_SUBCLASS.GOOD]),
            BAD = mod:convertPhdPillEffect(nil, effect, mod.PHD_TYPE.BAD, rng, invalidTb[mod.PILL_SUBCLASS.BAD]),
        }
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_FORCE_ADD_PILL_EFFECT, CallbackPriority.LATE, forceAddPillEffect)

-- base game is approx bad=4-5, neutral=2-3, good=6-7, 
function mod:calcPillPool(rng, numBadPills, numNeutralPills, numGoodPills)
    local dataTable = mod:getExtraDataTable()

    rng = rng or mod:generateRng()
    mod:createPillTables()
    --print(#dataTable.PILL_COLORS, #dataTable.PILLS_GOOD, #dataTable.PILLS_NEUTRAL, #dataTable.PILLS_BAD)

    local pillQualityData = {
        [mod.PILL_SUBCLASS.GOOD]={NUM=(numGoodPills or dataTable.PILLS_BAD_NUM), TB=dataTable.PILLS_GOOD, INVTB={}},
        [mod.PILL_SUBCLASS.NEUTRAL]={NUM=(numNeutralPills or dataTable.PILLS_NEUTRAL_NUM), TB=dataTable.PILLS_NEUTRAL, INVTB={}},
        [mod.PILL_SUBCLASS.BAD]={NUM=(numBadPills or dataTable.PILLS_GOOD_NUM), TB=dataTable.PILLS_BAD, INVTB={}},
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
        dat.NEUTRAL = mod:convertPhdPillEffect(nil, dat.DEFAULT, mod.PHD_TYPE.NEUTRAL, rng, pillQualityData[mod.PILL_SUBCLASS.NEUTRAL].INVTB)
        pillQualityData[mod.PILL_SUBCLASS.NEUTRAL].INVTB[dat.NEUTRAL] = 0

        dat.GOOD = mod:convertPhdPillEffect(nil, dat.DEFAULT, mod.PHD_TYPE.GOOD, rng, pillQualityData[mod.PILL_SUBCLASS.GOOD].INVTB)
        pillQualityData[mod.PILL_SUBCLASS.GOOD].INVTB[dat.GOOD] = 0

        dat.BAD = mod:convertPhdPillEffect(nil, dat.DEFAULT, mod.PHD_TYPE.BAD, rng, pillQualityData[mod.PILL_SUBCLASS.BAD].INVTB)
        pillQualityData[mod.PILL_SUBCLASS.BAD].INVTB[dat.BAD] = 0
    end

    dataTable.CUSTOM_PILL_POOL = finalPool
end

local function replacePillEffect(_, pilleffect, color)
    if(jerkinOff) then return end

    local dataTable = mod:getExtraDataTable()
    local pillpool = dataTable.CUSTOM_PILL_POOL
    if(pillpool and pillpool~=0) then
        local chosenPlayer = Isaac.GetPlayer()
        local phdVal = mod:getTotalPhdMask()

        if(color==PillColor.PILL_GOLD or color==PillColor.PILL_GOLD|PillColor.PILL_GIANT_FLAG) then
            --print("x")
            local rng = mod:generateRng()
            local invalidPills = {}
            for _, pDat in pairs(pillpool) do invalidPills[pDat.DEFAULT]=0 end

            return mod:getRandomPillEffect(rng, chosenPlayer, phdVal, invalidPills)
        end
        if(pillpool[color]) then
            local cKey = "DEFAULT"
            if(phdVal==mod.PHD_TYPE.GOOD) then cKey="GOOD"
            elseif(phdVal==mod.PHD_TYPE.NEUTRAL) then cKey="NEUTRAL"
            elseif(phdVal==mod.PHD_TYPE.BAD) then cKey="BAD" end

            local effect = pillpool[color][cKey]
            --print(effect, phdVal)

            return mod:convertPhdPillEffect(chosenPlayer, effect, phdVal)
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_GET_PILL_EFFECT, CallbackPriority.LATE, replacePillEffect)

local function makeBaseDatas(_, player)
    if(#Isaac.FindByType(1)==0 and Game():GetFrameCount()==0) then
        --print("Yea")
        mod:calcPillPool()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, makeBaseDatas)

local BASE_GOLDEN_CHANCE = 0.7/100
local BASE_HORSE_CHANCE = 1.43/100

local GOLDEN_CHANCES = {}
local HORSE_CHANCES = {}

function mod:addGoldenChance(val, condition)
    table.insert(GOLDEN_CHANCES, {Amount=val, Condition=condition})
end
function mod:addHorseChance(val, condition)
    table.insert(HORSE_CHANCES, {Amount=val, Condition=condition})
end
function mod:getGoldenChance()
    local baseChance = BASE_GOLDEN_CHANCE
    for _, data in ipairs(GOLDEN_CHANCES) do
        if(data.Condition==nil or (data.Condition and type(data.Condition)=="function" and data.Condition())) then
            if(type(data.Amount)=="number") then baseChance = baseChance+data.Amount
            elseif(type(data.Amount)=="function") then baseChance = data.Amount(baseChance) end
        end
    end
    return baseChance
end
function mod:getHorseChance()
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

    local goldChance = mod:getGoldenChance()
    local horseChance = mod:getHorseChance()
    local rng = mod:generateRng(math.max(1,seed))
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
mod:AddCallback(ModCallbacks.MC_GET_PILL_COLOR, recalcPillColor)

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

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    local dataTable = mod:getExtraDataTable()
    if(dataTable.CUSTOM_PILL_POOL and dataTable.CUSTOM_PILL_POOL~=0) then
        local y = 45
        local totaleff = mod:getAllPillEffects()
        for i, pData in ipairs(dataTable.CUSTOM_PILL_POOL) do
            local isFirst = true

            local highLightName = "DEFAULT"
            local phdMask = mod:getTotalPhdMask()
            if(phdMask == mod.PHD_TYPE.GOOD) then highLightName = "GOOD"
            elseif(phdMask == mod.PHD_TYPE.NEUTRAL) then highLightName = "NEUTRAL"
            elseif(phdMask == mod.PHD_TYPE.BAD) then highLightName = "BAD" end

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
        if(Isaac.GetPlayer():GetPlayerType()~=mod.PLAYER_TYPE.JONAS_A) then return end
        local data = mod:getJonasATable(Isaac.GetPlayer())
        Isaac.RenderText((data.PILLS_POPPED or 0).." "..(data.PILL_BONUS_COUNT or 0).." "..(data.PILLS_FOR_NEXT_BONUS or 0).." "..(data.RESET_BOOST_ROOMS or 0), 505, y, 1,1,1,1)
    end
end)
--]]