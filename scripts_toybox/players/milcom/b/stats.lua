

---@param player EntityPlayer
local function milcomBInit(_, player)
    if(player:GetPlayerType()==ToyboxMod.PLAYER_TYPE.MILCOM_B) then
        local pgd = Isaac.GetPersistentGameData()
        if(not pgd:Unlocked(ToyboxMod.ACHIEVEMENT.MILCOM_B)) then
            player:ChangePlayerType(0)
            player:AddMaxHearts(6)
            player:AddHearts(6)
            player:InitPostLevelInitStats()
            player:AddSoulHearts(-1)
            SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 1, 0, false, 1, 0)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, milcomBInit)