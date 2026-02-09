---@param key string
---@param amount number?
local function incrementEventCounter(key, amount)
    ToyboxMod:setPersistentData(key, (ToyboxMod:getPersistentData(key) or 0)+(amount or 1))
    ToyboxMod:checkUnlocks(false)
end

local PREV_LEVEL = nil

local function increaseLevelClearCounts(_)
    if(PREV_LEVEL) then
        if(PREV_LEVEL.Type==StageType.STAGETYPE_AFTERBIRTH) then
            if(PREV_LEVEL.Stage==LevelStage.STAGE1_1 or PREV_LEVEL.Stage==LevelStage.STAGE1_2) then -- B. Basement
                incrementEventCounter("BURNING_BASEMENT_CLEARS")
            elseif(PREV_LEVEL.Stage==LevelStage.STAGE2_1 or PREV_LEVEL.Stage==LevelStage.STAGE2_2) then -- F. Caves
                incrementEventCounter("FLOODED_CAVES_CLEARS")
            elseif(PREV_LEVEL.Stage==LevelStage.STAGE3_1 or PREV_LEVEL.Stage==LevelStage.STAGE3_2) then -- D. Depths
                incrementEventCounter("DANK_DEPTHS_CLEARS")
            elseif(PREV_LEVEL.Stage==LevelStage.STAGE4_1 or PREV_LEVEL.Stage==LevelStage.STAGE4_2) then -- S. Womb
                incrementEventCounter("SCARRED_WOMB")
            end
        end
    end
    local level = Game():GetLevel()
    PREV_LEVEL = {Stage=level:GetStage(), Type=level:GetStageType(), AbsStage=level:GetAbsoluteStage()}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, increaseLevelClearCounts)

local function resetPrevLevel(_)
    PREV_LEVEL = nil
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, resetPrevLevel)