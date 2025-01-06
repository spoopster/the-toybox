local mod = MilcomMOD

---@param npc EntityNPC
local function tryMakeModChampion(_, npc)
    if(not (npc:IsChampion())) then return end

    if(npc:GetDropRNG():RandomFloat()<mod.CONFIG.MOD_CHAMPION_CHANCE) then
        local outcome = mod.CUSTOM_CHAMPION_IDX_TO_NAME[mod.CUSTOM_CHAMPION_PICKER:PickOutcome(npc:GetDropRNG())]

        mod.DENY_CHAMP_ROLL = true
        local newNpc
        while(not (newNpc and newNpc:Exists())) do
            newNpc = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, npc.Velocity, npc.SpawnerEntity):ToNPC()
            if(newNpc:IsChampion()) then
                newNpc:Remove()
            end
        end
        mod.DENY_CHAMP_ROLL = false
        npc:Remove()

        local result = mod.CUSTOM_CHAMPIONS[outcome]

        mod:setEntityData(newNpc, "CUSTOM_CHAMPION_IDX", result.Idx)
        newNpc.Color = result.Color
        newNpc.MaxHitPoints = newNpc.MaxHitPoints*result.HPMult
        newNpc.HitPoints = newNpc.HitPoints*result.HPMult
        if(newNpc.CollisionDamage>0) then
            newNpc.CollisionDamage = 2
        end
        newNpc.Scale = newNpc.Scale*1.15

        Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_CUSTOM_CHAMPION_INIT, result.Idx, newNpc, result.Idx)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, tryMakeModChampion)

local function championProjDealDamage(_, _, amount, flags, source, frames)
    source = source.Entity
    if(not (source and source:ToProjectile())) then return end

    local npc = source.SpawnerEntity
    if(not (npc and npc:ToNPC() and mod:getEntityData(npc:ToNPC(), "CUSTOM_CHAMPION_IDX"))) then return end

    if(amount>0) then
        return {
            Damage = 2,
            DamageFlags = flags,
            DamageCountdown = frames,
        }
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -math.huge, championProjDealDamage, EntityType.ENTITY_PLAYER)