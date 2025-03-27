local mod = ToyboxMod

function mod:checkUnlocks(blockPaper)
    for _, unlockData in ipairs(mod.ACHIEVEMENTS) do
        if(unlockData.Condition()) then
            Isaac.GetPersistentGameData():TryUnlock(unlockData.Achievement, blockPaper)
        else
            Isaac.ExecuteCommand("lockachievement " .. unlockData.Achievement)
        end
    end
end

local function checkUnlockOnInit(_)
    mod:checkUnlocks(false)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, checkUnlockOnInit)

local function checkUnlocksOnCompletion(_, mark)
    mod:checkUnlocks(false)
end
mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, checkUnlocksOnCompletion)