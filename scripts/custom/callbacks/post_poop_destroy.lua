local mod = MilcomMOD

---@param poop GridEntityPoop
local function updatePoopGrid(_, poop)
    if(Game():IsPaused()) then return end
    if(poop:GetVariant()==GridPoopVariant.RED) then return end
    local data = mod:getGridEntityDataTable(poop)

    data.POOP_DMG = (data.POOP_DMG or poop:GetSaveState().State)
    if(data.POOP_DMG and poop.State==1000 and poop.State~=data.POOP_DMG) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_POOP_DESTROY, poop:GetVariant(), poop, poop:GetVariant())
    end

    data.POOP_DMG = poop.State
end
mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_UPDATE, updatePoopGrid)