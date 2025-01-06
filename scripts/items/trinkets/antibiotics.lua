local mod = MilcomMOD

local isDoubling = false

---@param player EntityPlayer
local function usePill(_, effect, color, player, flags)
    if(isDoubling or not player:HasTrinket(mod.TRINKET_ANTIBIOTICS)) then return end
    isDoubling = true

    local pool = Game():GetItemPool()
    if(not pool:IsPillIdentified(color)) then

        local trinketMult = player:GetTrinketMultiplier(mod.TRINKET_ANTIBIOTICS)
        for _=1, trinketMult do
            player:UsePill(effect, color, flags)
        end
    end
    isDoubling = false
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_PILL, usePill)