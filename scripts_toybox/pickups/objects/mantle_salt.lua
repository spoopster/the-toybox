local sfx = SFXManager()

local CARBATTERY_ITEMS = 2

---@param player EntityPlayer
---@param flags UseFlag
local function useMantle(_, _, player, flags)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CONGLOMERATE) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.SALT.ID)
    else
        local numitems = 1
        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            numitems = CARBATTERY_ITEMS
        end
        for i=1, numitems do
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

            if(flags & UseFlag.USE_CARBATTERY ~= 0) then
                ToyboxMod:addItemForLevel(player, finalItem, 1)
            else
                ToyboxMod:addItemForRoom(player, finalItem, 1)
            end
            
            Isaac.CreateTimer(function()
                player:AnimateCollectible(finalItem)
                sfx:Play(SoundEffect.SOUND_POWERUP1)
            end, 20*(i-1), 1, true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_SALT)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_SALT] = true end