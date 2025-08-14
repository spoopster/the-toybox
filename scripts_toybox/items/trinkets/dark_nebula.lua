local function isValidStage()
    local totalMult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_DARK_NEBULA)
    if(totalMult==0) then return false end

    local level = Game():GetLevel()
    if(level:GetStageType()==StageType.STAGETYPE_ORIGINAL) then
        if(level:GetStage()==LevelStage.STAGE5 or (totalMult>1 and level:GetStage()==LevelStage.STAGE6)) then
            return true
        end
    end
    return false
end


local function cancelStagePenalty(_)
    if(isValidStage()) then
        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLANETARIUM_APPLY_STAGE_PENALTY, cancelStagePenalty)

local function applyGuaranteedChance(_)
    if(isValidStage()) then
        return 1
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLANETARIUM_CALCULATE, applyGuaranteedChance)