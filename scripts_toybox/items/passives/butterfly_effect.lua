local DMG_ADD = 0.2
local DMG_MULT = 1.2
local DMG_EXPO = 1.2

---@param pl EntityPlayer
---@param val number
local function evalCache(_, pl, _, val)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_BUTTERFLY_EFFECT)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_BUTTERFLY_EFFECT)

    return ((val+mult*DMG_ADD)*(DMG_MULT^mult))^(DMG_EXPO^mult)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_STAT, CallbackPriority.LATE, evalCache, EvaluateStatStage.FLAT_DAMAGE)