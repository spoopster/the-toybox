local mod = MilcomMOD

mod.THROWABLE_ITEMS = {}
function mod:registerThrowableActive(item, willDischarge, willRemove)
    if(willDischarge==nil) then willDischarge=true end
    if(willRemove==nil) then willRemove=false end

    mod.THROWABLE_ITEMS[item] = {
        DISCHARGE = willDischarge,
        REMOVE = willRemove,
    }
end

local function useThrowable(_, item, rng, player, flags, slot)
    if(flags & UseFlag.USE_CARBATTERY ~= 0) then return end
    local pData = mod:getEntityDataTable(player)

    if(pData.THROWABLE_DATA and item==pData.THROWABLE_DATA.ITEM) then
        player:AnimateCollectible(item, "HideItem", "PlayerPickup")
        pData.THROWABLE_DATA=nil
        player:SetItemState(0)

        return {
            Discharge=false,
            Remove=false,
            ShowAnim=false,
        }
    elseif(mod.THROWABLE_ITEMS[item]) then
        player:AnimateCollectible(item, "LiftItem", "PlayerPickup")
        pData.THROWABLE_DATA = {
            ITEM=item,
            RNG=rng,
            FLAGS=flags,
            SLOT=slot,
            DISCHARGE = mod.THROWABLE_ITEMS[item].DISCHARGE,
            REMOVE = mod.THROWABLE_ITEMS[item].REMOVE,
        }
        player:SetItemState(item)

        return {
            Discharge=false,
            Remove=false,
            ShowAnim=false,
        }
    else
        if(pData.THROWABLE_DATA and player:GetItemState()==pData.THROWABLE_DATA.ITEM) then player:SetItemState(0) end
        pData.THROWABLE_DATA=nil
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.LATE, useThrowable)

---@param player EntityPlayer
local function updateThrowable(_, player)
    local pData = mod:getEntityDataTable(player)

    if(pData.THROWABLE_DATA) then
        if(player:GetItemState()==pData.THROWABLE_DATA.ITEM) then
            local joystick = player:GetAimDirection()

            if(joystick:Length()>0.05) then
                if(pData.THROWABLE_DATA.DISCHARGE) then player:DischargeActiveItem(pData.THROWABLE_DATA.SLOT) end

                Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.USE_THROWABLE_ACTIVE, pData.THROWABLE_DATA.ITEM, pData.THROWABLE_DATA.ITEM, player, pData.THROWABLE_DATA.RNG, pData.THROWABLE_DATA.FLAGS, pData.THROWABLE_DATA.SLOT, 1)

                player:AnimateCollectible(pData.THROWABLE_DATA.ITEM, "HideItem", "PlayerPickup")
                if(pData.THROWABLE_DATA.REMOVE) then player:RemoveCollectible(pData.THROWABLE_DATA.ITEM, false, pData.THROWABLE_DATA.SLOT) end
                player:SetItemState(0)
                pData.THROWABLE_DATA = nil
            end
        elseif(player:GetItemState()~=0) then
            pData.THROWABLE_DATA = nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateThrowable)

local function cancelThrowableOnDmg(_, p)
    p=p:ToPlayer()
    local pData = mod:getEntityDataTable(p)
    if(pData.THROWABLE_DATA and p:GetItemState()==pData.THROWABLE_DATA.ITEM) then
        p:AnimateCollectible(pData.THROWABLE_DATA.ITEM, "HideItem", "PlayerPickup")
        p:SetItemState(0)
        pData.THROWABLE_DATA = nil
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, cancelThrowableOnDmg, EntityType.ENTITY_PLAYER)

local function cancelThrowableOnNewRoom(_)
    for i=0, Game():GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(i)
        local pData = mod:getEntityDataTable(p)
        if(pData.THROWABLE_DATA) then
            p:AnimateCollectible(pData.THROWABLE_DATA.ITEM, "HideItem", "PlayerPickup")
            p:SetItemState(0)
            pData.THROWABLE_DATA = nil
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, cancelThrowableOnNewRoom)