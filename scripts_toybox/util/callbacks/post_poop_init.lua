local function gridInit(_, ent, _)
    local poop = ent:ToPoop()
    Isaac.RunCallbackWithParam(ToyboxMod.CUSTOM_CALLBACKS.POST_POOP_INIT, ent:GetVariant(), poop, ent:GetVariant())
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_GRID_INIT, gridInit, GridEntityType.GRID_POOP)