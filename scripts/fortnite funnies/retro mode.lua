local mod = MilcomMOD

local function makeItemRetro(_, pickup)
    if(mod.CONFIG.EPIC_ITEM_MODE==1) then
        pickup:GetSprite():GetLayer("head"):SetCustomShader("spriteshaders/hologramshader")
        mod:setEntityData(pickup, "PREFERREDOPTIONS_HOLOGRAM", 1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, makeItemRetro, PickupVariant.PICKUP_COLLECTIBLE)