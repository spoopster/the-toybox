local mod = MilcomMOD
--// this is the worst code i have ever written
--*nvm

local ENUM_FIREDELAY_MULT = 1.15
local ENUM_DAMAGE_MULT = 0.85

local ENUM_FIREDELAY_ROOT = 11.75
local ENUM_DAMAGE_ROOT = 13.25

local ENUM_EXTRACOLLECTIBLES_POW = 2
local ENUM_STATDECREASE_MULT = 5/6

local STAT_DECREASE_TIMER_LENIENCY = 20

local function increaseCondensedMilkBonus(player, increaseMod)
    local data = mod:getDataTable(player)

    local bonus = (2.73/mod:getTps(player))*(player:GetCollectibleNum(mod.COLLECTIBLE_CONDENSED_MILK)^ENUM_EXTRACOLLECTIBLES_POW)*increaseMod

    data.CONDENSED_MILK_BONUS = data.CONDENSED_MILK_BONUS+bonus
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)
end

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_CONDENSED_MILK)

    local bonus = mod:getData(player, "CONDENSED_MILK_BONUS") or 1
    if(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay*(ENUM_FIREDELAY_MULT^mult)/(bonus^(1/ENUM_FIREDELAY_ROOT))
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*(ENUM_DAMAGE_MULT^mult)*(bonus^(1/ENUM_DAMAGE_ROOT))
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function milkBonusUpdateLogic(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then
        if(mod:getData(player, "CONDENSED_MILK_BONUS")~=nil) then
            mod:setData(player, "CONDENSED_MILK_BONUS", nil)
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE, true)
        end

        return
    end

    local data = mod:getDataTable(player)
    data.CONDENSED_MILK_BONUS = data.CONDENSED_MILK_BONUS or 1
    data.TIME_WITHOUT_FIRING = data.TIME_WITHOUT_FIRING or 0
    data.FAMILIAR_FIRED_NUM = 0

    local activeWeapon = player:GetActiveWeaponEntity()

    local shouldStartIncreasingTimer = true
    local timerOffset = 0
    if(not (player:GetShootingJoystick():Length()<0.01)) then shouldStartIncreasingTimer=false end
    if(activeWeapon and activeWeapon.Type==7 and activeWeapon.Variant==1) then
        shouldStartIncreasingTimer = false
    elseif(activeWeapon and activeWeapon.Type==8 and activeWeapon.Variant==0 and activeWeapon.SubType==0) then
        if(math.abs((activeWeapon.Position-player.Position+player.Velocity):Length()-30) > 5) then shouldStartIncreasingTimer=false end
    elseif(activeWeapon and activeWeapon.Type==1000 and activeWeapon.Variant==30 and activeWeapon.SubType==0) then
        shouldStartIncreasingTimer = false
    elseif(activeWeapon and activeWeapon.Type==3 and activeWeapon.Variant==240 and activeWeapon.SubType==0) then
        shouldStartIncreasingTimer = false
    elseif(activeWeapon and activeWeapon.Type==8 and activeWeapon.Variant==1 and activeWeapon.SubType==0) then
        if(math.abs((activeWeapon.Position-player.Position+player.Velocity):Length()-4) > 5) then shouldStartIncreasingTimer=false end
        if(activeWeapon:GetSprite():GetAnimation()=="Swing" and activeWeapon:GetSprite():GetFrame()~=9) then shouldStartIncreasingTimer=false end
    end

    for i=1, 4 do
        local w = player:GetWeapon(i)

        if(w) then
            if(w:GetWeaponType()==WeaponType.WEAPON_MONSTROS_LUNGS) then timerOffset = timerOffset+20 end
            if(w:GetWeaponType()==WeaponType.WEAPON_TECH_X) then timerOffset = timerOffset+20 end
            if(w:GetWeaponType()==WeaponType.WEAPON_SPIRIT_SWORD) then timerOffset = timerOffset+15 end
            if(w:GetWeaponType()==WeaponType.WEAPON_BONE and w:GetFireDelay()>0) then shouldStartIncreasingTimer=false end
        end
    end

    if(shouldStartIncreasingTimer) then data.TIME_WITHOUT_FIRING=data.TIME_WITHOUT_FIRING+1
    elseif(data.TIME_WITHOUT_FIRING~=0) then data.TIME_WITHOUT_FIRING=0 end

    if(data.TIME_WITHOUT_FIRING>=STAT_DECREASE_TIMER_LENIENCY+timerOffset) then
        if(data.CONDENSED_MILK_BONUS>1) then
            data.CONDENSED_MILK_BONUS = math.max(1, data.CONDENSED_MILK_BONUS*ENUM_STATDECREASE_MULT)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, milkBonusUpdateLogic)

local function playerAttack(_, ent, weap, dir, cMod)
    local p = ent:ToPlayer()
    if(p and p:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then
        increaseCondensedMilkBonus(p, cMod)
    elseif(ent.Type==EntityType.ENTITY_FAMILIAR and ent:ToFamiliar().Player and ent:ToFamiliar().Player:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then
        ent = ent:ToFamiliar()
        p = ent.Player:ToPlayer()
        local data = mod:getDataTable(p)

        if(ent.Variant==FamiliarVariant.INCUBUS) then
            increaseCondensedMilkBonus(p, cMod/3)
        elseif(ent.Variant==FamiliarVariant.TWISTED_BABY) then
            increaseCondensedMilkBonus(p, cMod/6)
        elseif(ent.Variant==FamiliarVariant.UMBILICAL_BABY) then
            increaseCondensedMilkBonus(p, cMod/5)
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_ATTACK, playerAttack)