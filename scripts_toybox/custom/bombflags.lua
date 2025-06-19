

---@param bomb EntityBomb
local function initFlags(_, bomb)
    ToyboxMod:setEntityData(bomb, "CUSTOM_BOMBFLAGS", 0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, initFlags)
---@param bomb EntityBomb
function ToyboxMod:getCustomBombFlags(bomb)
    return (ToyboxMod:getEntityData(bomb, "CUSTOM_BOMBFLAGS") or 0)
end
---@param bomb EntityBomb
function ToyboxMod:addCustomBombFlags(bomb, flags)
    ToyboxMod:setEntityData(bomb, "CUSTOM_BOMBFLAGS", ToyboxMod:getCustomBombFlags(bomb)|flags)
end
---@param bomb EntityBomb
function ToyboxMod:removeCustomBombFlags(bomb, flags)
    ToyboxMod:setEntityData(bomb, "CUSTOM_BOMBFLAGS", ToyboxMod:getCustomBombFlags(bomb)&(~flags))
end