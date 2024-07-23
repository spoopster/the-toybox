local mod = MilcomMOD

if(not EID) then return end

--#region --! DEFINITIONS

local transformationSprites = Sprite()
transformationSprites:Load("gfx/eid/tb_eid_mantleicons.anm2", true)
local statuseffectSprites = Sprite()
statuseffectSprites:Load("gfx/eid/tb_eid_statuseffects.anm2", true)
local goldenPillSprite = Sprite()
goldenPillSprite:Load("gfx/eid/tb_eid_goldenpill.anm2", true)
local playerIconSprites = Sprite()
playerIconSprites:Load("gfx/eid/tb_eid_playericons.anm2", true)

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

EID:addIcon("ToyboxElectrifiedStatus", "Electrified", 0, 12, 11, -1, 0, statuseffectSprites)
EID:addIcon("ToyboxOverflowingStatus", "Overflowing", 0, 16, 13, -3, 0, statuseffectSprites)

EID:addIcon("ToyboxGoldenPill", "Golden Pill", 0, 12, 11, -1, 0, goldenPillSprite)

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
    else
        return
    end

    if(desc==nil) then return end

    if(desc.DescriptionAppend and #desc.DescriptionAppend~=0) then
        EID:addDescriptionModifier(
            "TOYBOX-1"..tostring(entData[1]).."."..tostring(entData[2]).."."..tostring(entData[3]).."-".."AppendDesc",
            function(descObj)
                if(not (descObj.ObjType==entData[1] and descObj.ObjVariant==entData[2] and (descObj.ObjSubType==entData[3] or (entData[2]==350 and descObj.ObjSubType==entData[3]+TrinketType.TRINKET_GOLDEN_FLAG)))) then return false end
                local ok = false
                for _, mData in ipairs(desc.DescriptionAppend) do
                    if(ok~=false) then break end
                    ok = ok or mData.Condition(descObj)
                end

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
                if(not (descObj.ObjType==entData[1] and descObj.ObjVariant==entData[2] and (descObj.ObjSubType==entData[3] or (entData[2]==350 and descObj.ObjSubType==entData[3]+TrinketType.TRINKET_GOLDEN_FLAG)))) then return false end
                local ok = false
                for _, mData in ipairs(desc.DescriptionModifiers) do
                    if(ok~=false) then break end
                    ok = ok or mData.Condition(descObj)
                end

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
for _, modData in ipairs(descs.EXTRA_ITEM_MODIFIERS) do
    local baseData = modData[0]
    for key, data in pairs(modData) do
        if(key==0) then goto continue end
        --print(key)

        if((data.DescriptionAppend or data.DescriptionModifiers) and (descs.ITEMS[key]==nil)) then
            descs.ITEMS[key] = {}
        end

        if(data.DescriptionAppend) then
            if(descs.ITEMS[key].DescriptionAppend==nil) then descs.ITEMS[key].DescriptionAppend={} end
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
                table.insert(descs.ITEMS[key].DescriptionAppend,
                    {
                        AddToTop = appendData.AddToTop,
                        Condition = finalCondition,
                        DescriptionToAdd = finalDescTable
                    }
                )
            end
        end
        if(data.DescriptionModifiers) then
            if(descs.ITEMS[key].DescriptionModifiers==nil) then descs.ITEMS[key].DescriptionModifiers={} end
            for _, modifData in ipairs(data.DescriptionModifiers) do
                local finalCondition = function(descObj)
                    return baseData.BaseCondition(descObj) and (modifData.Condition==nil or (modifData.Condition and modifData.Condition(descObj)))
                end
                table.insert(descs.ITEMS[key].DescriptionModifiers,
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

for key, data in pairs(descs.ITEMS) do
    if(data.Description) then
        EID:addCollectible(key, turnStringTableToEIDDesc(data.Description), data.Name, "en_us")
    end
    addExtraDescriptionStuff({5,100,key})
end
for key, data in pairs(descs.TRINKETS) do
    if(data.Description) then
        EID:addTrinket(key, turnStringTableToEIDDesc(data.Description), data.Name, "en_us")
    end
    addExtraDescriptionStuff({5,350,key})
end

local cardSprite = Sprite()
cardSprite:Load("gfx/eid/tb_eid_mantles.anm2", true)
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
end

for key, data in pairs(descs.PLAYERS) do
    if(data.Description) then
        EID.descriptions["en_us"].CharacterInfo[key] = {data.Name or EntityConfig.GetPlayer(key):GetName(), turnStringTableToEIDDesc(data.Description)}
    end
    if(data.Birthright) then
        EID:addBirthright(key, turnStringTableToEIDDesc(data.Birthright))
    end
end