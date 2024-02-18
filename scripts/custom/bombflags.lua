local mod = MilcomMOD

---@param bomb EntityBomb
local function initFlags(_, bomb)
    mod:setData(bomb, "CUSTOM_BOMBFLAGS", 0)
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, initFlags)
---@param bomb EntityBomb
function mod:getCustomBombFlags(bomb)
    return (mod:getData(bomb, "CUSTOM_BOMBFLAGS") or 0)
end
---@param bomb EntityBomb
function mod:addCustomBombFlags(bomb, flags)
    mod:setData(bomb, "CUSTOM_BOMBFLAGS", mod:getCustomBombFlags(bomb)|flags)
end
---@param bomb EntityBomb
function mod:removeCustomBombFlags(bomb, flags)
    mod:setData(bomb, "CUSTOM_BOMBFLAGS", mod:getCustomBombFlags(bomb)&(~flags))
end