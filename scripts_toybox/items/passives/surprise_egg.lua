

---@param player EntityPlayer
local function addEgg(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    
    local pool = Game():GetItemPool()
    pool:ForceAddPillEffect(ToyboxMod.PILL_CAPSULE)

    local color = pool:GetPillColor(ToyboxMod.PILL_CAPSULE)
    if(color==-1) then color=PillColor.PILL_BLUE_BLUE end

    player:StopExtraAnimation()
    player:UsePill(ToyboxMod.PILL_CAPSULE, color, 0)
    player:AnimatePill(color)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addEgg, ToyboxMod.COLLECTIBLE_SURPRISE_EGG)