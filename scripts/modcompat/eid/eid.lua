local mod = MilcomMOD

if(not EID) then return end

local transformationSprites = Sprite()
transformationSprites:Load("gfx/eid/eid_atlasa_transformations.anm2", true)

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
        newDesc = newDesc:gsub(tab.Old, tab.New)
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
                entity.Description = "{{Blank}} "..entity.Description
                entity.Description = modifyEIDDescValues(entity.Description, {{Old="#", New="#{{Blank}} "}})
                entity.Description = "#{{AtlasATransformationTar}} {{ColorGray}}As Atlas{{CR}}#"..entity.Description.."#{{Blank}}#{{AtlasATransformationEmpty}} {{ColorGray}}As other players{{CR}}#"

                extraDesc = "{{Blank}} "..extraDesc
                extraDesc = modifyEIDDescValues(extraDesc, {{Old="#", New="#{{Blank}} "}})
            end

            entity.Description = entity.Description..extraDesc

            return entity
        end
    )
end

for key, data in pairs(descs.ITEMS) do
    EID:addCollectible(key, turnStringTableToEIDDesc(data.Description), data.Name, "en_us")
end

local cardSprite = Sprite()
cardSprite:Load("gfx/eid/eid_atlasa_mantles.anm2", true)
for key, data in pairs(descs.CARDS) do
    EID:addIcon("Card"..key, data.Name, -1, 16, 16, 5, 7, cardSprite)
end
for key, data in pairs(descs.CARDS) do
    EID:addCard(key, turnStringTableToEIDDesc(data.Description), data.Name, "en_us")

    if(data.NonAtlasDescription) then
        atlasMantleDescription(data, key)
    end
end
