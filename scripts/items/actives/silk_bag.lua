local mod = MilcomMOD
local sfx = SFXManager()

local MAX_USES = 8
local BATTERY_MAX_USES = 16

local USES_PER_FLOOR = 4
local NINEVOLT_USES_PER_FLOOR = 5

local INVINCIBILITY_DURATION = 30 -- 0.5 seconds
local USE_COLOR = Color(1,1,1,1,1,0.5)

---@param player EntityPlayer
local function useSilkBag(_, _, rng, player, flags, slot, vData)
    if(slot==-1) then
        mod:addInvincibility(player, INVINCIBILITY_DURATION*(1+player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CAR_BATTERY)))
        player:SetColor(USE_COLOR, 5, 1, true, false)
        sfx:Play(mod.SFX_SILK_BAG_SHIELD, 0.6)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    else
        if(Game():GetDebugFlags() & DebugFlag.INFINITE_ITEM_CHARGES == 0) then
            player:GetActiveItemDesc(slot).VarData = player:GetActiveItemDesc(slot).VarData-1
        end
        local isRemoved = (player:GetActiveItemDesc(slot).VarData<=0)

        mod:addInvincibility(player, INVINCIBILITY_DURATION*(player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 2 or 1))
        player:SetColor(USE_COLOR, 5, 1, true, false)
        sfx:Play(mod.SFX_SILK_BAG_SHIELD, 0.6)

        if(isRemoved) then
            sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
        end

        return {
            Discharge = true,
            Remove = isRemoved,
            ShowAnim = true,
        }
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useSilkBag, mod.COLLECTIBLE_SILK_BAG)

---@param player EntityPlayer
local function postAddItem(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    player:GetActiveItemDesc(slot).VarData = MAX_USES
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem, mod.COLLECTIBLE_SILK_BAG)

---@param player EntityPlayer
local function addChargesToItem(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_SILK_BAG)) then return end
    for _, i in pairs(ActiveSlot) do
        if(player:GetActiveItem(i)==mod.COLLECTIBLE_SILK_BAG) then
            local toAdd = (player:HasCollectible(CollectibleType.COLLECTIBLE_9_VOLT) and NINEVOLT_USES_PER_FLOOR or USES_PER_FLOOR)
            local maxUses = (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and BATTERY_MAX_USES or MAX_USES)

            player:GetActiveItemDesc(i).VarData = math.min(player:GetActiveItemDesc(i).VarData+toAdd, maxUses)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, addChargesToItem)

local f = Font("font/pftempestasevencondensed.fnt")

---@param player EntityPlayer
local function renderCounter(_, player, slot, offset, alpha, scale)
    if(slot==1) then return end
    local item = player:GetActiveItem(slot)
    if(item~=mod.COLLECTIBLE_SILK_BAG) then return end
    f:DrawString("x"..player:GetActiveItemDesc(slot).VarData,offset.X+24, offset.Y+18,KColor(1,1,1,alpha))
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderCounter)