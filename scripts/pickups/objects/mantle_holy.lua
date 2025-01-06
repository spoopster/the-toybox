local mod = MilcomMOD
local sfx = SFXManager()

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.HOLY.ID)
    else
        player:AddEternalHearts(1)
        sfx:Play(SoundEffect.SOUND_SUPERHOLY)

        local data = mod:getEntityDataTable(player)
        data.MANTLEHOLY_ACTIVE = (data.MANTLEHOLY_ACTIVE or 0)+1
        player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG, true)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_HOLY)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local data = mod:getEntityDataTable(player)
    if(data.MANTLEHOLY_ACTIVE and data.MANTLEHOLY_ACTIVE>0) then
        data.MANTLEHOLY_ACTIVE = 0
        player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

---@param pl EntityPlayer
local function evalCache(_, pl, flag)
    local data = mod:getEntityDataTable(pl)
    if(data.MANTLEHOLY_ACTIVE and data.MANTLEHOLY_ACTIVE>0) then
        pl.TearFlags = pl.TearFlags | TearFlags.TEAR_GLOW
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_TEARFLAG)

if(mod.ATLAS_A_MANTLESUBTYPES) then mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_HOLY] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(mod.CONSUMABLE_MANTLE_HOLY).Weight = mod.CONFIG.MANTLE_WEIGHT
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)