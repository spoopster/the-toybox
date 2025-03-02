local mod = MilcomMOD

local strokinMyShit = false
local function replacePillEffects(_, pilleffect, color)
    if(strokinMyShit) then return end

    local dataTable = mod:getExtraDataTable()
    local pillpool = dataTable.CUSTOM_PILL_POOL
    if(pillpool and pillpool~=0) then
        local chosenPlayer = Isaac.GetPlayer()
        local phdVal = mod:getTotalPhdMask()
        if(PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.CLOWN_PHD)) then
            local rng = mod:generateRng()
            return mod:getRandomPillEffect(chosenPlayer:GetCollectibleRNG(mod.COLLECTIBLE.CLOWN_PHD), chosenPlayer, phdVal, {})
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_GET_PILL_EFFECT, CallbackPriority.LATE-1, replacePillEffects)

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    if(PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.CLOWN_PHD)) then
        mod:unidentifyPill(color)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill)