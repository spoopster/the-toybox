local mod = MilcomMOD

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.SALT.ID)
    else
        local rng = player:GetCardRNG(mod.CONSUMABLE.MANTLE_SALT)
        local conf = Isaac.GetItemConfig()
        local isOk = false
        local finalItem
        while(not isOk) do
            isOk = true

            finalItem = rng:RandomInt(conf:GetCollectibles().Size-1)+1
            local fConfig = conf:GetCollectible(finalItem)

            if(not fConfig) then
                isOk = false
            elseif(not fConfig:IsAvailable()) then
                isOk = false
            elseif(not fConfig:HasTags(ItemConfig.TAG_SUMMONABLE)) then
                isOk = false
            elseif(not fConfig:HasTags(ItemConfig.TAG_TEARS_UP)) then
                isOk = false
            end
        end

        mod.HiddenItemManager:AddForRoom(player, finalItem, nil, 1, "TOYBOX")
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE.MANTLE_SALT)

if(mod.ATLAS_A_MANTLESUBTYPES) then mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE.MANTLE_SALT] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(mod.CONSUMABLE.MANTLE_SALT).Weight = (mod.CONFIG.MANTLE_WEIGHT or 0.5)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)