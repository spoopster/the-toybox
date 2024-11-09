local mod = MilcomMOD
local sfx = SFXManager()

function mod:updateMantles(player)
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)
    local mantles = data.MANTLES

    local rIdx = mod:getRightmostMantleIdx(player)
    for i=rIdx, 1, -1 do
        if(mantles[i].HP<=0 and mantles[i].TYPE~=mod.MANTLE_DATA.NONE.ID) then
            if(i>1) then mantles[i-1].HP = mantles[i-1].HP+mantles[i].HP end

            Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.PRE_ATLAS_LOSE_MANTLE, mantles[i].TYPE, player, mantles[i].TYPE)
            local oldType = mantles[i].TYPE
            mod:setMantleType(player, i, nil, mod.MANTLE_DATA.NONE.ID)
            sfx:Play(mod.MANTLE_DATA[mod:getMantleKeyFromId(oldType)].BREAK_SFX)
            Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, oldType, player, oldType)
        end
    end
    rIdx = mod:getRightmostMantleIdx(player)
    for i=1,rIdx do
        if(mantles[i].HP>mantles[i].MAXHP) then
            if(i<rIdx) then mantles[i+1].HP = mantles[i+1].HP+(mantles[i].HP-mantles[i].MAXHP) end

            mantles[i].HP = mantles[i].MAXHP
        end
    end

    -- [[
    for i=1, data.HP_CAP-1 do
        if(mantles[i].TYPE==mod.MANTLE_DATA.NONE.ID and mantles[i+1].TYPE~=mod.MANTLE_DATA.NONE.ID) then
            local temp = mod:cloneTable(mantles[i])
            mantles[i] = mod:cloneTable(mantles[i+1])
            mantles[i+1] = mod:cloneTable(temp)
        end
    end
    --]]

    local trf = mod:getCurrentTransformationType(player)
    if(data.TRANSFORMATION~=trf) then
        if(data.TRANSFORMATION==mod.MANTLE_DATA.TAR.ID or not mod:isBadMantle(trf)) then
            if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                if(not mod:isBadMantle(data.TRANSFORMATION)) then
                    data.BIRTHRIGHT_TRANSFORMATION = data.TRANSFORMATION
                end
            else
                data.BIRTHRIGHT_TRANSFORMATION = mod.MANTLE_DATA.NONE.ID
            end

            if(data.TRANSFORMATION==mod.MANTLE_DATA.TAR.ID) then player:ChangePlayerType(mod.PLAYER_ATLAS_A) end

            data.TRANSFORMATION = trf
            data.TIME_HAS_BEEN_IN_TRANSFORMATION = 0
        elseif(trf==mod.MANTLE_DATA.TAR.ID) then
            player:ChangePlayerType(mod.PLAYER_ATLAS_A_TAR)

            data.TRANSFORMATION = mod.MANTLE_DATA.TAR.ID
            data.BIRTHRIGHT_TRANSFORMATION=mod.MANTLE_DATA.NONE.ID
            data.TIME_HAS_BEEN_IN_TRANSFORMATION = 0
        end
    end

    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.SALT.ID)) then
        data.SALT_AUTOTARGET_ENABLED = false
    end

    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end

---@param player EntityPlayer
local function timeInTransfUpdate(_, player)
    if(not mod:isAtlasA(player)) then return end
    mod:setAtlasAData(player, "TIME_HAS_BEEN_IN_TRANSFORMATION", (mod:getAtlasAData(player, "TIME_HAS_BEEN_IN_TRANSFORMATION") or 0)+1)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, timeInTransfUpdate)

local function mantleDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)
    local ridx = mod:getRightmostMantleIdx(player)

    if(data.TRANSFORMATION~=mod.MANTLE_DATA.TAR.ID) then
        sfx:Play(mod.MANTLE_DATA[mod:getMantleKeyFromId(data.MANTLES[ridx].TYPE)].HURT_SFX, 1)
    end
    --]]

    if(dmg>0 and Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0) then
        if(data.TRANSFORMATION~=mod.MANTLE_DATA.TAR.ID) then
            mod:addMantleHp(player, -dmg)
        else
            player:Die()
        end

        return {
            Damage=0,
            DamageFlags=flags,
            DamageCountdown=frames
        }
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12-1+(CustomHealthAPI and (-1e12-1e3) or 0), mantleDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
---@param flag CacheFlag
local function changeFlightCostume(_, player, flag)
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)
    if(data.TRANSFORMATION==mod.MANTLE_DATA.TAR.ID) then return end

    if(flag==CacheFlag.CACHE_FLYING) then
        if(player.CanFly and data.TRANSFORMATION==mod.MANTLE_DATA.HOLY.ID) then
            player:AddNullCostume(mod.MANTLE_DATA.HOLY.FLIGHT_COSTUME)
        else
            player:TryRemoveNullCostume(mod.MANTLE_DATA.HOLY.FLIGHT_COSTUME)
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 1e12, changeFlightCostume)