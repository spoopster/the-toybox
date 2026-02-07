
local sfx = SFXManager()

---@param player EntityPlayer
---@param flags DamageFlag
local function useMantle(_, _, player, flags)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CONGLOMERATE) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.HOLY.ID)
    else
        player:AddEternalHearts(1)
        sfx:Play(SoundEffect.SOUND_SUPERHOLY)

        local data = ToyboxMod:getEntityDataTable(player)
        data.MANTLEHOLY_ACTIVE = (data.MANTLEHOLY_ACTIVE or 0)+1
        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            if(data.MANTLEHOLY_ACTIVE==data.MANTLEHOLY_ACTIVE//1) then
                data.MANTLEHOLY_ACTIVE = data.MANTLEHOLY_ACTIVE+0.5
            end
        end
        player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG, true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_HOLY)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(data.MANTLEHOLY_ACTIVE and data.MANTLEHOLY_ACTIVE>0) then
        if(data.MANTLEHOLY_ACTIVE==data.MANTLEHOLY_ACTIVE//1) then
            data.MANTLEHOLY_ACTIVE = 0
            player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG, true)
        elseif(data.MANTLEHOLY_ACTIVE>1) then
            data.MANTLEHOLY_ACTIVE = data.MANTLEHOLY_ACTIVE-(data.MANTLEHOLY_ACTIVE//1)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

---@param pl EntityPlayer
local function tryCancelGodEffect(_, pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    if(data.MANTLEHOLY_ACTIVE and data.MANTLEHOLY_ACTIVE>0 and data.MANTLEHOLY_ACTIVE<1 and data.MANTLEHOLY_ACTIVE~=data.MANTLEHOLY_ACTIVE//1) then
        if(pl:GetEternalHearts()==0) then
            data.MANTLEHOLY_ACTIVE = 0
            pl:AddCacheFlags(CacheFlag.CACHE_TEARFLAG, true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, tryCancelGodEffect)

---@param pl EntityPlayer
local function evalCache(_, pl, flag)
    local data = ToyboxMod:getEntityDataTable(pl)
    if(data.MANTLEHOLY_ACTIVE and data.MANTLEHOLY_ACTIVE>0) then
        pl.TearFlags = pl.TearFlags | TearFlags.TEAR_GLOW
        if(data.MANTLEHOLY_ACTIVE~=data.MANTLEHOLY_ACTIVE//1) then
            pl.TearFlags = pl.TearFlags | TearFlags.TEAR_HOMING
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_TEARFLAG)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_HOLY] = true end