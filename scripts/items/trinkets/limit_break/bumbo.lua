local mod = MilcomMOD
--* Coins count as double value when picked up by Bumbo

local function postFamiliarColl(_, familiar, collider)
    if(not (collider.Type==5 and collider.Variant==20)) then return end
    if(not (familiar.Player and mod:playerHasLimitBreak(familiar.Player))) then return end

    familiar.Coins = familiar.Coins + collider:ToPickup():GetCoinValue()
end
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, postFamiliarColl, FamiliarVariant.BUMBO)