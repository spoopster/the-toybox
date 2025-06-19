
local modName = "Toybox"

if(not EID) then return end

include("scripts_toybox.modcompat.eid.descriptions")
local STORED = require("scripts_toybox.modcompat.eid.stored")

local function getTypeMatchFunction(itemType, itemId)
    if(itemType==PickupVariant.PICKUP_COLLECTIBLE) then
        return function(descObj)
            return (descObj.ObjType==5 and descObj.ObjVariant==100 and descObj.ObjSubType==itemId)
        end
    elseif(itemType==PickupVariant.PICKUP_TRINKET) then
        return function(descObj)
            return (descObj.ObjType==5 and descObj.ObjVariant==350 and (descObj.ObjSubType & ~TrinketType.TRINKET_GOLDEN_FLAG)==itemId)
        end
    elseif(itemType==PickupVariant.PICKUP_PILL) then
        return function(descObj)
            return (descObj.ObjType==5 and descObj.ObjVariant==70 and Game():GetItemPool():GetPillEffect(descObj.ObjSubType)==itemId)
        end
    elseif(itemType==PickupVariant.PICKUP_TAROTCARD) then
        return function(descObj)
            return (descObj.ObjType==5 and descObj.ObjVariant==300 and descObj.ObjSubType==itemId)
        end
    else
        return function(descObj)
            return false
        end
    end
end

local function formatModifier(modifier, icon, color)
    local newModifier = ToyboxMod:cloneTable(modifier)
    newModifier.Type = newModifier.Type or STORED.CONSTANTS.DescriptionModifier.APPEND
    newModifier.Condition = newModifier.Condition or function(descObj) return true end

    if(icon or color) then
        if(type(newModifier.ToModify)~="function") then
            for i, text in ipairs(newModifier.ToModify) do
                if(newModifier.Type==STORED.CONSTANTS.DescriptionModifier.REPLACE) then
                    text[2] = string.gsub(text[2], "{{CR}}", "{{CR}}"..(color or ""))
                    text[2] = (color or "")..text[2]..(color and "{{CR}}" or "")
                    text[2] = (icon and (icon.." ") or "")..text[2]

                    newModifier.ToModify[i] = text
                else
                    text = string.gsub(text, "{{CR}}", "{{CR}}"..(color or ""))
                    text = (color or "")..text..(color and "{{CR}}" or "")
                    text = (icon and (icon.." ") or "")..text

                    newModifier.ToModify[i] = text
                end
            end
        end
    end

    return newModifier
end

local function applyModifier(descObj, modifier)
    if(modifier.Condition(descObj)) then
        if(modifier.Type==STORED.CONSTANTS.DescriptionModifier.APPEND or modifier.Type==STORED.CONSTANTS.DescriptionModifier.APPEND_TOP) then
            local toAdd
            if(type(modifier.ToModify)=="function") then
                toAdd = STORED.FUNCTIONS.StringTableToDescription(modifier.ToModify(descObj))
            else
                toAdd = STORED.FUNCTIONS.StringTableToDescription(modifier.ToModify)
            end

            if(modifier.Type==STORED.CONSTANTS.DescriptionModifier.APPEND) then
                descObj.Description = descObj.Description.."#"..toAdd
            else
                descObj.Description = toAdd.."#"..descObj.Description
            end
        elseif(modifier.Type==STORED.CONSTANTS.DescriptionModifier.REPLACE) then
            if(type(modifier.ToModify)=="function") then
                descObj.Description = modifier.ToModify(descObj, descObj.Description)
            else
                for _, modifyTexts in ipairs(modifier.ToModify) do
                    descObj.Description = string.gsub(descObj.Description, modifyTexts[1], modifyTexts[2])
                end
            end
        end
    end
end

local function addDescriptionModifiers(itemType, itemId, modifiers)
    local matchFunc = getTypeMatchFunction(itemType, itemId)

    local finalCondition = function(descObj)
        if(not matchFunc(descObj)) then return false end

        for _, modifier in ipairs(modifiers) do
            if(modifier.Condition(descObj)) then
                return true
            end
        end
        return false
    end

    EID:addDescriptionModifier(
        tostring(modName).." "..tostring(itemType).." "..tostring(itemId).." MODIFIER",
        finalCondition,
        function(descObj)
            for _, modifier in ipairs(modifiers) do
                applyModifier(descObj, modifier)
            end

            return descObj
        end
    )
end

for id, data in pairs(STORED.ITEMS) do
    if(data.Description) then
        EID:addCollectible(id, STORED.FUNCTIONS.StringTableToDescription(data.Description), data.Name or "", "en_us")
    end

    local modifiersToAdd = {}
    if(data.Modifiers) then
        for _, modifier in ipairs(data.Modifiers) do
            table.insert(modifiersToAdd, formatModifier(modifier))
        end
    end
    for modifierName, modifierData in pairs(STORED.CONSTANTS.ModifierFunctionKey) do
        if(data[modifierName]) then
            for _, modifier in ipairs(data[modifierName]) do
                local tempNewMod = formatModifier(modifier, modifierData[2], modifierData[3])

                local newModifier = ToyboxMod:cloneTable(tempNewMod)
                newModifier.Condition = function(descObj)
                    return STORED.CONSTANTS.ModifierCondition[modifierData[1]](descObj) and tempNewMod.Condition(descObj)
                end

                table.insert(modifiersToAdd, newModifier)
            end
        end
    end

    if(modifiersToAdd[1]) then
        addDescriptionModifiers(PickupVariant.PICKUP_COLLECTIBLE, id, modifiersToAdd)
    end
