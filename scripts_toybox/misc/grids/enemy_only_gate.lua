---@param effect EntityEffect
local function replaceHelper(_, effect)
    if(effect.SubType==ToyboxMod.GRID_ENEMYONLY_BLOCK) then
        effect.Visible = false
        local room = Game():GetRoom()
        local idx = room:GetGridIndex(effect.Position)

        room:RemoveGridEntityImmediate(idx, 0, false)
        local worked = room:SpawnGridEntity(idx, GridEntityType.GRID_ROCKB, 0, effect.InitSeed)
        if(worked) then
            local block = room:GetGridEntity(idx)
            if(block) then
                local data = ToyboxMod:getGridEntityDataTable(block)
                data.GRID_INIT = nil
                data.ENEMYONLY_GATE = true

                block:Update()
            end
        end
        effect:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, replaceHelper, ToyboxMod.EFFECT_GRID_HELPER)

---@param ent GridEntity
local function gridInit(_, ent, _, _)
    if(not ToyboxMod:getGridEntityData(ent, "ENEMYONLY_GATE")) then return end
    ent:GetSprite():Load("gfx_tb/grid/grid_enemy_gate.anm2", true)
    ent:GetSprite():Play("black", true)

    Game():GetRoom():SetGridPath(ent:GetGridIndex(), 0)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, gridInit, GridEntityType.GRID_ROCKB)

---@param ent Entity
local function cancelGridColl(_, ent, idx, grident)
    if(grident and ToyboxMod:getGridEntityData(grident, "ENEMYONLY_GATE")) then
        if(ent:ToNPC()) then
            if(not (ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then
                return true
            end
        elseif(ent:ToLaser() or ent:ToBomb()) then
            if(not ToyboxMod:getPlayerFromEnt(ent)) then
                return true
            end
        else
            return true
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, cancelGridColl)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_BOMB_GRID_COLLISION, cancelGridColl)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_GRID_COLLISION, cancelGridColl)

---@param npc EntityNPC
local function postnpcrender(_, npc)
    local room = Game():GetRoom()
    local idx = room:GetGridIndex((npc.Position))
    local ent = room:GetGridEntity(idx)
    if(not (ent and ToyboxMod:getGridEntityData(ent, "ENEMYONLY_GATE"))) then return end

    local centerpos = room:GetGridPosition(idx)
    local dist = centerpos:Distance(npc.Position)/20
    local frac = dist
    if(centerpos.X+centerpos.Y>npc.Position.X+npc.Position.Y) then frac = -dist end

    return Vector(0, -math.abs(dist-1)*40)
end
--ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, postnpcrender)