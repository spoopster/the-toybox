
local json = require("json")

ToyboxMod.IS_DATA_LOADED = false
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
            for key1, val1 in pairs(ToyboxMod:vectorToVectorTable(val)) do
                data[key][key1] = val1
            end
        elseif(type(val)=="userdata" and type(val.SetColorize)=="function") then
            data[key] = {}
            for key1, val1 in pairs(ToyboxMod:colorToColorTable(val)) do
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
                data[key] = ToyboxMod:vectorTableToVector(val)
            elseif(val.IsColorTable) then
                data[key] = ToyboxMod:colorTableToColor(val)
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
        saveDat[key] = (data[key]~=nil and data[key] or val)
    end
    saveDat = convertTableToSaveData(saveDat)

    return saveDat
end

local playerBaseData = include("scripts_toybox.util.savedata.players_basedata")             --! PERSISTS THROUGHOUT ONE RUN, ONE TABLE FOR EACH PLAYER
local extraBaseData = include("scripts_toybox.util.savedata.extras_basedata")               --! PERSISTS THROUGHOUT ONE RUN, NOT DEPENDENT ON PLAYERS
local persistentBaseData = include("scripts_toybox.util.savedata.persistent_basedata")      --! PERSISTS THROUGHOUT ALL RUNS

function ToyboxMod:saveProgress()
    local save = {}

    --save.milcomData = {}
    --save.atlasData = {}
    --save.jonasData = {}
    save.playerData = {}
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local seed = ""..player:GetCollectibleRNG(rngItem):GetSeed()

        --print("SAVED SEED:", seed, player:GetPlayerIndex())

        save.playerData[seed] = convertDataToSaveData(ToyboxMod:getEntityDataTable(player), playerBaseData)
    end
    save.extraData = convertDataToSaveData(ToyboxMod:getExtraDataTable(), extraBaseData)

    save.persistentData = convertDataToSaveData(ToyboxMod:getPersistentDataTable(), persistentBaseData)

    save.configData = convertDataToSaveData(ToyboxMod:cloneTable(ToyboxMod.CONFIG), {})

	ToyboxMod:SaveData(json.encode(save))
end

function ToyboxMod:saveNewFloor()
    if(ToyboxMod.IS_DATA_LOADED) then ToyboxMod:saveProgress() end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, ToyboxMod.saveNewFloor)
function ToyboxMod:saveGameExit(save)
    ToyboxMod:saveProgress()
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, ToyboxMod.saveGameExit)

local function loadImportantData(_, slot)
    ToyboxMod.IS_DATA_LOADED = false
    if(ToyboxMod:HasData()) then
        local sd = json.decode(Isaac.LoadModData(ToyboxMod))

        if(sd and sd.configData) then
            ToyboxMod.CONFIG = ToyboxMod.CONFIG or {}
            ToyboxMod:cloneTableWithoutDeleteing(ToyboxMod.CONFIG, convertSaveDataToTable(sd.configData))
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, loadImportantData)

---@param player EntityPlayer
function ToyboxMod:dataSaveInit(player)
    ToyboxMod.IS_DATA_LOADED = false
    ToyboxMod:cloneTableWithoutDeleteing(ToyboxMod:getEntityDataTable(player), playerBaseData)
    if(#Isaac.FindByType(1)==0) then
        ToyboxMod:cloneTableWithoutDeleteing(ToyboxMod:getExtraDataTable(), extraBaseData)
        ToyboxMod:cloneTableWithoutDeleteing(ToyboxMod:getPersistentDataTable(), persistentBaseData)
    end

    if(Game():GetFrameCount()~=0 and ToyboxMod:HasData()) then
        local save = json.decode(ToyboxMod:LoadData())
        local pSeed = tostring(player:GetCollectibleRNG(rngItem):GetSeed())

        --print("LOADING SEED:", pSeed, player:GetPlayerIndex())

        if(save.playerData[pSeed]) then
            ToyboxMod:cloneTableWithoutDeleteing(ToyboxMod:getEntityDataTable(player), convertSaveDataToTable(save.playerData[pSeed]))
            --print("HAS DATA! LOADED SEED:", pSeed, player:GetPlayerIndex())
        end
        
        if(#Isaac.FindByType(1)==0) then
            if(save.extraData) then
                ToyboxMod:cloneTableWithoutDeleteing(ToyboxMod:getExtraDataTable(), convertSaveDataToTable(save.extraData))
            end
            if(save.persistentData) then ToyboxMod:cloneTableWithoutDeleteing(ToyboxMod:getPersistentDataTable(), convertSaveDataToTable(save.persistentData)) end
        end
    else
        if(Game():GetFrameCount()==0 and ToyboxMod:HasData() and #Isaac.FindByType(1)==0) then
            local save = json.decode(ToyboxMod:LoadData())
            if(save.persistentData) then ToyboxMod:cloneTableWithoutDeleteing(ToyboxMod:getPersistentDataTable(), convertSaveDataToTable(save.persistentData)) end
        end
    end

    ToyboxMod.IS_DATA_LOADED = true
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, -math.huge, ToyboxMod.dataSaveInit)