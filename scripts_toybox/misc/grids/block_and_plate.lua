local sfx = SFXManager()

local SWITCH_BLOCK_SUB_GROUPS = {
    [ToyboxMod.GRID_SWITCH_BLOCK_1] = 1,
    [ToyboxMod.GRID_SWITCH_BLOCK_2] = 2,
    [ToyboxMod.GRID_SWITCH_BLOCK_3] = 3,
    [ToyboxMod.GRID_SWITCH_BLOCK_4] = 4,
    [ToyboxMod.GRID_SWITCH_BLOCK_INACTIVE_1] = 1,
    [ToyboxMod.GRID_SWITCH_BLOCK_INACTIVE_2] = 2,
    [ToyboxMod.GRID_SWITCH_BLOCK_INACTIVE_3] = 3,
    [ToyboxMod.GRID_SWITCH_BLOCK_INACTIVE_4] = 4,
}
local SWITCH_BLOCK_SUB_INACTIVE = {
    [ToyboxMod.GRID_SWITCH_BLOCK_INACTIVE_1] = true,
    [ToyboxMod.GRID_SWITCH_BLOCK_INACTIVE_2] = true,
    [ToyboxMod.GRID_SWITCH_BLOCK_INACTIVE_3] = true,
    [ToyboxMod.GRID_SWITCH_BLOCK_INACTIVE_4] = true,
}

local SWITCH_PLATE_SUB_GROUPS = {
    [ToyboxMod.GRID_SWITCH_PLATE_1] = 1,
    [ToyboxMod.GRID_SWITCH_PLATE_2] = 2,
    [ToyboxMod.GRID_SWITCH_PLATE_3] = 3,
    [ToyboxMod.GRID_SWITCH_PLATE_4] = 4,
}

---@param effect EntityEffect
local function replaceHelper(_, effect)
    if(SWITCH_BLOCK_SUB_GROUPS[effect.SubType]) then
        local room = Game():GetRoom()
        local idx = room:GetGridIndex(effect.Position)
        local worked = room:SpawnGridEntity(idx, GridEntityType.GRID_PILLAR, 0, effect.InitSeed)
        if(worked) then
            local block = room:GetGridEntity(idx)
            if(block) then
                local data = ToyboxMod:getGridEntityDataTable(block)
                data.SWITCH_BLOCK = true
                data.SWITCH_GRID = SWITCH_BLOCK_SUB_GROUPS[effect.SubType]
                block.State = (SWITCH_BLOCK_SUB_INACTIVE[effect.SubType] and 2 or 1)

                block:Update()
            end
        end

        effect.Visible = false
        effect:Remove()
    elseif(SWITCH_PLATE_SUB_GROUPS[effect.SubType]) then
        local room = Game():GetRoom()
        local idx = room:GetGridIndex(effect.Position)
        local worked = room:SpawnGridEntity(idx, GridEntityType.GRID_PRESSURE_PLATE, 1, effect.InitSeed)
        if(worked) then
            local block = room:GetGridEntity(idx)
            if(block) then
                local data = ToyboxMod:getGridEntityDataTable(block)
                data.SWITCH_PLATE = true
                data.SWITCH_GRID = SWITCH_PLATE_SUB_GROUPS[effect.SubType]
                block.State = 0

                block:Update()
            end
        end

        effect.Visible = false
        effect:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, replaceHelper, ToyboxMod.EFFECT_GRID_HELPER)

---@param ent GridEntity
local function getBlockNeighborhood(ent)
    local group = ToyboxMod:getGridEntityData(ent, "SWITCH_GRID") or 1

    local adj = {}
    local otherplates = {}

    local room = Game():GetRoom()
    for i=0, room:GetGridSize()-1 do
        local grid = room:GetGridEntity(i)
        if(grid and ToyboxMod:getGridEntityData(grid, "SWITCH_GRID")==group) then
            if(ToyboxMod:getGridEntityData(grid, "SWITCH_BLOCK")) then
                table.insert(adj, i)
            elseif(ToyboxMod:getGridEntityData(grid, "SWITCH_PLATE")) then
                table.insert(otherplates, i)
            end
        end
    end

    for _, idx in ipairs(otherplates) do
        ToyboxMod:setGridEntityData(room:GetGridEntity(idx), "SWITCH_PLATE_NEIGHBORHOOD", adj)
        ToyboxMod:setGridEntityData(room:GetGridEntity(idx), "SWITCH_VISITED", true)
    end
    for _, idx in ipairs(adj) do
        ToyboxMod:setGridEntityData(room:GetGridEntity(idx), "SWITCH_VISITED", true)
    end
end

