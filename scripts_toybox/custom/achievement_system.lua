

function ToyboxMod:checkUnlocks(blockPaper)
    for _, unlockData in ipairs(ToyboxMod.ACHIEVEMENTS) do
        if(unlockData.Condition()) then
            Isaac.GetPersistentGameData():TryUnlock(unlockData.Achievement, blockPaper)
        else
            Isaac.ExecuteCommand("lockachievement " .. unlockData.Achievement)
        end
    end
end

local function checkUnlockOnInit(_)
    ToyboxMod:checkUnlocks(false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, checkUnlockOnInit)

local function checkUnlocksOnCompletion(_, mark)
    ToyboxMod:checkUnlocks(false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, checkUnlocksOnCompletion)