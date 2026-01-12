

local SPEED_BONUS = 0.2
local DMG_BONUS = 0.5

local TEMP_SPEED_BONUS = 0.2
local TEMP_DMG_BONUS = 1
local TEMP_TEARS_BONUS = 0.5
local TEMP_BONUS_DURATION = 60*10 --10 seconds

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