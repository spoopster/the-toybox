---@param effect EntityEffect
local function replaceHelper(_, effect)
    if(effect.SubType==ToyboxMod.GRID_PLAYERONLY_BLOCK) then
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
                data.PLAYERONLY_GATE = true

                block:Update()
            end
        end
        effect:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, replaceHelper, ToyboxMod.EFFECT_GRID_HELPER)

local function gridInit(_, ent, _, _)
    if(not ToyboxMod:getGridEntityData(ent, "PLAYERONLY_GATE")) then return end
    ent:GetSprite():Load("gfx_tb/grid/grid_player_gate.anm2", true)
    ent:GetSprite():Play("black", true)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, gridInit, GridEntityType.GRID_ROCKB)

---@param ent Entity
local function cancelGridColl(_, ent, idx, grident)
    if(grident and ToyboxMod:getGridEntityData(grident, "PLAYERONLY_GATE")) then
        if(ent:ToNPC()) then
            if(ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
                return true
            end
        elseif(ent:ToLaser() or ent:ToBomb()) then
            if(ToyboxMod:getPlayerFromEnt(ent)) then
                return true
            end
        else
            return true
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, cancelGridColl)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_TEAR_GRID_COLLISION, cancelGridColl)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_GRID_COLLISION, cancelGridColl)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NPC_GRID_COLLISION, cancelGridColl)
--ToyboxMod:AddCallback(ModCallbacks.MC_PRE_LASER_GRID_COLLISION, cancelGridColl)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_BOMB_GRID_COLLISION, cancelGridColl)