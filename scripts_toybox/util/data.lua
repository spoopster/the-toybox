
local MODEntityData = {}
local MODExtraData = {}             --! ONE=RUN ONLY, NOT ENTITY DEPENDENT
local MODPersistentData = {}        --! PERSISTS ACROSS RUNS
ToyboxMod.GridEntityData = {}

local function getGridEntSeed(ent)
    return tostring(ent:GetSaveState().SpawnSeed)..tostring(ent:GetGridIndex())
end

function ToyboxMod:getGridEntityDataTable(entity)
    local seed = getGridEntSeed(entity)
    if(not ToyboxMod.GridEntityData[seed]) then ToyboxMod.GridEntityData[seed]={} end

    return ToyboxMod.GridEntityData[seed]
end
function ToyboxMod:getGridEntityData(entity, key)
    local seed = getGridEntSeed(entity)
    if(not ToyboxMod.GridEntityData[seed]) then ToyboxMod.GridEntityData[seed]={} end

    return ToyboxMod.GridEntityData[seed][key]
end
function ToyboxMod:setGridEntityData(entity, key, val)
    local seed = getGridEntSeed(entity)
    local exists = true
    if(not ToyboxMod.GridEntityData[seed]) then
        ToyboxMod.GridEntityData[seed]={}
        exists=false
    end

    ToyboxMod.GridEntityData[seed][key]=val

    return exists
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, math.huge,
    function()
        --ToyboxMod.GridEntityData = {}
    end
)

local function getEntIndex(ent)
    return tostring(ent.InitSeed)
end

function ToyboxMod:getEntityDataTable(entity)
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
function ToyboxMod:getEntityData(entity, key)
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
function ToyboxMod:setEntityData(entity, key, val)
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
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, math.huge,
    function(_, entity)
        if(Game():IsPaused()) then return end

        local idx = getEntIndex(entity)
        MODEntityData[idx] = nil
    end
)
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, math.huge,
    function()
        MODEntityData = {}
    end
)
--]]

function ToyboxMod:getExtraDataTable()
    return MODExtraData or {}
end
function ToyboxMod:getExtraData(key)
    return (MODExtraData or {})[key]
end
function ToyboxMod:setExtraData(key, val)
    MODExtraData = MODExtraData or {}
    MODExtraData[key] = val
end

function ToyboxMod:getPersistentDataTable()
    return MODPersistentData or {}
end
function ToyboxMod:getPersistentData(key)
    return (MODPersistentData or {})[key]
end
function ToyboxMod:setPersistentData(key, val)
    MODPersistentData = MODPersistentData or {}
    MODPersistentData[key] = val
end