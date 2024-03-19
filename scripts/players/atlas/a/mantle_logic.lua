local mod = MilcomMOD
local sfx = SFXManager()

function mod:updateMantles(player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)
    local mantles = data.MANTLES

    local rIdx = mod:getRightmostMantleIdx(player)
    for i=rIdx, 1, -1 do
        if(mantles[i].HP<=0 and mantles[i].TYPE~=mod.MANTLES.NONE) then
            if(i>1) then mantles[i-1].HP = mantles[i-1].HP+mantles[i].HP end

            Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.PRE_ATLAS_LOSE_MANTLE, mantles[i].TYPE, player, mantles[i].TYPE)
            local oldType = mantles[i].TYPE
            mantles[i] = {
                TYPE = mod.MANTLES.NONE,
                HP = mod.MANTLES_HP.NONE,
                MAXHP = mod.MANTLES_HP.NONE,
                COLOR = mantles[i].COLOR or Color(1,1,1,1),
            }
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
        if(mantles[i].TYPE==mod.MANTLES.NONE and mantles[i+1].TYPE~=mod.MANTLES.NONE) then
            local temp = mod:cloneTable(mantles[i])
            mantles[i] = mod:cloneTable(mantles[i+1])
            mantles[i+1] = mod:cloneTable(temp)
        end
    end
    --]]

    if(mod.CONFIG.ATLAS_PERSISTENT_TRANSFORMATIONS) then
        local trf = mod:getCurrentTransformationType(player)
        local hasFlight = (player.CanFly and 1 or 0)+1

        if(data.TRANSFORMATION~=trf) then
            if(data.TRANSFORMATION==mod.MANTLES.TAR or not mod:isBadMantle(trf)) then
                if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                    if(not mod:isBadMantle(data.TRANSFORMATION)) then
                        data.BIRTHRIGHT_TRANSFORMATION = data.TRANSFORMATION
                    end
                else
                    data.BIRTHRIGHT_TRANSFORMATION = mod.MANTLES.NONE
                end

                if(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION]) then
                    player:TryRemoveNullCostume(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION][hasFlight])
                end
                if(mod.TRANSFORMATION_TO_COSTUME[trf]) then
                    player:AddNullCostume(mod.TRANSFORMATION_TO_COSTUME[trf][hasFlight])
                end

                data.TRANSFORMATION = trf
                data.TIME_HAS_BEEN_IN_TRANSFORMATION = 0
            elseif(trf==mod.MANTLES.TAR) then
                if(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION]) then
                    player:TryRemoveNullCostume(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION][hasFlight])
                end

                data.TRANSFORMATION = mod.MANTLES.TAR
                data.BIRTHRIGHT_TRANSFORMATION=mod.MANTLES.NONE
                data.TIME_HAS_BEEN_IN_TRANSFORMATION = 0
            end
        end
    else
        local trf = mod:getCurrentTransformationType(player)

        if(data.TRANSFORMATION~=trf) then
            if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
                if(not mod:isBadMantle(data.TRANSFORMATION)) then
                    data.BIRTHRIGHT_TRANSFORMATION = data.TRANSFORMATION
                end
            else
                data.BIRTHRIGHT_TRANSFORMATION = mod.MANTLES.NONE
            end

            local hasFlight = (player.CanFly and 1 or 0)+1
            if(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION]) then
                player:TryRemoveNullCostume(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION][hasFlight])
            end
            if(mod.TRANSFORMATION_TO_COSTUME[trf]) then
                player:AddNullCostume(mod.TRANSFORMATION_TO_COSTUME[trf][hasFlight])
            end

            data.TRANSFORMATION = trf
            data.TIME_HAS_BEEN_IN_TRANSFORMATION = 0
            if(trf==mod.MANTLES.TAR) then data.BIRTHRIGHT_TRANSFORMATION=mod.MANTLES.NONE end
        end
    end

    if(not mod:atlasHasTransformation(player, mod.MANTLES.SALT)) then
        data.SALT_AUTOTARGET_ENABLED = false
    end

    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
end

---@param player EntityPlayer
local function timeInTransfUpdate(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    mod:setAtlasAData(player, "TIME_HAS_BEEN_IN_TRANSFORMATION", (mod:getAtlasAData(player, "TIME_HAS_BEEN_IN_TRANSFORMATION") or 0)+1)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, timeInTransfUpdate)

local function mantleDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    if(dmg>0) then
        local data = mod:getAtlasATable(player)

        if(data.TRANSFORMATION~=mod.MANTLES.TAR) then
            mod:addMantleHp(player, -dmg)

            sfx:Play(mod.SFX_ATLASA_ROCKHURT, 1)
            sfx:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT,0,2)

            return {
                Damage=0,
                DamageFlags=flags,
                DamageCountdown=frames
            }
        else
            player:Die()

            return {
                Damage=0,
                DamageFlags=flags,
                DamageCountdown=frames
            }
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -1e12+1, mantleDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
---@param flag CacheFlag
local function changeFlightCostume(_, player, flag)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)
    if(data.TRANSFORMATION==mod.MANTLES.TAR) then return end

    if(flag==CacheFlag.CACHE_FLYING and mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION]) then
        player:TryRemoveNullCostume(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION][1])
        player:TryRemoveNullCostume(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION][2])
        if(player.CanFly) then
            player:AddNullCostume(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION][2])
        else
            player:AddNullCostume(mod.TRANSFORMATION_TO_COSTUME[data.TRANSFORMATION][1])
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 1e12, changeFlightCostume)