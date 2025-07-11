
local sfx = SFXManager()

local DURATION = 18*60
local HORSE_DURATION = 27*60
local MINDMG = 0.5
local HORSE_DMGDOWN = -0.1

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = ToyboxMod:getEntityDataTable(player)
    data.ATROPHY_DURATION = (isHorse and HORSE_DURATION or DURATION)
    data.ATROPHY_MAXDURATION = data.ATROPHY_DURATION
    data.ATROPHY_HORSESTACKS = (data.ATROPHY_HORSESTACKS or 0)+(isHorse and 1 or 0)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
    player:AnimateSad()
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_EFFECT.MUSCLE_ATROPHY)

local function cacheEval(_, player, flag)
    local data = ToyboxMod:getEntityDataTable(player)
    if((data.ATROPHY_HORSESTACKS or 0)<=0) then return end

    ToyboxMod:addBasicDamageUp(player, HORSE_DMGDOWN*data.ATROPHY_HORSESTACKS)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheEval, CacheFlag.CACHE_DAMAGE)

local function tempDamage(_, player, flag)
    local data = ToyboxMod:getEntityDataTable(player)
    if((data.ATROPHY_DURATION or 0)<=0) then return end

    local t = 1-data.ATROPHY_DURATION/(data.ATROPHY_MAXDURATION or DURATION)
    player.Damage = ToyboxMod:lerp(MINDMG, player.Damage, t)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, tempDamage, CacheFlag.CACHE_DAMAGE)

---@param player EntityPlayer
local function reduceDuration(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    data.ATROPHY_DURATION = data.ATROPHY_DURATION or 0
    if(data.ATROPHY_DURATION>0) then
        data.ATROPHY_DURATION = data.ATROPHY_DURATION-1
        if(data.ATROPHY_DURATION%30==0) then player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true) end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, reduceDuration, 0)