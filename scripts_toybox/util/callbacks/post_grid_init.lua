---@param ent GridEntity
local function updateGrid(_, ent)
    if(not ToyboxMod:getGridEntityData(ent, "GRID_INIT")) then
        ToyboxMod:setGridEntityData(ent, "GRID_INIT", true)
        Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, ent:GetType(), ent, ent:GetType(), true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_UPDATE, updateGrid)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_ROCK_UPDATE, updateGrid)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_PIT_UPDATE, updateGrid)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_PRESSUREPLATE_UPDATE, updateGrid)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, updateGrid)

local function initOnNewRoom(_)
    local room = Game():GetRoom()
    for i=0, room:GetGridSize()-1 do
        local ent = room:GetGridEntity(i)
        if(ent) then
            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, ent:GetType(), ent, ent:GetType(), ToyboxMod:getGridEntityData(ent, "GRID_INIT"))
            ToyboxMod:setGridEntityData(ent, "GRID_INIT", true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, initOnNewRoom)