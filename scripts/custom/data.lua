local mod = ToyboxMod
local MODEntityData = {}
local MODExtraData = {}             --! ONE=RUN ONLY, NOT ENTITY DEPENDENT
local MODPersistentData = {}        --! PERSISTS ACROSS RUNS
local MODGridEntityData = {}

function mod:getGridEntityDataTable(entity)
    if(not MODGridEntityData[entity:GetSaveState().SpawnSeed]) then MODGridEntityData[entity:GetSaveState().SpawnSeed]={} end

    return MODGridEntityData[entity:GetSaveState().SpawnSeed]
end
function mod:getGridEntityData(entity, key)
    if(not MODGridEntityData[entity:GetSaveState().SpawnSeed]) then MODGridEntityData[entity:GetSaveState().SpawnSeed]={} end

    return MODGridEntityData[entity:GetSaveState().SpawnSeed][key]
end
function mod:setGridEntityData(entity, key, val)
    local exists = true
    if(not MODGridEntityData[entity:GetSaveState().SpawnSeed]) then
        MODGridEntityData[entity:GetSaveState().SpawnSeed]={}
        exists=false
    end

    MODGridEntityData[entity:GetSaveState().SpawnSeed][key]=val

    return exists
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, math.huge,
    function()
        MODGridEntityData = {}
    end
)

local function getEntIndex(ent)
    return tostring(ent.InitSeed)
end

function mod:getEntityDataTable(entity)
    -- [[
    if(not entity:GetData().TOYBOXDATA) then entity:GetData().TOYBOXDATA = {} end
    return entity:GetData().TOYBOXDATA
    --]]

    --[[
    local idx = getEntIndex(entity)
    if(not MODEntityData[idx]) then MODEntityData[idx]={} end

    return MODEntityData[idx]
    --]]
end
function mod:getEntityData(entity, key)
    -- [[
    if(not entity:GetData().TOYBOXDATA) then entity:GetData().TOYBOXDATA = {} end
    return entity:GetData().TOYBOXDATA[key]
    --]]

    --[[
    local idx = getEntIndex(entity)
    if(not MODEntityData[idx]) then MODEntityData[idx]={} end

    return MODEntityData[idx][key]
    --]]
end
function mod:setEntityData(entity, key, val)
    -- [[
    if(not entity:GetData().TOYBOXDATA) then entity:GetData().TOYBOXDATA = {} end
    entity:GetData().TOYBOXDATA[key] = val
    --]]

    --[[
    local idx = getEntIndex(entity)
    local exists = true
    if(not MODEntityData[idx]) then
        MODEntityData[idx]={}
        exists=false
    end

    MODEntityData[idx][key]=val

    return exists
    --]]
end

--[[
mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, math.huge,
    function(_, entity)
        if(Game():IsPaused()) then return end

        local idx = getEntIndex(entity)
        MODEntityData[idx] = nil
    end
)
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, math.huge,
    function()
        MODEntityData = {}
    end
)
--]]

function mod:getExtraDataTable()
    return MODExtraData or {}
end
function mod:getExtraData(key)
    return (MODExtraData or {})[key]
end
function mod:setExtraData(key, val)
    MODExtraData = MODExtraData or {}
    MODExtraData[key] = val
end

function mod:getPersistentDataTable()
    return MODPersistentData or {}
end
function mod:getPersistentData(key)
    return (MODPersistentData or {})[key]
end
function mod:setPersistentData(key, val)
    MODPersistentData = MODPersistentData or {}
    MODPersistentData[key] = val
end