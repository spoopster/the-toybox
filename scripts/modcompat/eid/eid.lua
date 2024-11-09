local mod = MilcomMOD

if(not EID) then return end

--#region --! DEFINITIONS

local transformationSprites = Sprite()
transformationSprites:Load("gfx/eid/tb_eid_mantleicons.anm2", true)
local playerIconSprites = Sprite()
playerIconSprites:Load("gfx/eid/tb_eid_playericons.anm2", true)
local miscIconSprites = Sprite()
miscIconSprites:Load("gfx/eid/tb_eid_miscicons.anm2", true)

EID:addIcon("AtlasATransformationRock", "RockMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationPoop", "PoopMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationBone", "BoneMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationDark", "DarkMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationHoly", "HolyMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationSalt", "SaltMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationGlass", "GlassMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationMetal", "MetalMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationGold", "GoldMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationEmpty", "Empty", 0, 16, 16, 5, 6, transformationSprites)
EID:addIcon("AtlasATransformationTar", "TarMantle", 0, 16, 16, 5, 6, transformationSprites)
EID:addColor("AtlasBlankColor", KColor(0,0,0,0))

EID:addIcon("ToyboxElectrifiedStatus", "Icons", 0, 16, 16, 5, 6, miscIconSprites)
EID:addIcon("ToyboxOverflowingStatus", "Icons", 1, 16, 16, 5, 6, miscIconSprites)
EID:addIcon("ToyboxGoldenPill", "Icons", 2, 16, 16, 5, 6, miscIconSprites)
EID:addIcon("ToyboxHorsePill", "Icons", 3, 16, 16, 5, 6, miscIconSprites)
EID:addIcon("ToyboxGoldenHorsePill", "Icons", 4, 16, 16, 5, 6, miscIconSprites)

EID:addIcon("Player"..mod.PLAYER_ATLAS_A, "AtlasA", 0, 16, 16, 5, 6, playerIconSprites)
EID:addIcon("Player"..mod.PLAYER_ATLAS_A_TAR, "AtlasATar", 0, 16, 16, 5, 6, playerIconSprites)
EID:addIcon("Player"..mod.PLAYER_JONAS_A, "JonasA", 0, 16, 16, 5, 6, playerIconSprites)

