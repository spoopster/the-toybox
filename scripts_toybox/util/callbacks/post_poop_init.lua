---@param poop GridEntityPoop
local function updatePoopGrid(_, poop)
    if(not ToyboxMod:getGridEntityData(poop, "POOP_INIT")) then
        ToyboxMod:setGridEntityData(poop, "POOP_INIT", true)
        Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_POOP_INIT, poop:GetVariant(), poop, poop:GetVariant(), true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_UPDATE, updatePoopGrid)

local function initOnNewRoom(_)
    local room = Game():GetRoom()
    for i=0, room:GetGridSize()-1 do
        local ent = room:GetGridEntity(i)
        if(ent and ent:ToPoop()) then
            local poop = ent:ToPoop()
            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_POOP_INIT, ent:GetVariant(), poop, ent:GetVariant(), ToyboxMod:getGridEntityData(poop, "POOP_INIT"))
            ToyboxMod:setGridEntityData(poop, "POOP_INIT", true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, initOnNewRoom)