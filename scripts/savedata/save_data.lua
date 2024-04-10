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

    save.milcomData = {}
    save.atlasData = {}
    save.playerData = {}
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local seed = ""..player:GetCollectibleRNG(rngItem):GetSeed()
        local pt = player:GetPlayerType()

        if(pt==mod.PLAYER_MILCOM_A) then save.milcomData[seed] = convertTableToSaveData(mod:getMilcomATable(player)) end
        if(pt==mod.PLAYER_ATLAS_A) then save.atlasData[seed] = convertTableToSaveData(mod:getAtlasATable(player)) end

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
    if(mod:HasData()) then
        local sd = json.decode(Isaac.LoadModData(mod))

        if(sd and sd.configData) then
            mod.CONFIG = mod:cloneTable(sd.configData)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, loadImportantData)

function mod:dataSaveInit(player)
    local pt = player:GetPlayerType()

    mod:cloneTableWithoutDeleteing(mod:getEntityDataTable(player), playerBaseData)
    if(#Isaac.FindByType(1)==0) then
        mod:cloneTableWithoutDeleteing(mod:getExtraDataTable(), extraBaseData)
        mod:cloneTableWithoutDeleteing(mod:getPersistentDataTable(), persistentBaseData)
    end
    if(pt==mod.PLAYER_ATLAS_A) then
        mod.ATLAS_A_DATA[player.InitSeed] = {}
        mod:cloneTableWithoutDeleteing(mod:getAtlasATable(player), mod.ATLAS_A_BASEDATA)
    end
    if(pt==mod.PLAYER_MILCOM_A) then
        mod.MILCOM_A_DATA[player.InitSeed] = {}
        mod:cloneTableWithoutDeleteing(mod:getMilcomATable(player), mod.MILCOM_A_BASEDATA)
    end

    if(Game():GetFrameCount()~=0 and mod:HasData()) then
        local save = json.decode(mod:LoadData())
        local pSeed = ""..player:GetCollectibleRNG(rngItem):GetSeed()

        if(pt==mod.PLAYER_ATLAS_A and save.atlasData and save.atlasData[pSeed]) then mod:cloneTableWithoutDeleteing(mod:getAtlasATable(player), convertSaveDataToTable(save.atlasData[pSeed])) end
        if(pt==mod.PLAYER_MILCOM_A and save.milcomData and save.milcomData[pSeed]) then mod:cloneTableWithoutDeleteing(mod:getMilcomATable(player), convertSaveDataToTable(save.milcomData[pSeed])) end

        if(save.playerData[seed]) then mod:cloneTableWithoutDeleteing(mod:getEntityDataTable(player), convertSaveDataToTable(save.playerData[pSeed])) end
        
        if(#Isaac.FindByType(1)==0) then
            if(save.extraData) then mod:cloneTableWithoutDeleteing(mod:getExtraDataTable(), convertSaveDataToTable(save.extraData)) end
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
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, mod.dataSaveInit)