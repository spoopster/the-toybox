ToyboxMod.CUSTOM_TEARFLAGS = {}
local TEARFLAG_TABLE_KEY = "CUSTOM_TEARFLAGS"

---@param key string
---@param applyFunc? function
---@param tearVar? TearVariant
---@param tearColor? Color
---@param bombVar? BombVariant
function ToyboxMod:addTearFlagEnum(key, applyFunc, tearVar, tearColor, bombVar)
    ToyboxMod.CUSTOM_TEARFLAGS[key] = {
        ApplyFunction = applyFunc,
        TearVariant = tearVar,
        TearColor = tearColor,
        BombVariant = bombVar,
    }
end

---@param ent Entity
---@param flag string|TearFlags
---@param chance? number
---@param sourceItem? CollectibleType
---@param flagKey? string
function ToyboxMod:addTearFlag(ent, flag, chance, sourceItem, flagKey)
    local resultTable = flag
    if(type(chance)=="function" or (chance or 1)<1) then
        resultTable = {
            Flag = flag,
            Chance = chance,
            RNG = (sourceItem and ent:ToPlayer() and ent:ToPlayer():GetCollectibleRNG(sourceItem) or ToyboxMod:generateRng())
        }
    end

    local data = ToyboxMod:getEntityDataTable(ent)
    data[TEARFLAG_TABLE_KEY] = data[TEARFLAG_TABLE_KEY] or {}
    table.insert(data[TEARFLAG_TABLE_KEY], {Data=resultTable, Key=flagKey or (type(flag)=="string" and flag)})

    return true
end

function ToyboxMod:getFinalFlags(source)
    local flags = {}
    if(source and ToyboxMod:getEntityData(source, TEARFLAG_TABLE_KEY)) then
        local cFlags = ToyboxMod:getEntityData(source, TEARFLAG_TABLE_KEY)
        for _, flag in ipairs(cFlags) do
--[[
            local s = ""
            for key, val in pairs(flag) do
                s = s.."{"..tostring(key)..","

                if(type(val)=="table") then
                    s = s.."["
                    for key2, val2 in pairs(val) do
                        s = s.."{"..tostring(key2)..","..tostring(val2).."};"
                    end
                    s = s.."] "
                else
                    s = s..tostring(val)
                end

                s = s.."} "
            end
            print(s)
--]]
            local flagKey = flag.Key
            local flagData = flag.Data
            local fT = type(flagData)
            if(fT~="table") then
                table.insert(flags, {Flag=flagData, Key=flagKey})
            elseif(fT=="table") then
                local rng = flagData.RNG
                local chance = flagData.Chance
                if(type(flagData.Chance)=="function") then
                    if(source:ToPlayer()) then
                        chance = flagData.Chance(source:ToPlayer())
                    else
                        chance = 1
                    end
                end

                if(rng:RandomFloat()<chance) then
                    table.insert(flags, {Flag=flagData.Flag, Key=flagKey})
                end
            end
        end
    end
    return flags
end

---@param ent Entity
---@param source Entity
local function giveCustomFlags(ent, source)
    local data = ToyboxMod:getEntityDataTable(ent)
    data[TEARFLAG_TABLE_KEY] = data[TEARFLAG_TABLE_KEY] or {}

    local finalFlag = nil
    local cFlags = ToyboxMod:getFinalFlags(source)
    for _, flag in ipairs(cFlags) do
        if(type(flag.Flag)=="string") then
            table.insert(data[TEARFLAG_TABLE_KEY], {Data=flag.Flag, Key=flag.Key})
            finalFlag = flag.Key or flag.Flag
        end
    end

    if(finalFlag and ToyboxMod.CUSTOM_TEARFLAGS[finalFlag]) then
        if(ent:ToTear() and ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].TearVariant) then
            ent:ToTear():ChangeVariant(ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].TearVariant)
        elseif(ent:ToBomb() and ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].BombVariant) then
            -- mango
        end

        if(ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].TearColor) then
            ent.Color = ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].TearColor
            ToyboxMod:setEntityData(ent, "EXPLOSION_COLOR", ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].TearColor)
        end
    end
end

---@param npc EntityNPC
---@param pos Vector
---@param flags TearFlags
---@param source Entity?
---@param dmg number
local function applyTearflags(_, npc, pos, flags, source, dmg)
    local vanillaFlags = TearFlags.TEAR_NORMAL

    local cFlags = ToyboxMod:getFinalFlags(source)
    for _, flag in ipairs(cFlags) do
        if(type(flag.Flag)=="userdata") then
            vanillaFlags = vanillaFlags | flag.Flag
        else
            if(flag.Key and ToyboxMod.CUSTOM_TEARFLAGS[flag.Key].ApplyFunction) then
                ToyboxMod.CUSTOM_TEARFLAGS[flag.Key].ApplyFunction(npc, flag.Flag, source, pos, dmg, flag.Key)
            end
            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.APPLY_CUSTOM_TEARFLAG, flag.Flag, npc, flag.Flag, source, pos, dmg, flag.Key)
        end
    end

    if(vanillaFlags~=TearFlags.TEAR_NORMAL) then
        return {
            Position = pos,
            TearFlags = flags | vanillaFlags,
            Damage = dmg,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_APPLY_TEARFLAG_EFFECTS, applyTearflags)

---@param player EntityPlayer
local function resetTearFlags(_, player, _)
    ToyboxMod:setEntityData(player, TEARFLAG_TABLE_KEY, {})
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.IMPORTANT-1, resetTearFlags, CacheFlag.CACHE_TEARFLAG)

---@param pl EntityPlayer
---@param params TearParams
local function evalParams(_, pl, params, weap, dmg, tearDisp, source)
    local vanillaFlags = TearFlags.TEAR_NORMAL
    local finalFlag = nil
    local cFlags = ToyboxMod:getFinalFlags(source)
    for _, flag in ipairs(cFlags) do
        if(type(flag.Flag)=="userdata") then
            vanillaFlags = vanillaFlags | flag.Flag
            finalFlag = flag.Key
        end
    end

    if(vanillaFlags~=TearFlags.TEAR_NORMAL) then
        params.TearFlags = params.TearFlags | vanillaFlags
        if(finalFlag and ToyboxMod.CUSTOM_TEARFLAGS[finalFlag]) then
            params.TearVariant = ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].TearVariant or params.TearVariant
            params.TearColor = ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].TearColor or params.TearColor
            params.BombVariant = ToyboxMod.CUSTOM_TEARFLAGS[finalFlag].BombVariant or params.BombVariant
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, evalParams)

---@param tear EntityTear
---@param player EntityPlayer
local function letterFireTear(_, tear, player, isLudo)
    giveCustomFlags(tear, player)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, letterFireTear)

---@param bomb EntityBomb
---@param player EntityPlayer
local function letterFireBomb(_, bomb, player)
    giveCustomFlags(bomb, player)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, letterFireBomb)

---@param rocket EntityEffect
---@param player EntityPlayer
local function letterFireRocket(_, rocket, player)
    giveCustomFlags(rocket, player)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_ROCKET, letterFireRocket)
---@param rocket EntityEffect
---@param target EntityEffect
local function letterCopyTargetData(_, rocket, target)
    giveCustomFlags(rocket, target)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.ROCKET_COPY_TARGET_DATA, letterCopyTargetData)