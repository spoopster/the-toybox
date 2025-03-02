local mod = MilcomMOD

local DOUBLE_CHANCE = 0.2

local isDoubling = false
---@param player EntityPlayer
local function usePill(_, effect, color, player, flags)
    if(isDoubling or not player:HasTrinket(mod.TRINKET.ANTIBIOTICS)) then return end
    isDoubling = true

    local pool = Game():GetItemPool()
    if((not pool:IsPillIdentified(color)) or player:GetPillRNG(effect):RandomFloat()<DOUBLE_CHANCE) then

        local trinketMult = player:GetTrinketMultiplier(mod.TRINKET.ANTIBIOTICS)
        for _=1, trinketMult do
            player:UsePill(effect, color, flags)
        end
    end
    isDoubling = false
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_PILL, usePill)