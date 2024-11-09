local mod = MilcomMOD
--* Super Troll Bombs devolve into Troll Bombs, Troll Bombs have a chance to never explode

local DUD_CHANCE = 0.15

---@param bomb EntityBomb
local function boomDevolveSuperTroll(_, bomb)
    if(not (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BOOM) and mod:anyPlayerHasLimitBreak())) then return end
    local newBomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, bomb.Position, bomb.Velocity, bomb.SpawnerEntity):ToBomb()
    newBomb.Flags = bomb.Flags
    newBomb.ExplosionDamage = bomb.ExplosionDamage
    newBomb:SetExplosionCountdown(bomb:GetExplosionCountdown())

    bomb:Remove()
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_BOMB_INIT, CallbackPriority.IMPORTANT, boomDevolveSuperTroll, BombVariant.BOMB_SUPERTROLL)

---@param bomb EntityBomb
local function boomMakeDudTroll(_, bomb)
    if(not (PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_BOOM) and mod:anyPlayerHasLimitBreak())) then return end
    
    if(bomb:GetDropRNG():RandomFloat()<DUD_CHANCE) then
        mod:setEntityData(bomb, "IS_TROLL_DUD", true)
        bomb:SetExplosionCountdown(100000000)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, boomMakeDudTroll, BombVariant.BOMB_TROLL)

---@param bomb EntityBomb
local function boomUpdateDudTroll(_, bomb)
    if(mod:getEntityData(bomb, "IS_TROLL_DUD")==true and bomb:GetExplosionCountdown()<=120) then
        bomb:SetExplosionCountdown(100000000)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, boomUpdateDudTroll, BombVariant.BOMB_TROLL)