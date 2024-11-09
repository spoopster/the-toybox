local mod = MilcomMOD
--* Using an active has a chance to trigger the Necronomicon effect

---@param player EntityPlayer
local function missingPage2UseActive(_, player, item, slot)
    if(item and item==CollectibleType.COLLECTIBLE_NECRONOMICON) then return end
    if(not (player and player:HasCollectible(CollectibleType.COLLECTIBLE_MISSING_PAGE_2) and mod:playerHasLimitBreak(player))) then return end
    local iConfig = Isaac.GetItemConfig():GetCollectible(item)
    if(not iConfig) then return end

    local chance = 0.1
    if(iConfig.ChargeType==0) then
        local charges = iConfig.MaxCharges
        if(charges<=0) then chance = 0.0
        elseif(charges<=5) then chance = (charges+1)*0.05
        elseif(charges<=12) then chance = (charges-6)*0.1+0.4
        else chance = 1.0 end
    end

    if(player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MISSING_PAGE_2):RandomFloat()<chance) then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON)
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.USE_ACTIVE_ITEM, missingPage2UseActive)