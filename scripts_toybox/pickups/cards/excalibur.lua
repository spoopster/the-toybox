---@param pl EntityPlayer
---@param id Card
---@param flags UseFlag
local function useExcalibur(_, id, pl, flags)
    --if(pl:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    pl:UseActiveItem(ToyboxMod.COLLECTIBLE_ART_OF_WAR)
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useExcalibur, ToyboxMod.CARD_EXCALIBUR)