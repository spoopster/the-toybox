
local sfx = SFXManager()

local DMG_DOWN = -0.35

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = ToyboxMod:getEntityDataTable(player)
    data.DAMAGE_DOWN_STACKS = (data.DAMAGE_DOWN_STACKS or 0)+(isHorse and 2 or 1)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
    player:AnimateSad()
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_EFFECT.DMG_DOWN)

local function cacheEval(_, player, flag)
    local data = ToyboxMod:getEntityDataTable(player)
    if((data.DAMAGE_DOWN_STACKS or 0)<=0) then return end

    ToyboxMod:addBasicDamageUp(player, DMG_DOWN*data.DAMAGE_DOWN_STACKS)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheEval, CacheFlag.CACHE_DAMAGE)