local mod = MilcomMOD

local function makeItemRetro(_, pickup)
    pickup:GetSprite():GetLayer("head"):SetCustomShader("spriteshaders/hologramshader")
    mod:setEntityData(pickup, "PREFERREDOPTIONS_HOLOGRAM", 1)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, makeItemRetro, PickupVariant.PICKUP_COLLECTIBLE)