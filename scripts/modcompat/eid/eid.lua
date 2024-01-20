local mod = MilcomMOD

if(not EID) then return end

local descs = include("scripts.modcompat.eid.enums")

local function turnStringTableToEIDDesc(table)
    local s=""

    for _, text in ipairs(table.Description) do
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

for key, data in pairs(descs.ITEMS) do
    EID:addCollectible(key, turnStringTableToEIDDesc(data), data.Name, "en_us")
end
