local mod = MilcomMOD

local ENUM_SPEED_BONUS = 0.2
local ENUM_DMG_BONUS = 0.25

local ENUM_TEMP_SPEED_BONUS = 0.2
local ENUM_TEMP_DMG_BONUS = 0.25
local ENUM_TEMP_TPS_BONUS = 0.5
local ENUM_TEMP_BONUS_DURATION = 60*20 --20 seconds

local ENUM_TAR_FREQ = 4
local ENUM_TAR_DURATION = 30*5

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.TAR.ID)) then return end

    if(mod.CONFIG.ATLAS_BASE_STRONGER_TAR) then
        if(flag==CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+ENUM_SPEED_BONUS
        end
        if(flag==CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*(1+ENUM_DMG_BONUS)
        end
    end
    if(mod.CONFIG.ATLAS_TEMP_STRONGER_TAR) then
        local data = mod:getAtlasATable(player)
        local intensity = 0
        if(data.TIME_HAS_BEEN_IN_TRANSFORMATION<=ENUM_TEMP_BONUS_DURATION) then intensity = 1-data.TIME_HAS_BEEN_IN_TRANSFORMATION/ENUM_TEMP_BONUS_DURATION end

        if(flag==CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+intensity*ENUM_TEMP_SPEED_BONUS
        end
        if(flag==CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*(1+intensity*ENUM_TEMP_DMG_BONUS)
        end
        if(flag==CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = mod:addTps(player, ENUM_TEMP_TPS_BONUS*intensity)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function updateTar(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.TAR.ID)) then return end

    local data = mod:getAtlasATable(player)
    
    if(mod.CONFIG.ATLAS_TEMP_STRONGER_TAR and data.TIME_HAS_BEEN_IN_TRANSFORMATION%30==0 and data.TIME_HAS_BEEN_IN_TRANSFORMATION<=ENUM_TEMP_BONUS_DURATION) then
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    end

    if(mod.CONFIG.ATLAS_TAR_CREEP) then
        if(player.FrameCount%ENUM_TAR_FREQ==0) then
            if(mod:getEntityData(player, "ATLAS_SPAWNED_TAR_CREEP")==nil) then
                local tar = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, player.Position, Vector.Zero, player):ToEffect()
                tar.Timeout = ENUM_TAR_DURATION
                tar:Update()
                mod:setEntityData(player, "ATLAS_SPAWNED_TAR_CREEP", true)
            else
                mod:setEntityData(player, "ATLAS_SPAWNED_TAR_CREEP", nil)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateTar)