local mod = MilcomMOD
local json = require("json")

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
                data[key] = mod:colorToColorTable(val)
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

local isDataLoaded = false
local itemBaseData = include("scripts.savedata.items_basedata")

function mod:saveProgress()
    local save = {}

    save.milcomData = {}
    save.atlasData = {}
    save.itemData = {}
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local pData = mod:getDataTable(player)
        local seed = ""..player:GetCollectibleRNG(rngItem):GetSeed()
        if(player:GetPlayerType()==mod.PLAYER_MILCOM_A) then
            save.milcomData[seed] = convertTableToSaveData(mod:getMilcomATable(player))
        elseif(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
            save.atlasData[seed] = convertTableToSaveData(mod:getAtlasATable(player))
        end

        save.itemData[seed] = {}
        for key, val in pairs(itemBaseData) do
            save.itemData[seed][key] = pData[key] or val
        end

        save.itemData[seed] = convertTableToSaveData(save.itemData[seed])
    end
    save.configData =mod:cloneTable(mod.CONFIG)
    save.pickupDataA = mod.MILCOM_A_PICKUPS or {CARDBOARD = 0, DUCT_TAPE = 0, NAILS = 0}

	mod:SaveData(json.encode(save))
end

function mod:saveNewFloor()
    if(isDataLoaded) then mod:saveProgress() end
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
    local pData = mod:getDataTable(player)
    mod:cloneTableWithoutDeleteing(pData, itemBaseData)

    if(Game():GetFrameCount()==0) then
        if(player:GetPlayerType()==mod.PLAYER_MILCOM_A) then
            mod.MILCOM_A_DATA[player.InitSeed] = mod:cloneTable(mod.MILCOM_A_BASEDATA)
            mod.MILCOM_A_PICKUPS = {CARDBOARD = 0, DUCT_TAPE = 0, NAILS = 0}
        elseif(player:GetPlayerType()==mod.PLAYER_MILCOM_B) then

        elseif(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
            mod.ATLAS_A_DATA[player.InitSeed] = mod:cloneTable(mod.ATLAS_A_BASEDATA)
        elseif(player:GetPlayerType()==mod.PLAYER_ATLAS_B) then
        end
    else
        if(mod:HasData()) then
            local save = json.decode(mod:LoadData())
            local pSeed = ""..player:GetCollectibleRNG(rngItem):GetSeed()

            if(save) then
                local milcomData = save.milcomData[pSeed]
                local atlasData = save.atlasData[pSeed]
                if(player:GetPlayerType()==mod.PLAYER_MILCOM_A) then
                    if(milcomData and milcomData["CHARACTER_SIDE"]=="A") then mod.MILCOM_A_DATA[player.InitSeed] = convertSaveDataToTable(milcomData)
                    else mod.MILCOM_A_DATA[player.InitSeed] = mod:cloneTable(mod.MILCOM_A_BASEDATA) end
                elseif(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
                    if(atlasData and atlasData["CHARACTER_SIDE"]=="A") then mod.ATLAS_A_DATA[player.InitSeed] = convertSaveDataToTable(atlasData)
                    else mod.ATLAS_A_DATA[player.InitSeed] = mod:cloneTable(mod.ATLAS_A_BASEDATA) end
                end

                if(#Isaac.FindByType(1)==0) then
                    if(save.pickupDataA) then mod.MILCOM_A_PICKUPS = save.pickupDataA
                    else mod.MILCOM_A_PICKUPS = {CARDBOARD = 0, DUCT_TAPE = 0, NAILS = 0} end
                end

                local iData = save.itemData[pSeed]
                if(iData) then
                    iData = convertSaveDataToTable(iData)
                    mod:cloneTableWithoutDeleteing(pData, iData)
                end
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, CallbackPriority.IMPORTANT, mod.dataSaveInit)