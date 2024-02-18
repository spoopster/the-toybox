local mod = MilcomMOD

mod:AddPriorityCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, math.huge,
---@param e Entity
---@param w Weapon
function(_, fd, fa, e, w)
    if(not (e and e:ToPlayer())) then return end
    local p = e:ToPlayer()

    if(not mod:getData(p, "LAST_LUDO_POS")) then mod:setData(p, "LAST_LUDO_POS", fd) end

    mod:setData(p, "LAST_LUDO_POS", fd)
end,
WeaponType.WEAPON_LUDOVICO_TECHNIQUE)
function mod:shouldTriggerLudoMove(p, fd)
    return (fd-(mod:getData(p, "LAST_LUDO_POS") or Vector.Zero)):Length()>1
end