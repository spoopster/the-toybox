local mod = MilcomMOD

local MARK_TO_ACH = {
    [CompletionType.BOSS_RUSH] = mod.ACH_ROCK_CANDY,
    [CompletionType.HUSH] = mod.ACH_SALTPETER,
    [CompletionType.ISAAC] = mod.ACH_ASCENSION,
    [CompletionType.BLUE_BABY] = mod.ACH_GLASS_VESSEL,
    [CompletionType.SATAN] = mod.ACH_MISSING_PAGE_3,
    [CompletionType.LAMB] = mod.ACH_BONE_BOY,
    [CompletionType.ULTRA_GREED] = mod.ACH_GILDED_APPLE,
    [CompletionType.ULTRA_GREEDIER] = mod.ACH_PRISMSTONE,
    [CompletionType.MOTHER] = mod.ACH_AMBER_FOSSIL,
    [CompletionType.BEAST] = mod.ACH_STEEL_SOUL,
    [CompletionType.DELIRIUM] = mod.ACH_HOSTILE_TAKEOVER,
    [CompletionType.MEGA_SATAN] = mod.ACH_MANTLES,
    [CompletionType.MOMS_HEART] = -1,
    ["ALL"] = mod.ACH_MIRACLE_MANTLE,
}

local function tryUnlockAll()
    if(Isaac.AllMarksFilled(mod.PLAYER_ATLAS_A)==2) then
        if(MARK_TO_ACH.ALL and MARK_TO_ACH.ALL~=-1) then
            Isaac.GetPersistentGameData():TryUnlock(MARK_TO_ACH.ALL)
        end
    end
end
local function tryUnlock(mark)
    local compVal = Isaac.GetCompletionMark(mod.PLAYER_ATLAS_A, mark)
    if(compVal>=(mark==CompletionType.MOMS_HEART and 2 or 1)) then
        if(MARK_TO_ACH[mark] and MARK_TO_ACH[mark]~=-1) then
            Isaac.GetPersistentGameData():TryUnlock(MARK_TO_ACH[mark])
        end
    end
end

local function checkUnlocks(_)
    if(#Isaac.FindByType(1)==0) then
        for key, _ in pairs(MARK_TO_ACH) do
            if(type(key)=="number") then
                tryUnlock(key)
            end
        end
        tryUnlockAll()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, checkUnlocks)

local function checkMark(_, mark)
    if(not mod:isAtlasA(Isaac.GetPlayer())) then return end
    local compVal = Isaac.GetCompletionMark(Isaac.GetPlayer():GetPlayerType(), mark)
    Isaac.SetCompletionMark(mod.PLAYER_ATLAS_A, mark, compVal)
    Isaac.SetCompletionMark(mod.PLAYER_ATLAS_A_TAR, mark, compVal)

    tryUnlock(mark)
    tryUnlockAll()
end
mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, checkMark)