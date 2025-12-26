
local sfx = SFXManager()

local DMG_DOWN = -0.4

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = ToyboxMod:getEntityDataTable(player)
    data.DAMAGE_DOWN_STACKS = (data.DAMAGE_DOWN_STACKS or 0)+(isHorse and 2 or 1)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
    player:AnimateSad()
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_DMG_DOWN)

---@param pl EntityPlayer
---@param val number
local function evaluateDamage(_, pl, _, val)
    local stacks = (ToyboxMod:getEntityData(pl, "DAMAGE_DOWN_STACKS") or 0)
    return val+stacks*DMG_DOWN
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evaluateDamage, EvaluateStatStage.DAMAGE_UP)