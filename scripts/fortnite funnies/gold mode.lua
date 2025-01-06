local mod = MilcomMOD

local function makeItemGold(_, pickup)
    pickup:GetSprite():GetLayer("head"):SetRenderFlags(AnimRenderFlags.GOLDEN)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, makeItemGold, PickupVariant.PICKUP_COLLECTIBLE)