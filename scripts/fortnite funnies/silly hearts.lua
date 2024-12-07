local mod = MilcomMOD
local sfx = SFXManager()

---@param pl Entity
local function dsadasdad(_, pl, dmg)
    pl = pl:ToPlayer()
    mod:setEntityData(pl, "JUST_GOT_HURT", 1)
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, CallbackPriority.LATE, dsadasdad, EntityType.ENTITY_PLAYER)

local function initHeartTable(pl)
    local data = mod:getEntityDataTable(pl)
    data.UI_HEART_DATA = {INITIALIZED=false}
end
local function initHeartData(pl, pos, idx)
    return {
        POS = pos+Vector((idx-1)%6, (idx-1)//6)*Vector(12,10),
        VEL = Vector.Zero,
        TARGETPOS = nil,
        FRICTION = 0.94,
        WALLFRICTION = 0.5,
        GRAVITY = 0,--0.81,
        GRAVITYFRAMES = 0,
        PLAYSFX = false,
    }
end
function mod:invalidateTables()
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        mod:setEntityData(pl, "UI_HEART_DATA", nil)
    end
end
function mod:setHeartValue(key, val)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local data = mod:getEntityDataTable(pl)

        for idx, d in ipairs(data.UI_HEART_DATA) do
            d[key] = val
        end
    end
end

local function postHudRender()
    if(Game():IsPaused()) then return end
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local hud = Game():GetHUD():GetPlayerHUD(i)
        local data = mod:getEntityDataTable(pl)
        local hData = data.UI_HEART_DATA

        if(hData==nil) then
            initHeartTable(pl)
            return
        elseif(not hData.INITIALIZED) then
            return
        end

        if(data.JUST_GOT_HURT and data.JUST_GOT_HURT>0) then
            data.JUST_GOT_HURT = nil

            local rng = mod:generateRng()
            for idx, d in ipairs(hData) do
                d.VEL = d.VEL+Vector(10,1)*Vector.FromAngle(--[[rng:RandomInt(40)+250]] rng:RandomInt(360)):Resized((rng:RandomFloat()*0.5+0.5)*3)
                d.GRAVITY = 0.8+rng:RandomFloat()*0.1
                d.GRAVITYFRAMES = 0
            end
        end

        if(i~=0) then goto invalidPlayer end

        local IS_MOUSE_BTN = Input.IsMouseBtnPressed(MouseButton.LEFT)
        if(IS_MOUSE_BTN) then
            local mousePos = Isaac.WorldToScreen(Input.GetMousePosition(true))--/(Isaac.GetScreenPointScale())--*Isaac.GetScreenWidth()/Isaac.GetScreenHeight()

            if(not data.PREV_MOUSE_BTN) then-- just pressed mouse
                data.CUR_HELD_HEART = nil
                local minDist = 20

                for idx, d in ipairs(hData) do
                    local dist = d.POS:Distance(mousePos)
                    --print(idx, hud:GetHeartByIndex(idx-1):IsVisible())
                    if(dist<minDist and hud:GetHeartByIndex(idx-1):IsVisible()) then
                        minDist = dist
                        data.CUR_HELD_HEART = idx
                    end
                end
            end

            if(data.CUR_HELD_HEART) then
                local MAX_DIF_LENGTH = 100
                local dif = mousePos-hData[data.CUR_HELD_HEART].POS
                if(dif:Length()>MAX_DIF_LENGTH) then dif = dif:Resized(MAX_DIF_LENGTH) end

                hData[data.CUR_HELD_HEART].VEL = mod:lerp(hData[data.CUR_HELD_HEART].VEL, dif, 0.75)
                hData[data.CUR_HELD_HEART].GRAVITYFRAMES = 0
            end
        else
            if(data.PREV_MOUSE_BTN and data.CUR_HELD_HEART) then
                hData[data.CUR_HELD_HEART].VEL = hData[data.CUR_HELD_HEART].VEL*0.5
                data.CUR_HELD_HEART = nil
            end
        end

        data.PREV_MOUSE_BTN = IS_MOUSE_BTN

        ::invalidPlayer::
    end
end
mod:AddCallback(ModCallbacks.MC_HUD_RENDER, postHudRender)

---@param sprite Sprite
---@param pl EntityPlayer
local function preRenderHearts(_, _, sprite, pos, _, pl)
    local data = mod:getEntityDataTable(pl)
    local hData = data.UI_HEART_DATA
    local hud = Game():GetHUD():GetPlayerHUD(pl:GetPlayerIndex())
    local hearts = hud:GetHearts()
    local heartSprite = hud:GetHUD():GetHeartsSprite()

    if(hData==nil) then initHeartTable(pl) end
    if(not hData.INITIALIZED) then
        for i, d in ipairs(hearts) do
            hData[i] = initHeartData(pl, pos, i)
        end
        hData.INITIALIZED = true
    end

    for i, d in ipairs(hData) do
        d.POS = d.POS+d.VEL
        
        local clampPos = Vector(math.max(math.min(Isaac.GetScreenWidth(), d.POS.X), 0), math.max(math.min(Isaac.GetScreenHeight(), d.POS.Y), 0))
        for _, axis in ipairs({"X", "Y"}) do
            if(math.abs(d.POS[axis]-clampPos[axis])>0.001) then
                d.POS[axis] = clampPos[axis]
                if(math.abs(d.VEL[axis])>2.2) then
                    d.PLAYSFX = true
                end
                d.VEL[axis] = -d.VEL[axis]*d.WALLFRICTION

                if(axis=="Y") then d.GRAVITYFRAMES=1 end
            end
        end

        d.VEL.Y = d.VEL.Y+d.GRAVITY*d.GRAVITYFRAMES
        d.VEL = d.VEL*d.FRICTION

        d.GRAVITYFRAMES = d.GRAVITYFRAMES+(d.VEL.Y>=0 and 0.1 or 0.2)--/(math.max(1,d.GRAVITYFRAMES)*10)
    end

    for i, d in ipairs(hearts) do
        if(d:IsVisible()) then
            heartSprite:Play(d:GetHeartAnim(), true)
            heartSprite:PlayOverlay(d:GetHeartOverlayAnim(), true)
            if(d:GetHeartOverlayAnim()=="") then heartSprite:RemoveOverlay() end

            heartSprite:Render(hData[i].POS)
            if(d:IsGoldenHeartOverlayVisible()) then
                heartSprite:Play("GoldHeartOverlay", true)
                heartSprite:Render(hData[i].POS)
            end

            if(hData[i].PLAYSFX) then
                sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS, 0.2)
                hData[i].PLAYSFX = false
            end
        end
    end

    return true
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_HEARTS, math.huge, preRenderHearts)