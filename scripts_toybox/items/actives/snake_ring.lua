local sfx = SFXManager()

local BASE_TEARS = 0.0
local TEARS_PER_COUNTER = 0.1

---@param pl EntityPlayer
local function useSnakeRing(_, item, rng, pl, flags, slot, vdata)
    sfx:Play(SoundEffect.SOUND_BOSS_LITE_HISS, 1, 2, false, 0.95+math.random()*0.1)

    local data = ToyboxMod:getEntityDataTable(pl)
    data.SNAKE_RING_COUNTERS = (data.SNAKE_RING_COUNTERS or 0)+1

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useSnakeRing, ToyboxMod.COLLECTIBLE_SNAKE_RING)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not pl:GetEffects():HasCollectibleEffect(ToyboxMod.COLLECTIBLE_SNAKE_RING)) then return end

    local num = pl:GetEffects():GetCollectibleEffectNum(ToyboxMod.COLLECTIBLE_SNAKE_RING)
    return val+BASE_TEARS+(ToyboxMod:getEntityData(pl, "SNAKE_RING_COUNTERS") or 0)*TEARS_PER_COUNTER
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_TEARS)