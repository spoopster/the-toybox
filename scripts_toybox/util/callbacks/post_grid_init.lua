---@param ent GridEntity
local function spawnGrid(_, ent)
    Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, ent:GetType(), ent, ent:GetType())
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, spawnGrid)

local function initOnNewRoom(_)
    local room = ToyboxMod.GAME:GetRoom()
    for i=0, room:GetGridSize()-1 do
        local ent = room:GetGridEntity(i)
        if(ent) then
            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, ent:GetType(), ent, ent:GetType())
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, initOnNewRoom)