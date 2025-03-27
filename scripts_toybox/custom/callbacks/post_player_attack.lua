local mod = ToyboxMod

mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED,
---@param e Entity
---@param w Weapon
function(_, fd, fa, e, w)
    if(e==nil) then return end

    local wType = w:GetWeaponType()
    local wCharge = w:GetCharge()
    local wModifier = w:GetModifiers()
    local wFd = w:GetFireDelay()

    if(wType==WeaponType.WEAPON_TEARS) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 1)
    elseif(wType==WeaponType.WEAPON_BRIMSTONE) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 0.1)
    elseif(wType==WeaponType.WEAPON_LASER) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 1)
    elseif(wType==WeaponType.WEAPON_KNIFE) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, wCharge/(w:GetMaxFireDelay()*4))
    elseif(wType==WeaponType.WEAPON_BOMBS) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 1)
    elseif(wType==WeaponType.WEAPON_ROCKETS) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 1)
    elseif(wType==WeaponType.WEAPON_MONSTROS_LUNGS) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 1)
    elseif(wType==WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
        if(mod:shouldTriggerLudoMove(e)) then
            Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 1)
        end
    elseif(wType==WeaponType.WEAPON_TECH_X) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, wCharge/math.ceil(w:GetMaxFireDelay()*3))
    elseif(wType==WeaponType.WEAPON_BONE) then
        if(wCharge>0) then
            Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, wCharge/(w:GetMaxFireDelay()*3))
        else
            Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 1)
        end
    elseif(wType==WeaponType.WEAPON_SPIRIT_SWORD) then
        if(wFd==-1) then
            Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 6)
        else
            Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 1)
        end
    elseif(wType==WeaponType.WEAPON_FETUS) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 2.5)
    elseif(wType==WeaponType.WEAPON_UMBILICAL_WHIP) then
        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, wType, e, w, fd, 10)
    end
end
)