end

for id, data in pairs(STORED.TRINKETS) do
    if(data.Description) then
        EID:addTrinket(id, STORED.FUNCTIONS.StringTableToDescription(data.Description), data.Name or "", "en_us")
    end

    local modifiersToAdd = {}
    if(data.Modifiers) then
        for _, modifier in ipairs(data.Modifiers) do
            table.insert(modifiersToAdd, formatModifier(modifier))
        end
    end
    for modifierName, modifierData in pairs(STORED.CONSTANTS.ModifierFunctionKey) do
        if(data[modifierName]) then
            for _, modifier in ipairs(data[modifierName]) do
                local tempNewMod = formatModifier(modifier, modifierData[2], modifierData[3])

                local newModifier = ToyboxMod:cloneTable(tempNewMod)
                newModifier.Condition = function(descObj)
                    return STORED.CONSTANTS.ModifierCondition[modifierData[1]](descObj) and tempNewMod.Condition(descObj)
                end

                table.insert(modifiersToAdd, newModifier)
            end
        end
    end

    if(modifiersToAdd[1]) then
        addDescriptionModifiers(PickupVariant.PICKUP_TRINKET, id, modifiersToAdd)
    end
end

for id, data in pairs(STORED.PILLS) do
    if(data.Description) then
        EID:addPill(id, STORED.FUNCTIONS.StringTableToDescription(data.Description), data.Name or "", "en_us")

        local pill = Isaac.GetItemConfig():GetPillEffect(id)
        EID:addPillMetadata(id, pill.MimicCharge, tostring(pill.EffectClass)..(pill.EffectSubClass>0 and (pill.EffectSubClass==2 and "-" or "+") or ""))
    end

    local modifiersToAdd = {}
    if(data.Modifiers) then
        for _, modifier in ipairs(data.Modifiers) do
            table.insert(modifiersToAdd, formatModifier(modifier))
        end
    end
    if(data.HorseModifiers) then
        local horseFunc = function(descObj)
            return (descObj.ObjSubType & PillColor.PILL_GIANT_FLAG ~= 0)
        end

        for _, modifier in ipairs(data.HorseModifiers) do
            local newModifier = formatModifier(modifier)

            local horseModifier = ToyboxMod:cloneTable(newModifier)
            horseModifier.Condition = function(descObj)
                return horseFunc(descObj) and newModifier.Condition(descObj)
            end
            
            table.insert(modifiersToAdd, horseModifier)
        end
    end

    if(modifiersToAdd[1]) then
        addDescriptionModifiers(PickupVariant.PICKUP_PILL, id, modifiersToAdd)
    end
end

for id, data in pairs(STORED.CARDS) do
    if(data.Description) then
        EID:addCard(id, STORED.FUNCTIONS.StringTableToDescription(data.Description), data.Name or "", "en_us")

        local card = Isaac.GetItemConfig():GetCard(id)
        EID:addCardMetadata(id, card.MimicCharge, card:IsRune())
    end

    local modifiersToAdd = {}
    if(data.Modifiers) then
        for _, modifier in ipairs(data.Modifiers) do
            table.insert(modifiersToAdd, formatModifier(modifier))
        end
    end
    if(data.TarotClothModifiers) then
        local clothFunc = function(descObj)
            return PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH)
        end

        for _, modifier in ipairs(data.TarotClothModifiers) do
            local newModifier = formatModifier(modifier)

            local clothModifier = ToyboxMod:cloneTable(newModifier)
            clothModifier.Condition = function(descObj)
                return clothFunc(descObj) and newModifier.Condition(descObj)
            end
            
            table.insert(modifiersToAdd, clothModifier)
        end
    end

    if(modifiersToAdd[1]) then
        addDescriptionModifiers(PickupVariant.PICKUP_TAROTCARD, id, modifiersToAdd)
    end
end

for id, data in pairs(STORED.PLAYERS) do
    if(data.Description) then
        EID.descriptions["en_us"].CharacterInfo[id] = {data.Name, STORED.FUNCTIONS.StringTableToDescription(data.Description)}
    end
    if(data.BirthrightDescription) then
        EID:addBirthright(id, STORED.FUNCTIONS.StringTableToDescription(data.BirthrightDescription))
    end
end

for id, data in pairs(STORED.GLOBAL_MODIFIERS) do
    EID:addDescriptionModifier(
        tostring(modName).." "..tostring(id).." MODIFIER",
        function(descObj)
            for _, modifier in ipairs(data.Modifiers) do
                if(modifier.Condition(descObj)) then
                    return true
                end
            end
            return false
        end,
        function(descObj)
            for _, modifier in ipairs(data.Modifiers) do
                applyModifier(descObj, formatModifier(modifier, nil, nil))
            end

            return descObj
        end
    )
end