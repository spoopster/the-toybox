local mod = MilcomMOD
local sfx = SFXManager()

---@param player EntityPlayer
local function resetPillBonus(player, forcesfx)
    if(player:GetPlayerType()~=mod.PLAYER_JONAS_A) then return end
    local data = mod:getJonasATable(player)

    local hadBonus = ((data.PILL_BONUS_COUNT or 0)>0)
    local hadPopped = ((data.PILLS_POPPED or 0)>0)

    data.PILLS_POPPED = 0
    data.PILLS_FOR_BONUS = data.PILLS_FOR_BONUS_BASE
    data.PILLS_FOR_NEXT_BONUS = data.PILLS_FOR_BONUS
    data.PILL_BONUS_COUNT = 0
    data.RESET_BOOST_ROOMS = 0

    if(hadBonus) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK, true)
    end

    if(hadBonus or hadPopped) then
        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        player:AnimateSad()
    end
end

---@param player EntityPlayer
local function addPillBonus(_, pillEffect, player, flags, pillColor)
    if(player:GetPlayerType()~=mod.PLAYER_JONAS_A) then return end
    local data = mod:getJonasATable(player)

    local bonusInc = 1
    if(pillColor & PillColor.PILL_GIANT_FLAG ~= 0) then bonusInc = bonusInc*(data.PILBONUS_HORSE_MULT or 2) end
    if((pillColor & ~PillColor.PILL_GIANT_FLAG) == PillColor.PILL_GOLD) then bonusInc = bonusInc*(data.PILBONUS_GOLD_MULT or 0.2) end

    data.PILLS_POPPED = (data.PILLS_POPPED or 0)+bonusInc
    data.RESET_BOOST_ROOMS = 0

    if(data.PILLS_POPPED>=(data.PILLS_FOR_NEXT_BONUS or data.PILLS_FOR_BONUS or data.PILLS_FOR_BONUS_BASE or 3)) then
        data.PILL_BONUS_COUNT = (data.PILL_BONUS_COUNT or 0)+1
        data.PILLS_FOR_BONUS = (data.PILLS_FOR_BONUS_BASE or 3)+data.PILLBONUS_INCREMENT*math.floor(data.PILL_BONUS_COUNT/(data.PILLBONUS_INCREMENT_BONUSES or 2))
        data.PILLS_FOR_NEXT_BONUS = (data.PILLS_FOR_NEXT_BONUS or 0)+data.PILLS_FOR_BONUS

        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_LUCK, true)
        sfx:Play(SoundEffect.SOUND_THUMBSUP_AMPLIFIED)
        player:AnimateHappy()
    end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, addPillBonus)

local function incrementBonusReset()
    for _, player in ipairs(Isaac.FindByType(1,0,mod.PLAYER_JONAS_A)) do
        player = player:ToPlayer()
        local data = mod:getJonasATable(player)

        data.RESET_BOOST_ROOMS = data.RESET_BOOST_ROOMS+1
        if(data.RESET_BOOST_ROOMS>=data.RESET_BOOST_ROOMSREQ) then
            resetPillBonus(player)
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.LATE, incrementBonusReset)

local function resetBonusNewLevel(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_JONAS_A) then return end
    if(player.FrameCount==0) then return end

    resetPillBonus(player)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, resetBonusNewLevel)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalBonus(_, player, flag)
    if(player:GetPlayerType()~=mod.PLAYER_JONAS_A) then return end
    local data = mod:getJonasATable(player)
    if(data.PILL_BONUS_COUNT==0 or not data.PILL_BONUS_COUNT) then return end
    local mult = data.PILL_BONUS_COUNT or 0

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+(data.PILLBONUS_SPEED or 0.1)*mult
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(player, (data.PILLBONUS_TEARS or 0.2)*mult)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(player, (data.PILLBONUS_DMG or 0.3)*mult)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+40*(data.PILLBONUS_RANGE or 0.3)*mult
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+(data.PILLBONUS_SHOTSPEED or 0.05)*mult
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+(data.PILLBONUS_LUCK or 0.6)*mult
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalBonus)

---@param player EntityPlayer
local function ahhIAmExperiencingWithdrawalPleaseHelp(_, player, offset)
    if(player:GetPlayerType()~=mod.PLAYER_JONAS_A) then return end
    local data = mod:getJonasATable(player)
    if(not data) then return end
    if(not (data.PILLS_POPPED>0 or data.PILL_BONUS_COUNT>0)) then return end
    
    local dif = (data.RESET_BOOST_ROOMSREQ or 0)-(data.RESET_BOOST_ROOMS or 0)
    if(dif<=(data.RESET_BOOST_SHAKECLOSENESS or 2)) then
        dif = (data.RESET_BOOST_SHAKECLOSENESS or 2)-dif+1
        return Vector((player.FrameCount%2-0.5)*2*dif*(data.RESET_BOOST_SHAKEINTENSITY or 1), 0)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, ahhIAmExperiencingWithdrawalPleaseHelp)