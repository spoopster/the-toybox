
local sfx = SFXManager()

local DMG_UP = 0.5

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = ToyboxMod:getEntityDataTable(player)
    data.DAMAGE_UP_STACKS = (data.DAMAGE_UP_STACKS or 0)+(isHorse and 2 or 1)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

    sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
    player:AnimateHappy()
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_DMG_UP)

---@param pl EntityPlayer
---@param val number
local function evaluateDamage(_, pl, _, val)
    local stacks = (ToyboxMod:getEntityData(pl, "DAMAGE_UP_STACKS") or 0)
    return val+stacks*DMG_UP
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evaluateDamage, EvaluateStatStage.DAMAGE_UP)