local mod = MilcomMOD
local json = require("json")

mod.IS_DATA_LOADED = false
local rngItem = CollectibleType.COLLECTIBLE_BOX --* milcom uses box's rng just in case !

---@param t table
local function convertTableToSaveData(t)
    local data = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            data[key] = {}
            for key1, val1 in pairs(convertTableToSaveData(val)) do
                data[key][key1] = val1
            end
        elseif(type(val)=="userdata" and type(val.LengthSquared)=="function") then
            data[key] = {}
            for key1, val1 in pairs(mod:vectorToVectorTable(val)) do
                data[key][key1] = val1
            end
        elseif(type(val)=="userdata" and type(val.SetColorize)=="function") then
            data[key] = {}
            for key1, val1 in pairs(mod:colorToColorTable(val)) do
                data[key][key1] = val1
            end
        else
            data[key]=val
        end
    end

    return data
end

---@param t table
local function convertSaveDataToTable(t)
    local data = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            data[key] = {}

            if(val.IsVectorTable) then
                data[key] = mod:vectorTableToVector(val)
            elseif(val.IsColorTable) then
                data[key] = mod:colorTableToColor(val)
            else
                for key1, val1 in pairs(convertSaveDataToTable(val)) do
                    data[key][key1] = val1
                end
            end
        else
            data[key] = val
        end
    end

    return data
end

local function convertDataToSaveData(data, basedata)
    local saveDat = {}
    for key, val in pairs(basedata) do
        --print(key, val, data[key])
        saveDat[key] = data[key] or val
    end
    saveDat = convertTableToSaveData(saveDat)

    return saveDat
end

local playerBaseData = include("scripts.savedata.players_basedata")             --! PERSISTS THROUGHOUT ONE RUN, ONE TABLE FOR EACH PLAYER
local extraBaseData = include("scripts.savedata.extras_basedata")               --! PERSISTS THROUGHOUT ONE RUN, NOT DEPENDENT ON PLAYERS
local persistentBaseData = include("scripts.savedata.persistent_basedata")      --! PERSISTS THROUGHOUT ALL RUNS

function mod:saveProgress()
    local save = {}

    --save.milcomData = {}
    --save.atlasData = {}
    --save.jonasData = {}
    save.playerData = {}
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local seed = ""..player:GetCollectibleRNG(rngItem):GetSeed()

        save.playerData[seed] = convertDataToSaveData(mod:getEntityDataTable(player), playerBaseData)
    end
    save.extraData = convertDataToSaveData(mod:getExtraDataTable(), extraBaseData)

    save.persistentData = convertDataToSaveData(mod:getPersistentDataTable(), persistentBaseData)

    save.configData = mod:cloneTable(mod.CONFIG)

	mod:SaveData(json.encode(save))
end

function mod:saveNewFloor()
    if(mod.IS_DATA_LOADED) then mod:saveProgress() end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveNewFloor)
function mod:saveGameExit(save)
    mod:saveProgress()
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveGameExit)

local function loadImportantData(_, slot)
    mod.IS_DATA_LOADED = false
    if(mod:HasData()) then
        local sd = json.decode(Isaac.LoadModData(mod))

        if(sd and sd.configData) then
            mod.CONFIG = mod:cloneTable(sd.configData)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, loadImportantData)

function mod:dataSaveInit(player)
    --print(mod:getEntityData(player, "ATLAS_A_DATA"))
    mod.IS_DATA_LOADED = false
    mod:cloneTableWithoutDeleteing(mod:getEntityDataTable(player), playerBaseData)
    if(#Isaac.FindByType(1)==0) then
        mod:cloneTableWithoutDeleteing(mod:getExtraDataTable(), extraBaseData)
        mod:cloneTableWithoutDeleteing(mod:getPersistentDataTable(), persistentBaseData)
    end

    if(Game():GetFrameCount()~=0 and mod:HasData()) then
        local save = json.decode(mod:LoadData())
        local pSeed = ""..player:GetCollectibleRNG(rngItem):GetSeed()

        if(save.playerData[seed]) then mod:cloneTableWithoutDeleteing(mod:getEntityDataTable(player), convertSaveDataToTable(save.playerData[pSeed])) end
        
        if(#Isaac.FindByType(1)==0) then
            if(save.extraData) then
                mod:cloneTableWithoutDeleteing(mod:getExtraDataTable(), convertSaveDataToTable(save.extraData))
            end
            if(save.persistentData) then mod:cloneTableWithoutDeleteing(mod:getPersistentDataTable(), convertSaveDataToTable(save.persistentData)) end
        end
    else
        if(Game():GetFrameCount()==0 and mod:HasData() and #Isaac.FindByType(1)==0) then
            local save = json.decode(mod:LoadData())
            if(save.persistentData) then mod:cloneTableWithoutDeleteing(mod:getPersistentDataTable(), convertSaveDataToTable(save.persistentData)) end
        end
    end

    mod.IS_DATA_LOADED = true
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, -math.huge, mod.dataSaveInit)