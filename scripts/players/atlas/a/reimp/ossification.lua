local mod = MilcomMOD
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_PILL,
---@param player EntityPlayer
function(_, effect, player, flags, color)
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    local right = mod:getRightmostMantleIdx(player)
    if(isHorse) then
        for i=1, right do
            mod:setMantleType(player, i, 1, mod.MANTLE_DATA.BONE.ID)
        end
    else
        mod:setMantleType(player, right, 1, mod.MANTLE_DATA.BONE.ID)
    end
end,
mod.PILL_EFFECT.OSSIFICATION)