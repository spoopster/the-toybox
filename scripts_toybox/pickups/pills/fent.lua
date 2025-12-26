
local sfx = SFXManager()

local DURATION = 7*60

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP)
    if(isHorse) then player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP)
    else player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true) end
    player:SetMinDamageCooldown(DURATION*(isHorse and 2 or 1))

    player:AnimateHappy()
    sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_FENT)