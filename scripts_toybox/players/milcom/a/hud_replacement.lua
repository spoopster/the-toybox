

local WAS_MILCOM_EXIST = false

local PICKUPS_FONT = Font()
PICKUPS_FONT:Load("font/pftempestasevencondensed.fnt")

local GRAY_COLOR = KColor(0.5,0.5,0.5,1)

local function postGameStarted(_)
    WAS_MILCOM_EXIST = false
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)

local function postRender(_)
    local isMilcomExist = PlayerManager.AnyoneIsPlayerType(ToyboxMod.PLAYER_TYPE.MILCOM_A)
    local sp = Game():GetHUD():GetPickupsHUDSprite()
    if(isMilcomExist and not WAS_MILCOM_EXIST) then
        sp:ReplaceSpritesheet(0, "gfx_tb/ui/ui_milcom_hud.png", true)
    elseif(WAS_MILCOM_EXIST and not isMilcomExist) then
        sp:ReplaceSpritesheet(0, "gfx_tb/ui/hudpickups.png", true)
    end
    WAS_MILCOM_EXIST = isMilcomExist

    if(not Game():GetHUD():IsVisible()) then return end

    local pl = PlayerManager.FirstPlayerByType(ToyboxMod.PLAYER_TYPE.MILCOM_A)
    if(not pl) then return end

    local renderPos = Vector(20,12)*Options.HUDOffset + Vector(16,45) + Game().ScreenShakeOffset

    -- bombs
    local bombText = tostring(pl:GetNumBombs())
    local bombMaxLength = 1
    while(10^bombMaxLength<pl:GetMaxBombs()) do bombMaxLength = bombMaxLength+1 end
    local bombTextLength = string.len(bombText)

    for _=1, bombMaxLength-bombTextLength do
        bombText = "0"..bombText
    end
    PICKUPS_FONT:DrawString(bombText, renderPos.X, renderPos.Y, GRAY_COLOR)

    -- keys
    local keyText = tostring(pl:GetNumKeys())
    local keyMaxLength = 1
    while(10^keyMaxLength<pl:GetMaxKeys()) do keyMaxLength = keyMaxLength+1 end
    local keyTextLength = string.len(keyText)

    for _=1, keyMaxLength-keyTextLength do
        keyText = "0"..keyText
    end
    PICKUPS_FONT:DrawString(keyText, renderPos.X, renderPos.Y+12, GRAY_COLOR)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postRender)