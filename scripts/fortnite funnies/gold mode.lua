local mod = MilcomMOD

local function makeItemGold(_, pickup)
    if(mod.CONFIG.EPIC_ITEM_MODE==2) then
        pickup:GetSprite():GetLayer("head"):SetRenderFlags(AnimRenderFlags.GOLDEN)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, makeItemGold, PickupVariant.PICKUP_COLLECTIBLE)