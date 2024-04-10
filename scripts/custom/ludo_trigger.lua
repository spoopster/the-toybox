local mod = MilcomMOD

mod:AddPriorityCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, math.huge,
---@param e Entity
---@param w Weapon
function(_, fd, fa, e, w)
    if(not (e and e:ToPlayer())) then return end
    mod:setEntityData(e, "LAST_LUDO_POS", fd)
end,
WeaponType.WEAPON_LUDOVICO_TECHNIQUE)
function mod:shouldTriggerLudoMove(p)
    if(p.Type==EntityType.ENTITY_PLAYER) then
        if(p:ToPlayer():GetShootingJoystick():Length()>0.01) then return true end
    elseif(p.Type==EntityType.ENTITY_FAMILIAR) then
        if(p:ToFamiliar().Player:GetShootingJoystick():Length()>0.01) then return true end
    end

    return false
end