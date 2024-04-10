local mod = MilcomMOD

---@param spawner Entity? Default: nil — The firejet's spawner entity (firejet won't hurt spawner)
---@param damage number? Default: 3.5 — How much damage the firejet should do
---@param position Vector? Default: Room:GetCenterPos() — Where the firejet should spawn
---@param amount number? Default: 0 — How many firejets should be spawned in a line, starting from the one being currently spawned
---@param distance Vector? Default: Vector(40,0) - Distance vector between 2 firejets
---@param delay number? Default: 5 — Delay (in frames) between 2 firejets in a line being spawned
---@param angleVar number? Default: 0 — Random angle variance added on top of the base angle from the interval (-angleVar/2, angleVar/2)
---@param color Color? Default: Color(1,1,1,1,0,0,0) — Color of the firejet
---@param isPlayerFriendly boolean? Default: false — Will it deal damage to players?
---@return EntityEffect?
function mod:spawnFireJet(spawner, damage, position, amount, delay, distance, angleVar, color, isPlayerFriendly)
    position = position or Game():GetRoom():GetCenterPos()
    if(Game():GetRoom():IsPositionInRoom(position, 10) and Game():GetRoom():GetGridCollisionAtPos(position)==GridCollisionClass.COLLISION_NONE) then
        local fireJet = Isaac.Spawn(1000,EffectVariant.FIRE_JET,0, position, Vector.Zero, (spawner or nil)):ToEffect()

        fireJet.CollisionDamage = (damage or 3.5)
        fireJet.Timeout = (delay or 5)
        fireJet.Color = (color or Color(1,1,1,1))

        local data = mod:getEntityDataTable(fireJet)

        data.FIREJET_IS_CUSTOM_FIREJET = true
        data.FIREJET_SPAWN_DELAY = fireJet.Timeout
        data.FIREJET_SPAWN_DISTANCE = (distance or Vector(40,0))
        data.FIREJET_ANGLE_VAR = (angleVar or 0)
        data.FIREJET_SPAWNS_LEFT = (amount or 1)-1
        data.FIREJET_IS_PLAYER_FRIENDLY = (isPlayerFriendly or false)

        if(fireJet.Timeout==0) then fireJet:Update() end

        return fireJet
    else
        return nil
    end
end

---@param effect EntityEffect
local function customFireJetUpdate(_, effect)
    local data = mod:getEntityDataTable(effect)
    if(not data.FIREJET_IS_CUSTOM_FIREJET) then return end

    if(effect.Timeout==0 and data.FIREJET_SPAWNS_LEFT>0) then
        local rng = effect:GetDropRNG()

        local angleRot = (rng:RandomFloat()-0.5)*data.FIREJET_ANGLE_VAR
        local nextPos = effect.Position+data.FIREJET_SPAWN_DISTANCE:Rotated(angleRot)

        effect.Timeout = -1

        local newJet = mod:spawnFireJet(
            effect.SpawnerEntity,
            effect.CollisionDamage,
            nextPos,
            data.FIREJET_SPAWNS_LEFT,
            data.FIREJET_SPAWN_DELAY,
            data.FIREJET_SPAWN_DISTANCE:Rotated(angleRot),
            data.FIREJET_ANGLE_VAR,
            effect.Color,
            data.FIREJET_IS_PLAYER_FRIENDLY
        )
        if(newJet) then
            newJet.Scale = effect.Scale
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, customFireJetUpdate, EffectVariant.FIRE_JET)

local function customFireJetOnDMG(_, tookDmg, _, _, source)
    if(not (source.Entity and source.Entity:ToEffect() and source.Entity.Variant==EffectVariant.FIRE_JET)) then return end
    local e = source.Entity:ToEffect()
    local data = mod:getEntityDataTable(e)

    if(data.FIREJET_IS_CUSTOM_FIREJET) then
        if(e.SpawnerEntity and GetPtrHash(e.SpawnerEntity)==GetPtrHash(tookDmg)) then return false end
        if(data.FIREJET_IS_PLAYER_FRIENDLY and tookDmg.Type==EntityType.ENTITY_PLAYER) then return false end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, customFireJetOnDMG)

local function customFireJetOnPlayerDMG(_, tookDmg, _, _, source)
    if(not (source.Entity and source.Entity:ToEffect() and source.Entity.Variant==EffectVariant.FIRE_JET)) then return end
    local e = source.Entity:ToEffect()
    local data = mod:getEntityDataTable(e)

    if(data.FIREJET_IS_CUSTOM_FIREJET) then
        if(e.SpawnerEntity and GetPtrHash(e.SpawnerEntity)==GetPtrHash(tookDmg)) then return false end
        if(data.FIREJET_IS_PLAYER_FRIENDLY) then return false end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, customFireJetOnPlayerDMG)