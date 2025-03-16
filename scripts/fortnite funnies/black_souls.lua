local mod = ToyboxMod
local sfx = SFXManager()

local RESTART_PRESSED = false
local DROP_PRESSED = false

local TEXTBOX_SETTINGS = {
    KILL = 1,
    RAPE = 2,
    CANCEL = 3,
}
local TEXTBOX_NAMES = {
    "Kill", "Rape", "Leave"
}

local TEXTBOX_ACTIVE = false
local TEXTBOX_ENT = nil
local TEXTBOX_SETTING = 0

local RAPE_SCREEN_ACTIVE = false

local SEARCH_POS = 2*40

local interactables = {
    ["904.0.0"] = 0,
    ["36.0.0"] = 0,
    ["23.2.0"] = 0,
    ["28.2.0"] = 0,
    ["28.0.0"] = 0,
    ["97.0.0"] = 0,
    ["98.0.0"] = 0,
    ["100.0.0"] = 0,
    ["413.0.0"] = 0,
    ["47.0.0"] = 0,
    ["47.1.0"] = 0,
    ["237.0.0"] = 0,
    ["237.1.0"] = 0,
    ["237.2.0"] = 0,
    ["266.0.0"] = 0,
    ["266.1.0"] = 0,
    ["266.2.0"] = 0,
    ["410.0.0"] = 0,
    ["808.0.0"] = 0,
    ["838.0.0"] = 0,
    ["908.0.0"] = 0,
    ["913.0.0"] = 0,
    ["917.0.0"] = 0,
}

local function canInteract(ent)
    local entStr = tostring(ent.Type).."."..tostring(ent.Variant)..".0"
    return (interactables[entStr]~=nil)
end
local function interactWithEntity(ent)
    RESTART_PRESSED = false
    TEXTBOX_ACTIVE = true
    TEXTBOX_ENT = ent
    TEXTBOX_SETTING = TEXTBOX_SETTINGS.KILL
end

---@param pl EntityPlayer
local function tryInteractWithEntity(_, pl)
    RESTART_PRESSED = false
    DROP_PRESSED = false

    if(Input.IsActionTriggered(ButtonAction.ACTION_RESTART, pl.ControllerIndex)) then
        RESTART_PRESSED = true
        if(not TEXTBOX_ACTIVE) then
            for _, ent in ipairs(Isaac.GetRoomEntities()) do
                if(canInteract(ent) and ent.Position:Distance(pl.Position)<SEARCH_POS) then
                    interactWithEntity(ent)
                    break
                end
            end
        end
    end

    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, pl.ControllerIndex)) then
        DROP_PRESSED = true
    end

    if(RAPE_SCREEN_ACTIVE) then
        RAPE_SCREEN_ACTIVE = false
        pl:AddHearts(99)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, tryInteractWithEntity)

local font = Font()
font:Load("font/pftempestasevencondensed.fnt")

---@param ent Entity
---@param offset Vector
local function postEntityRender(_, ent, offset)
    if(not TEXTBOX_ACTIVE) then return end
    if(not (TEXTBOX_ENT and GetPtrHash(TEXTBOX_ENT)==GetPtrHash(ent))) then return end

    if(DROP_PRESSED) then
        TEXTBOX_SETTING = TEXTBOX_SETTING%(#TEXTBOX_NAMES)+1
        sfx:Play(SoundEffect.SOUND_BEEP)
    end

    local textScale = 0.5
    local renderPos = Isaac.WorldToRenderPosition(ent.Position)+Vector(30,-20)
    for i, text in ipairs(TEXTBOX_NAMES) do
        local curPos = renderPos+(i-1)*Vector(0,10)*textScale
        local col = KColor(0.5,0.5,0.5,1)
        if(i==TEXTBOX_SETTINGS.KILL or i==TEXTBOX_SETTINGS.RAPE) then
            col = KColor(0.5,0,0,1)
            if(i==TEXTBOX_SETTING) then
                col = KColor(1,0,0,1)
            end
        elseif(i==TEXTBOX_SETTING) then
            col = KColor(1,1,1,1)
        end
        

        font:DrawStringScaled(text, curPos.X, curPos.Y, textScale, textScale, col)
    end

    local arrowPos = renderPos+(TEXTBOX_SETTING-1)*Vector(0,10)*textScale
    arrowPos = arrowPos+Vector(-15*textScale,0)+Vector(2*math.sin(math.rad(ent.FrameCount)*10),0)
    font:DrawStringScaled("->", arrowPos.X, arrowPos.Y, textScale, textScale, KColor(1,1,1,1))

    ent:SetPauseTime(1)

    if(RESTART_PRESSED) then
        if(TEXTBOX_SETTING==TEXTBOX_SETTINGS.KILL) then
            ent:Kill()
            ent:SetPauseTime(0)
        elseif(TEXTBOX_SETTING==TEXTBOX_SETTINGS.RAPE) then
            ItemOverlay.Show(Giantbook.SLEEP, 0, Isaac.GetPlayer())
            RAPE_SCREEN_ACTIVE = true

            TEXTBOX_ENT.HitPoints = 1
            TEXTBOX_ENT:AddCharmed(EntityRef(Isaac.GetPlayer()), -1)
        end
        TEXTBOX_ACTIVE = false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, postEntityRender)
