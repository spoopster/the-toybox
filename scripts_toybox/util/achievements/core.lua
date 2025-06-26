ToyboxMod.ACHIEVEMENTS = {
    COMPLETION_MARKS = {},
    MISCELLANEOUS = {},
}

---@param playerType PlayerType
---@param mark CompletionType
---@param threshold Difficulty?
function ToyboxMod:completionMarkCondition(playerType, mark, threshold)
    return function()
        return Isaac.GetCompletionMark(playerType, mark)>(threshold or Difficulty.DIFFICULTY_NORMAL)
    end
end
---@param playerType PlayerType
---@param threshold Difficulty?
function ToyboxMod:allMarkCondition(playerType, threshold)
    return function()
        return Isaac.AllMarksFilled(playerType)>(threshold or Difficulty.DIFFICULTY_NORMAL)
    end
end

---@param achievement Achievement
---@param condition function
---@param completionMarkUnlock boolean?
function ToyboxMod:addAchievement(achievement, condition, completionMarkUnlock)
    local achData = {
        Achievement = achievement,
        Condition = condition,
    }

    if(completionMarkUnlock==nil) then completionMarkUnlock=true end

    if(completionMarkUnlock) then
        table.insert(ToyboxMod.ACHIEVEMENTS.COMPLETION_MARKS, achData)
    else
        table.insert(ToyboxMod.ACHIEVEMENTS.MISCELLANEOUS, achData)
    end
end

include("scripts_toybox.util.achievements.enums")

---@param completionUnlocks boolean
---@param blockPaper boolean?
function ToyboxMod:checkUnlocks(completionUnlocks, blockPaper)
    local key = "MISCELLANEOUS"
    if(completionUnlocks) then
        key = "COMPLETION_MARKS"
    end

    for _, unlockData in ipairs(ToyboxMod.ACHIEVEMENTS[key]) do
        if(unlockData.Condition()) then
            Isaac.GetPersistentGameData():TryUnlock(unlockData.Achievement, blockPaper)
        else
            print("YUP", unlockData.Achievement)
            Isaac.ExecuteCommand("lockachievement " .. unlockData.Achievement)
        end
    end
end

local function checkUnlockOnInit(_)
    ToyboxMod:checkUnlocks(true)
    ToyboxMod:checkUnlocks(false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, checkUnlockOnInit)

local function checkUnlocksOnCompletion(_, mark)
    ToyboxMod:checkUnlocks(true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, checkUnlocksOnCompletion)