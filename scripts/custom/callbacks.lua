local mod = MilcomMOD

--! POST_PLAYER_BOMB_DETONATE
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE,
function(_, bomb)
    if(bomb:GetSprite():GetAnimation()=="Explode") then
        local p,isIncubus = mod:getPlayerFromTear(bomb)

        if(p) then Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_BOMB_DETONATE, p, bomb, isIncubus) end
    end
end)

--! NPC_DEATH
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,
---@param entity Entity
---@param amount number
---@param source EntityRef
function(_, entity, amount, _, source, _)
    if(not (entity and entity:ToNPC() and mod:isValidEnemy(entity:ToNPC()) and entity.HitPoints<=amount)) then return end
    if(not (source.Entity)) then return end
    local p = source.Entity
    if(p.SpawnerEntity) then p = p.SpawnerEntity or p end
    p = p:ToPlayer()

    if(p) then Isaac.RunCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_KILL_NPC, entity:ToNPC(), p) end
end)