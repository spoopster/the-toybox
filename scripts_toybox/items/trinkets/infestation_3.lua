

---@param npc EntityNPC
local function npcInit(_, npc)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_INFESTATION_3)) then return end
    if(npc:IsBoss() or npc:IsInvincible() or not npc.SpawnerEntity) then return end

    local mult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_INFESTATION_3)
    local desType = EntityType.ENTITY_SPIDER--(mult>1 and EntityType.ENTITY_SWARM_SPIDER or EntityType.ENTITY_SPIDER)

    if(npc.Type~=desType) then
        npc:Morph(desType,0,0,0)

        Isaac.CreateTimer(function()
            if(npc) then
                npc.State = NpcState.STATE_JUMP
                npc.V2 = Vector(0,-4)
                npc.V1 = npc.Velocity:Length()>0.01 and npc.Velocity*0.5 or RandomVector()
            end
        end, 1, 1, false)

        if(mult>1) then
            npc.HitPoints = 1
            npc.MaxHitPoints = 1
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, npcInit)