
local sfx = SFXManager()

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.HOLY.ID)
    else
        player:AddEternalHearts(1)
        sfx:Play(SoundEffect.SOUND_SUPERHOLY)

        local data = ToyboxMod:getEntityDataTable(player)
        data.MANTLEHOLY_ACTIVE = (data.MANTLEHOLY_ACTIVE or 0)+1
        player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG, true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CONSUMABLE.MANTLE_HOLY)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(data.MANTLEHOLY_ACTIVE and data.MANTLEHOLY_ACTIVE>0) then
        data.MANTLEHOLY_ACTIVE = 0
        player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG, true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

---@param pl EntityPlayer
local function evalCache(_, pl, flag)
    local data = ToyboxMod:getEntityDataTable(pl)
    if(data.MANTLEHOLY_ACTIVE and data.MANTLEHOLY_ACTIVE>0) then
        pl.TearFlags = pl.TearFlags | TearFlags.TEAR_GLOW
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_TEARFLAG)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CONSUMABLE.MANTLE_HOLY] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(ToyboxMod.CONSUMABLE.MANTLE_HOLY).Weight = (ToyboxMod.CONFIG.MANTLE_WEIGHT or 0.5)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)