--* stolen from EID, they should expose this in the api itd be cool
local function SwagColors(colors, maxAnimTime)
	maxAnimTime = maxAnimTime or 80
	local animTime = Game():GetFrameCount() % maxAnimTime
	local colorFractions = (maxAnimTime - 1) / #colors
	local subAnm = math.floor(animTime / (colorFractions + 1)) + 1
	local primaryColorIndex = subAnm % (#colors + 1)
	if primaryColorIndex == 0 then
		primaryColorIndex = 1
	end
	local secondaryColorIndex = (subAnm + 1) % (#colors + 1)
	if secondaryColorIndex == 0 then
		secondaryColorIndex = 1
	end
	return EID:interpolateColors(
		colors[primaryColorIndex],
		colors[secondaryColorIndex],
		(animTime % (colorFractions + 1)) / colorFractions
	)
end
EID:addColor("ColorToyboxLimitBreak", nil, function()
    return SwagColors({KColor(162/255, 164/255, 222/255, 1), KColor(1,235/255,160/255,1)}, 40)
end)
EID:addColor("ColorToyboxHorsePill", nil, function()
    return SwagColors({KColor(184/255, 169/255, 163/255, 1), KColor(111/255,134/255,192/255,1)}, 80)
end)
EID:addColor("ColorJonas", KColor(173/255, 189/255, 228/255, 1))
EID:addColor("ColorItemStack", KColor(196/255,167/255,196/255,1))

--#endregion

local descs = include("scripts.modcompat.eid.enums")

local function turnStringTableToEIDDesc(table)
    local s=""

    for _, text in ipairs(table) do
        s=s..tostring(text).."#"
    end
    s=string.sub(s,0,-2)

    return s
end

local function modifyEIDDescValues(desc, values)
    local newDesc = desc
    for i, tab in ipairs(values) do
        newDesc = string.gsub(newDesc, tab.Old, tab.New)
    end

    return newDesc
end

local function atlasMantleDescription(descData, id)
    EID:addDescriptionModifier(
        descData.Name .. " MantleDescMod",
        function(entity)
            return (entity.ObjType==5 and entity.ObjVariant==300 and entity.ObjSubType==id) and (#mod:getAllAtlasA()<Game():GetNumPlayers())
        end,
        function(entity)
            if(not descs.CARDS[entity.ObjSubType].NonAtlasDescription) then return end

            local extraDesc = turnStringTableToEIDDesc(descs.CARDS[entity.ObjSubType].NonAtlasDescription)

            if(#mod:getAllAtlasA()==0) then
                entity.Description=""
            else
                entity.Description = entity.Description
                entity.Description = "#{{AtlasATransformationTar}} {{ColorGray}}As Atlas:{{CR}}#"..entity.Description.."#{{Blank}}#{{AtlasATransformationEmpty}} {{ColorGray}}As other players:{{CR}}#"
            end

            entity.Description = entity.Description..extraDesc

            return entity
        end
    )
end

--! adds conditional description modifiers (append to end/beginning, replace text)
local function addExtraDescriptionStuff(entData)
    local desc = {}
    if(entData[1]==5 and entData[2]==100) then
        desc = descs.ITEMS[entData[3]]
    elseif(entData[1]==5 and entData[2]==300) then
        desc = descs.CARDS[entData[3]]
    elseif(entData[1]==5 and entData[2]==350) then
        desc = descs.TRINKETS[entData[3]]
    elseif(entData[1]==5 and entData[2]==70) then
        desc = descs.PILLS[entData[3]]
    else
        return
    end

    if(desc==nil) then return end

    if(desc.DescriptionAppend and #desc.DescriptionAppend~=0) then
        EID:addDescriptionModifier(
            "TOYBOX-1"..tostring(entData[1]).."."..tostring(entData[2]).."."..tostring(entData[3]).."-".."AppendDesc",
            function(descObj)
                if(not (descObj.ObjType==entData[1] and descObj.ObjVariant==entData[2])) then return false end
                if(entData[2]==350) then
                    if(not (descObj.ObjSubType==entData[3] or descObj.ObjSubType==entData[3]+TrinketType.TRINKET_GOLDEN_FLAG)) then return false end
                    --print("im a correct trinket!")
                elseif(entData[2]==70) then
                    if(Game():GetItemPool():GetPillEffect(descObj.ObjSubType)~=entData[3]) then return false end
                    --print("im a correct pill!")
                else
                    if(descObj.ObjSubType~=entData[3]) then return false end
                    --print("im a correct item/card!")
                end
               -- print(entData[1], entData[2], entData[3])
                --print("----")
                --print("appending:")

                local ok = false
                for _, mData in ipairs(desc.DescriptionAppend) do
                    --print("doingg")
                    if(ok~=false) then break end
                    ok = ok or mData.Condition(descObj)
                end

                --print(ok)
                --print("..........")

                return ok
            end,
            function(descObj)
                for _, mData in ipairs(desc.DescriptionAppend) do
                    if((mData.Condition and mData.Condition(descObj)) or (not mData.Condition)) then
                        if(mData.AddToTop==true) then
                            descObj.Description = turnStringTableToEIDDesc(mData.DescriptionToAdd).."#"..descObj.Description
                        else
                            descObj.Description = descObj.Description.."#"..turnStringTableToEIDDesc(mData.DescriptionToAdd)
                        end
                    end
                end
    
                return descObj
            end
        )
    end
    if(desc.DescriptionModifiers and #desc.DescriptionModifiers~=0) then
        EID:addDescriptionModifier(
            "TOYBOX-2"..tostring(entData[1]).."."..tostring(entData[2]).."."..tostring(entData[3]).."-".."ModifyDesc",
            function(descObj)
                if(not (descObj.ObjType==entData[1] and descObj.ObjVariant==entData[2])) then return false end
                if(entData[2]==350) then
                    if(not (descObj.ObjSubType==entData[3] or descObj.ObjSubType==entData[3]+TrinketType.TRINKET_GOLDEN_FLAG)) then return false end
                    --print("im a correct trinket!")
                elseif(entData[2]==70) then
                    if(Game():GetItemPool():GetPillEffect(descObj.ObjSubType)~=entData[3]) then return false end
                    --print("im a correct pill!")
                else
                    if(descObj.ObjSubType~=entData[3]) then return false end
                    --print("im a correct item/card!")
                end
                --print(entData[1], entData[2], entData[3])
                --print("----")
                --print("modifying:")
                
                local ok = false
                for _, mData in ipairs(desc.DescriptionModifiers) do
                    if(ok~=false) then break end
                    ok = ok or mData.Condition(descObj)
                end

                --print(ok)
                --print("..........")

                return ok
            end,
            function(descObj)
                for _, mData in ipairs(desc.DescriptionModifiers) do
                    if(mData.Condition(descObj)) then
                        descObj.Description = modifyEIDDescValues(descObj.Description, mData.TextToModify)
                    end
                end

                return descObj
            end
        )
    end
end

--! adds the "bundled" description modifiers for items (e.g atlas mantle modifiers, limit break buff modifiers etc.)
local bundleModifiers = {
    ITEMS = "EXTRA_ITEM_MODIFIERS",
    TRINKETS = "EXTRA_TRINKET_MODIFIERS",
    CARDS = "EXTRA_CARD_MODIFIERS",
    PILLS = "EXTRA_PILL_MODIFIERS",
}
for og, md in pairs(bundleModifiers) do
    for _, modData in ipairs(descs[md]) do
        local baseData = modData["0"]
        for key, data in pairs(modData) do
            if((data.DescriptionAppend or data.DescriptionModifiers) and (descs[og][key]==nil)) then
                descs[og][key] = {}
            end

            if(key=="0") then
                if(data.DescriptionAppend) then
                    if(descs[og][key].DescriptionAppend==nil) then descs[og][key].DescriptionAppend={} end
                    for _, appendData in ipairs(data.DescriptionAppend) do
                        local finalDescTable = {}
                        for i, st in ipairs(appendData.DescriptionToAdd) do
                            local finalSt = st
                            if(baseData.Color) then
                                finalSt = string.gsub(finalSt, "{{CR}}", "{{CR}}"..baseData.Color)
                                finalSt = baseData.Color..finalSt.."{{CR}}"
                            end
                            if(baseData.Icon) then
                                finalSt = baseData.Icon.." "..finalSt
                            end
                            finalDescTable[i] = finalSt
                        end
                        table.insert(descs[og][key].DescriptionAppend,
                            {
                                AddToTop = appendData.AddToTop,
                                Condition = baseData.BaseCondition,
                                DescriptionToAdd = finalDescTable
                            }
                        )
                    end
                end
                if(data.DescriptionModifiers) then
                    if(descs[og][key].DescriptionModifiers==nil) then descs[og][key].DescriptionModifiers={} end
                    for _, modifData in ipairs(data.DescriptionModifiers) do
                        table.insert(descs[og][key].DescriptionModifiers,
                            {
                                Condition = baseData.BaseCondition,
                                TextToModify = mod:cloneTable(modifData.TextToModify)
                            }
                        )
                    end
                end
            end
            --print(key)
    
            if(data.DescriptionAppend) then
                if(descs[og][key].DescriptionAppend==nil) then descs[og][key].DescriptionAppend={} end
                for _, appendData in ipairs(data.DescriptionAppend) do
                    local finalCondition = function(descObj)
                        return baseData.BaseCondition(descObj) and (appendData.Condition==nil or (appendData.Condition and appendData.Condition(descObj)))
                    end
                    local finalDescTable = {}
                    for i, st in ipairs(appendData.DescriptionToAdd) do
                        local finalSt = st
                        if(baseData.Color) then
                            finalSt = string.gsub(finalSt, "{{CR}}", "{{CR}}"..baseData.Color)
                            finalSt = baseData.Color..finalSt.."{{CR}}"
                        end
                        if(baseData.Icon) then
                            finalSt = baseData.Icon.." "..finalSt
                        end
                        finalDescTable[i] = finalSt
                    end
                    table.insert(descs[og][key].DescriptionAppend,
                        {
                            AddToTop = appendData.AddToTop,
                            Condition = finalCondition,
                            DescriptionToAdd = finalDescTable
                        }
                    )
                end
            end
            if(data.DescriptionModifiers) then
                if(descs[og][key].DescriptionModifiers==nil) then descs[og][key].DescriptionModifiers={} end
                for _, modifData in ipairs(data.DescriptionModifiers) do
                    local finalCondition = function(descObj)
                        return baseData.BaseCondition(descObj) and (modifData.Condition==nil or (modifData.Condition and modifData.Condition(descObj)))
                    end
                    table.insert(descs[og][key].DescriptionModifiers,
                        {
                            Condition = finalCondition,
                            TextToModify = mod:cloneTable(modifData.TextToModify)
                        }
                    )
                end
            end
    
            ::continue::
        end
    end
end

for key, data in pairs(descs.ITEMS) do
    if(data.Description) then
        EID:addCollectible(key, turnStringTableToEIDDesc(data.Description), data.Name, "en_us")
    end
    addExtraDescriptionStuff({5,100,key})

    EID:addDescriptionModifier(
        "TOYBOX-ALPHABET-BOX",
        function(descObj)
            if(not (descObj.ObjType==5 and descObj.ObjVariant==100)) then return false end
            if(descObj.Entity==nil) then return false end
            
            return PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_ALPHABET_BOX)
        end,
        function(descObj)
            if(mod.CONFIG.ALPHABETBOX_EID_DISPLAYS>0) then
                local boxDesc = "{{Collectible"..mod.COLLECTIBLE_ALPHABET_BOX.."}} :"

                local idx = mod:getNextAlphabetItem(descObj.ObjSubType, false)
                for i=1, mod.CONFIG.ALPHABETBOX_EID_DISPLAYS do
                    if(i~=1) then boxDesc = boxDesc.." -> " end

                    if(idx==-1) then
                        boxDesc = boxDesc.."Item disappears"
                        break
                    else
                        boxDesc = boxDesc.."{{Collectible"..mod.ABOX_ITEMS_ALPHABETICAL[idx][2].."}}"
                    end
                    
                    idx = mod:getNextAlphabetItem(mod.ABOX_ITEMS_ALPHABETICAL[idx][2], false)
                end

                descObj.Description = descObj.Description.."#"..boxDesc
            end

            return descObj
        end
    )
end
for key, data in pairs(descs.TRINKETS) do
    if(data.Description) then
        EID:addTrinket(key, turnStringTableToEIDDesc(data.Description), data.Name, "en_us")
    end
    addExtraDescriptionStuff({5,350,key})
end

local cardSprite = Sprite()
cardSprite:Load("gfx/eid/tb_eid_cards.anm2", true)
for key, data in pairs(descs.CARDS) do
    EID:addIcon("Card"..key, data.Name, -1, 16, 16, 5, 7, cardSprite)
end
for key, data in pairs(descs.CARDS) do
    if(data.Description) then
        EID:addCard(key, turnStringTableToEIDDesc(data.Description), data.Name, "en_us")
    end
    if(data.NonAtlasDescription) then
        atlasMantleDescription(data, key)
    end

    addExtraDescriptionStuff({5,300,key})
end

for key, data in pairs(descs.PILLS) do
    if(data.Description) then
        EID:addPill(key, turnStringTableToEIDDesc(data.Description), data.Name, "en_us")
    end

    addExtraDescriptionStuff({5,70,key})
end

for key, data in pairs(descs.PLAYERS) do
    if(data.Description) then
        EID.descriptions["en_us"].CharacterInfo[key] = {data.Name or EntityConfig.GetPlayer(key):GetName(), turnStringTableToEIDDesc(data.Description)}
    end
    if(data.Birthright) then
        EID:addBirthright(key, turnStringTableToEIDDesc(data.Birthright))
    end
end