local function getGridGroupsOnRoomEntry(_)
    local room = Game():GetRoom()
    for i=0, room:GetGridSize()-1 do
        local ent = room:GetGridEntity(i)
        if(ent and ToyboxMod:getGridEntityData(ent, "SWITCH_GRID") and not ToyboxMod:getGridEntityData(ent, "SWITCH_VISITED")) then
            getBlockNeighborhood(ent)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, getGridGroupsOnRoomEntry)

---@param ent GridEntity
local function switchBlockInit(_, ent, _, _)
    if(not ToyboxMod:getGridEntityData(ent, "SWITCH_BLOCK")) then return end

    local sp = ent:GetSprite()
    sp:Load("gfx_tb/grid/grid_switch_block.anm2", false)
    sp:ReplaceSpritesheet(0, "gfx_tb/grid/grid_switch_block_"..tostring(ToyboxMod:getGridEntityData(ent, "SWITCH_GRID") or 1)..".png", true)
    sp:Play((ent.State==2 and "black-retract" or "black"), true)
    sp:SetFrame(sp:GetCurrentAnimationData():GetLength()-1)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, switchBlockInit, GridEntityType.GRID_PILLAR)

---@param ent GridEntity
local function switchPlateInit(_, ent, _, _)
    if(not ToyboxMod:getGridEntityData(ent, "SWITCH_PLATE")) then return end

    local sp = ent:GetSprite()
    sp:Load("gfx_tb/grid/grid_switch.anm2", true)
    sp:ReplaceSpritesheet(0, "gfx_tb/grid/grid_switch_"..tostring(ToyboxMod:getGridEntityData(ent, "SWITCH_GRID") or 1)..".png", true)
    sp:Play("Off", true)

    ent.State = 1
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, switchPlateInit, GridEntityType.GRID_PRESSURE_PLATE)

---@param ent GridEntityPressurePlate
local function plateUpdate(_, ent)
    if(not ToyboxMod:getGridEntityData(ent, "SWITCH_PLATE")) then return end
    if(ent.State==0) then return end

    if(not ToyboxMod:getGridEntityData(ent, "SWITCH_VISITED")) then
        getBlockNeighborhood(ent)
    end

    local sp = ent:GetSprite()

    local validEntity = false
    for _, other in ipairs(Isaac.FindInRadius(ent.Position, 8, EntityPartition.PLAYER | EntityPartition.ENEMY)) do
        if(other:ToPlayer() or (other:IsEnemy() and not other:IsFlying())) then
            validEntity = true
            break
        end
    end

    if(ent.State==1) then
        if(validEntity) then
            ent.State = 2
            sp:Play("Switched", true)

            local room = Game():GetRoom()
            local adj = ToyboxMod:getGridEntityData(ent, "SWITCH_PLATE_NEIGHBORHOOD") or {}

            for _, grididx in ipairs(adj) do
                local othersp = room:GetGridEntity(grididx):GetSprite()
                if(othersp:GetAnimation()=="black") then
                    othersp:Play("black-retract", true)
                else
                    othersp:Play("black", true)
                end
            end

            sfx:Play(ToyboxMod.SFX_ROCK_SCRAPE, 0.25, 2, false, 0.95+math.random()*0.05)
            sfx:Play(SoundEffect.SOUND_BUTTON_PRESS)
        end
    elseif(ent.State==2) then
        if(not validEntity) then
            ent.State = 1
            sp:Play("Off", true)
        end

        if(sp:IsFinished("Switched")) then
            sp:Play("On", true)
        end
    end

    sp:Update()

    return false
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_PRESSUREPLATE_UPDATE, plateUpdate, GridEntityType.GRID_PRESSURE_PLATE)

---@param ent GridEntityRock
local function blockUpdate(_, ent)
    if(not ToyboxMod:getGridEntityData(ent, "SWITCH_BLOCK")) then return end

    if(not ToyboxMod:getGridEntityData(ent, "SWITCH_VISITED")) then
        getBlockNeighborhood(ent)
    end

    local sp = ent:GetSprite()
    if(sp:IsEventTriggered("makewalkable")) then
        ent.State = 2
    elseif(sp:IsEventTriggered("makeunwalkable")) then
        ent.State = 1
    end

    if(ent.State==2) then
        ent.CollisionClass = GridCollisionClass.COLLISION_NONE

        sp:Update()

        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_ROCK_UPDATE, blockUpdate, GridEntityType.GRID_PILLAR)

---@param ent GridEntityRock
local function blockRender(_, ent)
    if(not ToyboxMod:getGridEntityData(ent, "SWITCH_BLOCK")) then return end

    if(ent.State==2) then
        ent:GetSprite():Render(Isaac.WorldToRenderPosition(ent.Position)+Game():GetRoom():GetRenderScrollOffset())
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_ROCK_RENDER, blockRender, GridEntityType.GRID_PILLAR)
