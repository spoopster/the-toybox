local UPGRADE_CHANCE = 1/2

---@param fam EntityFamiliar
local function blueInsectInit(_, fam)
    if(Isaac.GetPlayer().FrameCount==0) then return end
    if(not fam.Player:HasCollectible(ToyboxMod.COLLECTIBLE_UNSTABLE_DNA)) then return end

    local mult = fam.Player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_UNSTABLE_DNA)

    local rng = ToyboxMod:generateRng(fam.InitSeed)
    local type = ToyboxMod:getBlueInsectTypeCol(fam)
    if(type==0 and rng:RandomFloat()<(1-(1-UPGRADE_CHANCE)^mult)) then
        ToyboxMod:makeRandomUpgradedInsect(fam)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, 1, blueInsectInit, FamiliarVariant.BLUE_FLY)
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, 1, blueInsectInit, FamiliarVariant.BLUE_SPIDER)