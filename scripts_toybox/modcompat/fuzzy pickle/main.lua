if(not FiendFolio) then return end

local references = include("scripts_toybox.modcompat.fuzzy pickle.enums")

for _, data in ipairs(references.Actives) do
    table.insert(FiendFolio.ReferenceItems.Actives, data)
end
for _, data in ipairs(references.Passives) do
    table.insert(FiendFolio.ReferenceItems.Passives, data)
end
for _, data in ipairs(references.Trinkets) do
    table.insert(FiendFolio.ReferenceItems.Trinkets, data)
end