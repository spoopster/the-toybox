

local function makeItemRetro(_, pickup)
    if(ToyboxMod.CONFIG.EPIC_ITEM_MODE==ToyboxMod.ENUMS.ITEM_SHADER_RETRO) then
        pickup:GetSprite():GetLayer("head"):SetCustomShader("spriteshaders/hologramshader")
        ToyboxMod:setEntityData(pickup, "PREFERREDOPTIONS_HOLOGRAM", 1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, makeItemRetro, PickupVariant.PICKUP_COLLECTIBLE)