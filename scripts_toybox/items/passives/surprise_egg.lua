local mod = ToyboxMod

---@param player EntityPlayer
local function addEgg(_, _, _, firstTime, slot, vData, player)
    if(firstTime~=true) then return end
    
    local pool = Game():GetItemPool()
    pool:ForceAddPillEffect(mod.PILL_EFFECT.CAPSULE)

    local color = pool:GetPillColor(mod.PILL_EFFECT.CAPSULE)
    if(color==-1) then color=PillColor.PILL_BLUE_BLUE end

    player:StopExtraAnimation()
    player:UsePill(mod.PILL_EFFECT.CAPSULE, color, 0)
    player:AnimatePill(color)
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addEgg, mod.COLLECTIBLE.SURPRISE_EGG)