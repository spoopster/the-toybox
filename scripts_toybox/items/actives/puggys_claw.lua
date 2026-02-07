local sfx = SFXManager()

local BASE_DMG = 0.3
local DMG_PER_COUNTER = 0.02

local HP_BASE = 12
local HP_POWER = 0.5

---@param pl EntityPlayer
local function usePuggysClaw(_, item, rng, pl, flags, slot, vdata)
    sfx:Play(ToyboxMod.SFX_ROAR, 1, 2, false, 0.9+math.random()*0.2)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, usePuggysClaw, ToyboxMod.COLLECTIBLE_PUGGYS_CLAW)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not pl:GetEffects():HasCollectibleEffect(ToyboxMod.COLLECTIBLE_PUGGYS_CLAW)) then return end

    local num = pl:GetEffects():GetCollectibleEffectNum(ToyboxMod.COLLECTIBLE_PUGGYS_CLAW)
    return val+num*BASE_DMG+(ToyboxMod:getEntityData(pl, "PUGGYS_CLAW_COUNTERS") or 0)*DMG_PER_COUNTER
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_DAMAGE)

---@param npc EntityNPC
local function increaseClawDmg(_, npc)
    if(npc.FrameCount>Game():GetRoom():GetFrameCount() and npc:GetDropRNG():RandomFloat()>=0.25) then return end

    for _, pl in ipairs(PlayerManager.GetPlayers()) do
        if(pl:GetEffects():HasCollectibleEffect(ToyboxMod.COLLECTIBLE_PUGGYS_CLAW)) then
            npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)

            local num = pl:GetEffects():GetCollectibleEffectNum(ToyboxMod.COLLECTIBLE_PUGGYS_CLAW)

            local data = ToyboxMod:getEntityDataTable(pl)
            data.PUGGYS_CLAW_COUNTERS = data.PUGGYS_CLAW_COUNTERS+num*math.min(1, npc.MaxHitPoints/HP_BASE)

            pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, increaseClawDmg)