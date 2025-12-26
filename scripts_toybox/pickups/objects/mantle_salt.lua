local sfx = SFXManager()

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.SALT.ID)
    else
        local rng = player:GetCardRNG(ToyboxMod.CARD_MANTLE_SALT)
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

        ToyboxMod:addItemForRoom(player, finalItem, 1)
        --ToyboxMod.HiddenItemManager:AddForRoom(player, finalItem, nil, 1, "TOYBOX")
        player:AnimateCollectible(finalItem)
        sfx:Play(SoundEffect.SOUND_POWERUP1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_SALT)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_SALT] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(ToyboxMod.CARD_MANTLE_SALT).Weight = (ToyboxMod.CONFIG.MANTLE_WEIGHT or 0.5)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)