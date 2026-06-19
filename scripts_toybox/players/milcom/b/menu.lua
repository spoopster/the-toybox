local RENDER_FRAMES = 0
local RENDER_CHANGE_FREQ = 45

---@param sprite Sprite
local function changePortraitRenderFrame(_, _, sprite)
    local frame = ((RENDER_FRAMES//RENDER_CHANGE_FREQ)%2)*2
    
    local isUnlocked = false
    if(CharacterMenu.GetPlayerTypeFromCharacterMenuID(CharacterMenu.GetSelectedCharacterID())==ToyboxMod.PLAYER_MILCOM_B) then
        isUnlocked = CharacterMenu.GetIsCharacterUnlocked()
    else
        isUnlocked = Isaac.GetPersistentGameData():Unlocked(ToyboxMod.ACHIEVEMENT_MILCOM_B)
    end

    if(not isUnlocked) then
        frame = frame+1
    end

    sprite:SetFrame(frame)

    RENDER_FRAMES = (RENDER_FRAMES+1)%(2*RENDER_CHANGE_FREQ)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_RENDER_CHARACTER_SELECT_PORTRAIT, changePortraitRenderFrame, ToyboxMod.PLAYER_MILCOM_B)