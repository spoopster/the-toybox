local STAGEHP_DEC_MULT = 1
local BOSSARMOR_DMG_MULT = 0.25

---@param npc EntityNPC
local function removeStageHP(_, npc)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_NEVERSTONE)) then return end

    local conf = EntityConfig.GetEntity(npc.Type, npc.Variant, npc.SubType)
    if(conf and conf:GetStageHP()~=0) then
        local mult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_NEVERSTONE)

        local stageHp = conf:GetStageHP()
        local stage = Game():GetLevel():GetAbsoluteStage()

        npc.MaxHitPoints = npc.MaxHitPoints-stage*stageHp
        npc.HitPoints = npc.HitPoints-stage*stageHp
        if(mult>0 and npc.MaxHitPoints>1) then
            npc.MaxHitPoints = math.max(1, npc.MaxHitPoints-(mult-1)*stageHp)
            npc.HitPoints = math.max(1, npc.HitPoints-(mult-1)*stageHp)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, removeStageHP)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@params source EntityRef
---@params frames integer
local function removeBossArmor(_, ent, amount, flags, source, frames)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_NEVERSTONE)) then return end

    local conf = EntityConfig.GetEntity(ent.Type, ent.Variant, ent.SubType)
    if(conf and conf:GetShieldStrength()~=0) then
        local mult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_NEVERSTONE)
        return {
            Damage = amount*(1+(mult-1)*BOSSARMOR_DMG_MULT),
            DamageFlags = flags | DamageFlag.DAMAGE_IGNORE_ARMOR,
            DamageCountdown = frames,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, removeBossArmor)