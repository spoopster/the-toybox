local mod = MilcomMOD
local sfx = SFXManager()

local DURATION = 24*60
local SPEED_UP = 0.3
local RANGE_UP = 1
local SHOTSPEED_UP = 0.3
local DMG_UP = 1
local HORSE_MULT = 1.5

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = mod:getEntityDataTable(player)
    data.VITAMINS_DURATION = DURATION
    data.VITAMINS_HORSE = isHorse
    player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_DAMAGE, true)

    sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
    player:AnimateHappy()
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_VITAMINS)

---@param player EntityPlayer
local function tempDamage(_, player, flag)
    local data = mod:getEntityDataTable(player)
    if((data.VITAMINS_DURATION or 0)<=0) then return end
    local t = data.VITAMINS_DURATION/DURATION

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+SPEED_UP*t*(data.VITAMINS_HORSE and HORSE_MULT or 1)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+RANGE_UP*40*t*(data.VITAMINS_HORSE and HORSE_MULT or 1)
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = player.ShotSpeed+SHOTSPEED_UP*t*(data.VITAMINS_HORSE and HORSE_MULT or 1)
    elseif(data.VITAMINS_HORSE and flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(player, DMG_UP*t)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, tempDamage)

---@param player EntityPlayer
local function reduceDuration(_, player)
    local data = mod:getEntityDataTable(player)
    data.VITAMINS_DURATION = data.VITAMINS_DURATION or 0
    if(data.VITAMINS_DURATION>0) then
        data.VITAMINS_DURATION = data.VITAMINS_DURATION-1
        if(data.VITAMINS_DURATION%20==0) then
            player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_DAMAGE, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, reduceDuration, 0)