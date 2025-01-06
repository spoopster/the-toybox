local mod = MilcomMOD

local MARK_TO_ACH = {
    [CompletionType.BOSS_RUSH] = mod.ACH_JONAS_LOCK,
    [CompletionType.HUSH] = mod.ACH_WONDER_DRUG,
    [CompletionType.ISAAC] = mod.ACH_DADS_PRESCRIPTION,
    [CompletionType.BLUE_BABY] = mod.ACH_CANDY_DISPENSER,
    [CompletionType.SATAN] = mod.ACH_DR_BUM,
    [CompletionType.LAMB] = mod.ACH_JONAS_MASK,
    [CompletionType.ULTRA_GREED] = mod.ACH_ANTIBIOTICS,
    [CompletionType.ULTRA_GREEDIER] = mod.ACH_FOIL_CARD,
    [CompletionType.MOTHER] = mod.ACH_HORSE_TRANQUILIZER,
    [CompletionType.BEAST] = mod.ACH_CLOWN_PHD,
    [CompletionType.DELIRIUM] = mod.ACH_GIANT_CAPSULE,
    [CompletionType.MEGA_SATAN] = -1,
    [CompletionType.MOMS_HEART] = -1,
    ["ALL"] = -1,
}

local function tryUnlockAll()
    if(Isaac.AllMarksFilled(mod.PLAYER_JONAS_A)==2) then
        if(MARK_TO_ACH.ALL and MARK_TO_ACH.ALL~=-1) then
            Isaac.GetPersistentGameData():TryUnlock(MARK_TO_ACH.ALL)
        end
    end
end
local function tryUnlock(mark)
    local compVal = Isaac.GetCompletionMark(mod.PLAYER_JONAS_A, mark)

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
    if(Isaac.GetPlayer():GetPlayerType()~=mod.PLAYER_JONAS_A) then return end
    tryUnlock(mark)
    tryUnlockAll()
end
mod:AddCallback(ModCallbacks.MC_POST_COMPLETION_EVENT, checkMark)