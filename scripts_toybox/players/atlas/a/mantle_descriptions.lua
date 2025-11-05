

local function replaceDescriptionsOnInit(_, pl)
    local atlasDescriptions = ToyboxMod:isAnyPlayerAtlasA()
    --print(atlasDescriptions)

    local conf = Isaac.GetItemConfig()
    for _, mantleData in pairs(ToyboxMod.MANTLE_DATA) do
        if(mantleData.ATLAS_DESC and mantleData.REG_DESC) then
            conf:GetCard(mantleData.CONSUMABLE_SUBTYPE).Description = (atlasDescriptions and mantleData.ATLAS_DESC or mantleData.REG_DESC)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, replaceDescriptionsOnInit)