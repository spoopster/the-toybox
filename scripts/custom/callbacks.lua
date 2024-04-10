local mod = MilcomMOD

--! POST_PLAYER_BOMB_DETONATE
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE,
function(_, bomb)
    if(bomb:GetSprite():GetAnimation()=="Explode") then
        local p,isIncubus = mod:getPlayerFromTear(bomb)

        if(p) then Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_BOMB_DETONATE, p, bomb, isIncubus) end
    end
end)

--! NPC_DEATH
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, math.huge,
---@param entity Entity
---@param amount number
---@param source EntityRef
function(_, entity, amount, _, source, _)
    if(not (entity and entity:ToNPC() and mod:isValidEnemy(entity:ToNPC()) and entity.HitPoints<=amount)) then return end
    if(not (source.Entity)) then return end
    local p = source.Entity
    if(p.SpawnerEntity) then p = p.SpawnerEntity or p end
    p = p:ToPlayer()

    if(p) then Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_KILL_NPC, entity:ToNPC(), p) end
end)

--! POST_PLAYER_ATTACK
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

--! POST_PLAYER_DOUBLE_TAP

local DIRECTION_FLUSH_MOD = 10
local LAST_FIRE_DIRECTIONS = {}

local function cloneTable(t)
    local tClone = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            tClone[key] = cloneTable(val)
        else
            tClone[key]=val
        end
    end
    return tClone
end

local function shouldActivateDoubletap(player)
    local playerPtr = GetPtrHash(player)
    local fireDirections = LAST_FIRE_DIRECTIONS[playerPtr]

    if fireDirections[1] == fireDirections[3] and fireDirections[2] == Direction.NO_DIRECTION and fireDirections[3] ~= Direction.NO_DIRECTION then
        return true
    end

    return false
end

local function postPlayerUpdate(_, player)
    local playerPtr = GetPtrHash(player)
    if not LAST_FIRE_DIRECTIONS[playerPtr] then
        LAST_FIRE_DIRECTIONS[playerPtr] = {
            Direction.NO_DIRECTION,
            Direction.NO_DIRECTION,
            Direction.NO_DIRECTION,
        }
    end

    local lastFireDirections = LAST_FIRE_DIRECTIONS[playerPtr]
    local tableClone = cloneTable(lastFireDirections)

    local fireDirection = player:GetFireDirection()
    if lastFireDirections[1] ~= fireDirection or Game():GetFrameCount() % DIRECTION_FLUSH_MOD == 0 then
        for i = 1, #lastFireDirections do
            lastFireDirections[i + 1] = tableClone[i]
        end
        lastFireDirections[#lastFireDirections] = nil

        lastFireDirections[1] = fireDirection
    end

    if shouldActivateDoubletap(player) then
        Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_DOUBLE_TAP, player)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate)