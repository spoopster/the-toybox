

local strokinMyShit = false
local function replacePillEffects(_, pilleffect, color)
    if(strokinMyShit) then return end

    local dataTable = ToyboxMod:getExtraDataTable()
    local pillpool = dataTable.CUSTOM_PILL_POOL
    if(pillpool and pillpool~=0) then
        local chosenPlayer = Isaac.GetPlayer()
        local phdVal = ToyboxMod:getTotalPhdMask()
        if(PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_CLOWN_PHD)) then
            local rng = ToyboxMod:generateRng()
            return ToyboxMod:getRandomPillEffect(chosenPlayer:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CLOWN_PHD), chosenPlayer, phdVal, {})
        end
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_GET_PILL_EFFECT, CallbackPriority.LATE-1, replacePillEffects)

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    if(PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_CLOWN_PHD)) then
        ToyboxMod:unidentifyPill(color)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill)