local MilcomMODData = {}

function MilcomMOD:getDataTable(entity)
    if(not MilcomMODData[GetPtrHash(entity)]) then MilcomMODData[GetPtrHash(entity)]={} end

    return MilcomMODData[GetPtrHash(entity)]
end

function MilcomMOD:getData(entity, key)
    if(not MilcomMODData[GetPtrHash(entity)]) then MilcomMODData[GetPtrHash(entity)]={} end

    return MilcomMODData[GetPtrHash(entity)][key]
end

function MilcomMOD:setData(entity, key, val)
    local exists = true
    if(not MilcomMODData[GetPtrHash(entity)]) then
        MilcomMODData[GetPtrHash(entity)]={}
        exists=false
    end

    MilcomMODData[GetPtrHash(entity)][key]=val

    return exists
end

MilcomMOD:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.LATE+1,
    function(_, entity)
        MilcomMODData[GetPtrHash(entity)] = nil
    end
)

MilcomMOD:AddPriorityCallback(ModCallbacks.MC_PRE_GAME_EXIT, CallbackPriority.LATE+1,
    function()
        MilcomMODData = {}
    end
)