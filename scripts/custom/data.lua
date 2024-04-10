local mod = MilcomMOD
local MODEntityData = {}
local MODExtraData = {}             --! ONE=RUN ONLY, NOT ENTITY DEPENDENT
local MODPersistentData = {}        --! PERSISTS ACROSS RUNS

function mod:getEntityDataTable(entity)
    if(not MODEntityData[GetPtrHash(entity)]) then MODEntityData[GetPtrHash(entity)]={} end

    return MODEntityData[GetPtrHash(entity)]
end
function mod:getEntityData(entity, key)
    if(not MODEntityData[GetPtrHash(entity)]) then MODEntityData[GetPtrHash(entity)]={} end

    return MODEntityData[GetPtrHash(entity)][key]
end
function mod:setEntityData(entity, key, val)
    local exists = true
    if(not MODEntityData[GetPtrHash(entity)]) then
        MODEntityData[GetPtrHash(entity)]={}
        exists=false
    end

    MODEntityData[GetPtrHash(entity)][key]=val

    return exists
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, math.huge,
    function(_, entity)
        MODEntityData[GetPtrHash(entity)] = nil
    end
)
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, math.huge,
    function()
        MODEntityData = {}
    end
)

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