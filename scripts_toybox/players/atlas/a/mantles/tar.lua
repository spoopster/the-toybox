

local SPEED_BONUS = 0.2
local DMG_BONUS = 0.5

local TEMP_SPEED_BONUS = 0.2
local TEMP_DMG_BONUS = 1
local TEMP_TEARS_BONUS = 0.5
local TEMP_BONUS_DURATION = 60*10 --10 seconds

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not (ToyboxMod:isAtlasA(player) and ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.TAR.ID))) then return end

    local data = ToyboxMod:getAtlasATable(player)
    local intensity = 0
    if(data.TIME_HAS_BEEN_IN_TRANSFORMATION<=TEMP_BONUS_DURATION) then intensity = 1-data.TIME_HAS_BEEN_IN_TRANSFORMATION/TEMP_BONUS_DURATION end

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+SPEED_BONUS+intensity*TEMP_SPEED_BONUS
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, intensity*TEMP_TEARS_BONUS)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(player, DMG_BONUS+intensity*TEMP_DMG_BONUS)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function updateTar(_, player)
    if(not ToyboxMod:isAtlasA(player)) then return end
    if(not ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.TAR.ID)) then return end

    local data = ToyboxMod:getAtlasATable(player)
    
    if(data.TIME_HAS_BEEN_IN_TRANSFORMATION%15==0 and data.TIME_HAS_BEEN_IN_TRANSFORMATION<=TEMP_BONUS_DURATION) then
        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateTar)