local sfx = SFXManager()

local MAX_USES = 6

local ACTIVE_TEARS_UP = 2
local ACTIVE_DMG_UP = 2.5
local ACTIVE_RANGE_UP = 1.5
local ACTIVE_LUCK_UP = 4

local PASSIVE_DMG_UP = -1
local PASSIVE_LUCK_UP = -2

---@param player EntityPlayer
---@param slot ActiveSlot
local function useWhiteDaisy(_, _, rng, player, flags, slot)
    local data = (slot==-1 and 0 or player:GetActiveItemDesc(slot).VarData)

    if(data>=MAX_USES) then
        sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 0.8)

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
    else
        local plData = ToyboxMod:getEntityDataTable(player)
        plData.WHITE_DAISY_USES = (plData.WHITE_DAISY_USES or 0)+1

        if(slot~=-1) then
            local toAdd = (player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 2 or 1)
            player:SetActiveVarData(math.min(data+toAdd, MAX_USES), slot)
        end

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useWhiteDaisy, ToyboxMod.COLLECTIBLE_WHITE_DAISY)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    local activeMult = ToyboxMod:getEntityData(player, "WHITE_DAISY_USES") or 0
    local passiveMult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_WHITE_DAISY)

    if(activeMult==0 and passiveMult==0) then return end
    
    if(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, activeMult*ACTIVE_TEARS_UP)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(player, passiveMult*PASSIVE_DMG_UP+activeMult*ACTIVE_DMG_UP)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+40*activeMult*ACTIVE_RANGE_UP
    elseif(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+activeMult*ACTIVE_LUCK_UP+passiveMult*PASSIVE_LUCK_UP
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
local function removeActiveEffect(_, pl)
    ToyboxMod:setEntityData(pl, "WHITE_DAISY_USES", 0)
    pl:AddCacheFlags(CacheFlag.CACHE_ALL)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, removeActiveEffect)

---@param pl EntityPlayer
local function refreshWhiteDaisy(_, pl)
    if(pl.FrameCount==0) then return end

    for _, slot in pairs(ActiveSlot) do
        local data = pl:GetActiveItemDesc(slot)
        if(data.Item==ToyboxMod.COLLECTIBLE_WHITE_DAISY) then
            data.VarData = 0
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, refreshWhiteDaisy)

---@param pl EntityPlayer
---@param slot EntitySlot
local function renderWhiteDaisy(_, pl, slot)
    local data = math.min(slot==-1 and 0 or pl:GetActiveItemDesc(slot).VarData, MAX_USES)

    return {CropOffset = Vector(32*data,0)}
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, renderWhiteDaisy)

---@param id CollectibleType
---@param pl EntityPlayer
local function removeWhiteDaisyCharge(_, id, pl, vardata, current)
    if(id==ToyboxMod.COLLECTIBLE_WHITE_DAISY and vardata>=MAX_USES) then
        return 0
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, removeWhiteDaisyCharge)