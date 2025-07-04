

local EXTRA_PAYOUT_CHANCE = 1/3

---@param slot EntitySlot
local function tryForceBeggarPayout(_, slot)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_LUCKY_TOOTH)) then return end

    local sp = slot:GetSprite()
    if(not (sp:GetAnimationData("PayNothing") and sp:GetAnimationData("PayPrize"))) then return end

    if(sp:IsPlaying("PayNothing") and sp:GetFrame()==1) then
        local rng = slot:GetDropRNG()
        if(rng:RandomFloat()<EXTRA_PAYOUT_CHANCE*PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_LUCKY_TOOTH)) then
            slot:SetState(2)
            sp:Play("PayPrize", true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, tryForceBeggarPayout)