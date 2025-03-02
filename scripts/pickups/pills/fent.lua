local mod = MilcomMOD
local sfx = SFXManager()

local DURATION = 10*60
local DMG_MULT = 0.7

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = mod:getEntityDataTable(player)
    data.FENT_DURATION = DURATION
    data.FENT_HORSE = isHorse

    player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP)
    if(isHorse) then player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP)
    else player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true) end
    player:SetMinDamageCooldown(DURATION)

    player:AnimateHappy()
    sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_EFFECT.FENT)

---@param player EntityPlayer
local function reduceEffect(_, player)
    local data = mod:getEntityDataTable(player)
    data.FENT_DURATION = data.FENT_DURATION or 0
    if(data.FENT_DURATION>0) then
        data.FENT_DURATION = data.FENT_DURATION-1
        if(data.FENT_DURATION==0 and data.FENT_HORSE~=true) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, reduceEffect, 0)

local function cacheEval(_, player)
    local data = mod:getEntityDataTable(player)
    data.FENT_DURATION = data.FENT_DURATION or 0
    if(data.FENT_DURATION>0 and data.FENT_HORSE~=true) then
        player.Damage = player.Damage*DMG_MULT
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheEval, CacheFlag.CACHE_DAMAGE)