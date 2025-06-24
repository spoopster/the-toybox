
local sfx = SFXManager()

---@param player EntityPlayer
function ToyboxMod:updateMantles(player)
    if(not ToyboxMod:isAtlasA(player)) then return end
    local data = ToyboxMod:getAtlasATable(player)
    local mantles = data.MANTLES

    local rIdx = ToyboxMod:getRightmostMantleIdx(player)
    for i=rIdx, 1, -1 do
        if(mantles[i].HP<=0 and mantles[i].TYPE~=ToyboxMod.MANTLE_DATA.NONE.ID) then
            if(i>1) then mantles[i-1].HP = mantles[i-1].HP+mantles[i].HP end

            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.PRE_ATLAS_LOSE_MANTLE, mantles[i].TYPE, player, mantles[i].TYPE)
            local oldType = mantles[i].TYPE
            ToyboxMod:setMantleType(player, i, nil, ToyboxMod.MANTLE_DATA.NONE.ID)
            sfx:Play(ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(oldType)].BREAK_SFX)
            Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, oldType, player, oldType)
        end
    end
    rIdx = ToyboxMod:getRightmostMantleIdx(player)
    for i=1,rIdx do
        if(mantles[i].HP>mantles[i].MAXHP) then
            if(i<rIdx) then mantles[i+1].HP = mantles[i+1].HP+(mantles[i].HP-mantles[i].MAXHP) end

            mantles[i].HP = mantles[i].MAXHP
        end
    end

    -- [[
    for i=1, data.HP_CAP-1 do
        if(mantles[i].TYPE==ToyboxMod.MANTLE_DATA.NONE.ID and mantles[i+1].TYPE~=ToyboxMod.MANTLE_DATA.NONE.ID) then
            local temp = ToyboxMod:cloneTable(mantles[i])
            mantles[i] = ToyboxMod:cloneTable(mantles[i+1])
            mantles[i+1] = ToyboxMod:cloneTable(temp)
        end
    end
    --]]

    local trf = ToyboxMod:getCurrentTransformationType(player)
    if(data.TRANSFORMATION~=trf) then
        if(data.TRANSFORMATION==ToyboxMod.MANTLE_DATA.TAR.ID or not ToyboxMod:isBadMantle(trf)) then
            if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                if(not ToyboxMod:isBadMantle(data.TRANSFORMATION)) then
                    data.BIRTHRIGHT_TRANSFORMATION = data.TRANSFORMATION
                end
            else
                data.BIRTHRIGHT_TRANSFORMATION = ToyboxMod.MANTLE_DATA.NONE.ID
            end

            if(data.TRANSFORMATION==ToyboxMod.MANTLE_DATA.TAR.ID) then player:ChangePlayerType(ToyboxMod.PLAYER_TYPE.ATLAS_A) end

            if(not ToyboxMod:isBadMantle(trf)) then
                local mantleDataTable = ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(trf)]

                if(mantleDataTable.TRANSF_NAME and mantleDataTable.TRANSF_DESC) then
                    Game():GetHUD():ShowItemText(mantleDataTable.TRANSF_NAME, mantleDataTable.TRANSF_DESC, false)
                end

                player:AnimateCard(mantleDataTable.CONSUMABLE_SUBTYPE, "Pickup")
                sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
            end

            data.TRANSFORMATION = trf
            data.TIME_HAS_BEEN_IN_TRANSFORMATION = 0
        elseif(trf==ToyboxMod.MANTLE_DATA.TAR.ID) then
            player:ChangePlayerType(ToyboxMod.PLAYER_TYPE.ATLAS_A_TAR)

            data.TRANSFORMATION = ToyboxMod.MANTLE_DATA.TAR.ID
            data.BIRTHRIGHT_TRANSFORMATION=ToyboxMod.MANTLE_DATA.NONE.ID
            data.TIME_HAS_BEEN_IN_TRANSFORMATION = 0
        end
    end

    if(not ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.SALT.ID)) then
        data.SALT_CHARIOT_ENABLED = false
        player:TryRemoveNullCostume(ToyboxMod.MANTLE_DATA.SALT.CHARIOT_COSTUME)
    end

    ToyboxMod.DONT_IGNORE_ATLAS_HEALING = true
    local desiredHealth = 0
    for i=1, data.HP_CAP do
        if(mantles[i].TYPE~=ToyboxMod.MANTLE_DATA.NONE.ID) then
            local hpToAdd = (mantles[i].HP==1 and 1 or 2)
            if(mantles[i].MAXHP<=1) then hpToAdd = 2 end

            desiredHealth = desiredHealth+hpToAdd
        end
    end
    player:AddHearts(desiredHealth-player:GetHearts())
    ToyboxMod.DONT_IGNORE_ATLAS_HEALING = false

    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end

---@param player EntityPlayer
local function timeInTransfUpdate(_, player)
    if(not ToyboxMod:isAtlasA(player)) then return end
    ToyboxMod:setAtlasAData(player, "TIME_HAS_BEEN_IN_TRANSFORMATION", (ToyboxMod:getAtlasAData(player, "TIME_HAS_BEEN_IN_TRANSFORMATION") or 0)+1)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, timeInTransfUpdate)

local function mantleDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(not ToyboxMod:isAtlasA(player)) then return end
    local data = ToyboxMod:getAtlasATable(player)
    local ridx = ToyboxMod:getRightmostMantleIdx(player)

    if(data.TRANSFORMATION~=ToyboxMod.MANTLE_DATA.TAR.ID) then
        sfx:Play(ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(data.MANTLES[ridx].TYPE)].HURT_SFX, 1)
    end
    --]]

    if(dmg>0 and Game():GetDebugFlags() & DebugFlag.INFINITE_HP == 0) then
        if(data.TRANSFORMATION~=ToyboxMod.MANTLE_DATA.TAR.ID) then
            ToyboxMod:addMantleHp(player, -dmg)
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
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12-1+(CustomHealthAPI and (-1e12-1e3) or 0), mantleDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
---@param flag CacheFlag
local function changeFlightCostume(_, player, flag)
    if(not ToyboxMod:isAtlasA(player)) then return end
    local data = ToyboxMod:getAtlasATable(player)
    if(data.TRANSFORMATION==ToyboxMod.MANTLE_DATA.TAR.ID) then return end

    if(flag==CacheFlag.CACHE_FLYING) then
        if(player.CanFly and data.TRANSFORMATION==ToyboxMod.MANTLE_DATA.HOLY.ID) then
            player:AddNullCostume(ToyboxMod.MANTLE_DATA.HOLY.FLIGHT_COSTUME)
        else
            player:TryRemoveNullCostume(ToyboxMod.MANTLE_DATA.HOLY.FLIGHT_COSTUME)
        end
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 1e12, changeFlightCostume)