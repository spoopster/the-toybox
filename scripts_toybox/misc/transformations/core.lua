local sfx = SFXManager()

ToyboxMod.TRANSFORMATIONS = include("scripts_toybox.misc.transformations.enums")

local BASE_TRANSF_REQ = 3

---@param pl EntityPlayer
---@param transfKey string
function ToyboxMod:hasCustomTransformation(pl, transfKey)
    local data = ToyboxMod:getEntityDataTable(pl)
    data.TRANSFORMATIONS = data.TRANSFORMATIONS or {}
    data.TRANSFORMATIONS[transfKey] = data.TRANSFORMATIONS[transfKey] or {true, false, 0}

    return data.TRANSFORMATIONS[transfKey][2]
end

---@param id CollectibleType
---@param transfKey string
function ToyboxMod:isItemInCustomTransformation(id, transfKey)
    local iConf = Isaac.GetItemConfig():GetCollectible(id)
    if(not iConf) then return end

    local data = ToyboxMod.TRANSFORMATIONS[transfKey]
    if(data.CustomTag and iConf:HasCustomTag(data.CustomTag)) then
        return true
    elseif(data.VanillaItems) then
        for _, checkId in ipairs(data.VanillaItems) do
            if(id==checkId) then
                return true
            end
        end
    end

    return false
end

---@param pl EntityPlayer
---@param transfKey string
---@param num integer
function ToyboxMod:incrementCustomTransformationCounter(pl, transfKey, num)
    local transfData = ToyboxMod.TRANSFORMATIONS[transfKey]

    local data = ToyboxMod:getEntityDataTable(pl)
    data.TRANSFORMATIONS = data.TRANSFORMATIONS or {}
    data.TRANSFORMATIONS[transfKey] = data.TRANSFORMATIONS[transfKey] or {true, false, 0}

    data.TRANSFORMATIONS[transfKey][3] = (data.TRANSFORMATIONS[transfKey][3] or 0)+num
    if(data.TRANSFORMATIONS[transfKey][3]>=(transfData.NumReq or BASE_TRANSF_REQ)) then
        if(not data.TRANSFORMATIONS[transfKey][2]) then
            data.TRANSFORMATIONS[transfKey][2] = true

            sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
            local poof = Isaac.Spawn(1000,15,0,pl.Position,Vector.Zero,nil)

            if(transfData.Costume) then
                pl:AddNullCostume(transfData.Costume)
            end
            if(transfData.StreakName) then
                Game():GetHUD():ShowItemText(transfData.StreakName.."!")
            end

            ---params: EntityPlayer pl, boolean firstTime, string transformation
            ---optional arg: string transformation
            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_GET_CUSTOM_TRANSFORMATION, transfKey, pl, data.TRANSFORMATIONS[transfKey][1], transfKey)

            data.TRANSFORMATIONS[transfKey][1] = false
        end
    else
        if(data.TRANSFORMATIONS[transfKey][2]) then
            data.TRANSFORMATIONS[transfKey][2] = false

            if(transfData.Costume) then
                pl:TryRemoveNullCostume(transfData.Costume)
            end

            ---params: EntityPlayer pl, string transformation
            ---optional arg: string transformation
            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_LOSE_CUSTOM_TRANSFORMATION, transfKey, pl, transfKey)
        end
    end
end

---@param id CollectibleType
---@param firstTime boolean
---@param pl EntityPlayer
local function itemAdded(_, id, _, firstTime, _, _, pl)
    if(not firstTime) then return end

    local iConf = Isaac.GetItemConfig():GetCollectible(id)
    if(not iConf) then return end

    for tKey, tData in pairs(ToyboxMod.TRANSFORMATIONS) do
        if(ToyboxMod:isItemInCustomTransformation(id, tKey)) then
            ToyboxMod:incrementCustomTransformationCounter(pl, tKey, 1)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, itemAdded)

---@param pl EntityPlayer
---@param id CollectibleType
---@param removeFromPlayerForm boolean
local function itemRemoved(_, pl, id, removeFromPlayerForm, _)
    if(not removeFromPlayerForm) then return end

    local iConf = Isaac.GetItemConfig():GetCollectible(id)
    if(not iConf) then return end

    for tKey, tData in pairs(ToyboxMod.TRANSFORMATIONS) do
        if(ToyboxMod:isItemInCustomTransformation(id, tKey)) then
            ToyboxMod:incrementCustomTransformationCounter(pl, tKey, -1)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, itemRemoved)