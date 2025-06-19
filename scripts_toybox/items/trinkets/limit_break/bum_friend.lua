
--* Coins count as double value when picked up by Bum Friend

local function postFamiliarColl(_, familiar, collider)
    if(not (collider.Type==5 and collider.Variant==20)) then return end
    if(not (familiar.Player and ToyboxMod:playerHasLimitBreak(familiar.Player))) then return end

    familiar.Coins = familiar.Coins + collider:ToPickup():GetCoinValue()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, postFamiliarColl, FamiliarVariant.BUM_FRIEND)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, postFamiliarColl, FamiliarVariant.SUPER_BUM)