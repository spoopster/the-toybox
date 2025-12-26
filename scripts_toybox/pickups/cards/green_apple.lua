local sfx = SFXManager()

local NUM_TRANSFORMATION_ADDS = 3
local DELAY_BETWEEN_ADDS = 45
local DELAY_BETWEEN_FIRST_ADD = 60

local ICON_SPRITE = Sprite("gfx_tb/ui/ui_green_apple_icons.anm2", true)
ICON_SPRITE:Play("Idle")

local TRANSF_DATA = {
    [1] =   {PlayerForm.PLAYERFORM_GUPPY, ToyboxMod.SOUND_EFFECT.MEOW},
    [2] =   {PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES, SoundEffect.SOUND_BOSS_BUG_HISS},
    [3] =   {PlayerForm.PLAYERFORM_MUSHROOM, SoundEffect.SOUND_1UP},
    [4] =   {PlayerForm.PLAYERFORM_ANGEL, SoundEffect.SOUND_HOLY},
    [5] =   {PlayerForm.PLAYERFORM_BOB, SoundEffect.SOUND_ZOMBIE_WALKER_KID},
    [6] =   {PlayerForm.PLAYERFORM_DRUGS, SoundEffect.SOUND_DERP},
    [7] =   {PlayerForm.PLAYERFORM_MOM, SoundEffect.SOUND_MOM_VOX_HURT},
    [8] =   {PlayerForm.PLAYERFORM_BABY, SoundEffect.SOUND_CHILD_ANGRY_ROAR},
    [9] =   {PlayerForm.PLAYERFORM_EVIL_ANGEL, SoundEffect.SOUND_BLACK_POOF},
    [10] =  {PlayerForm.PLAYERFORM_POOP, SoundEffect.SOUND_FART},
    [11] =  {PlayerForm.PLAYERFORM_BOOK_WORM, SoundEffect.SOUND_BOOK_PAGE_TURN_12},
    [12] =  {PlayerForm.PLAYERFORM_ADULTHOOD, SoundEffect.SOUND_BUMBINO_PUNCH},
    [13] =  {PlayerForm.PLAYERFORM_SPIDERBABY, SoundEffect.SOUND_SPIDER_COUGH},
    [14] =  {PlayerForm.PLAYERFORM_STOMPY, SoundEffect.SOUND_ROCK_CRUMBLE},
}

local TRANSF_PICKER = WeightedOutcomePicker()
TRANSF_PICKER:AddOutcomeWeight(1, 1)
TRANSF_PICKER:AddOutcomeWeight(2, 1)
TRANSF_PICKER:AddOutcomeWeight(3, 1)
TRANSF_PICKER:AddOutcomeWeight(4, 1)
TRANSF_PICKER:AddOutcomeWeight(5, 1)
TRANSF_PICKER:AddOutcomeWeight(6, 1)
TRANSF_PICKER:AddOutcomeWeight(7, 1)
TRANSF_PICKER:AddOutcomeWeight(8, 1)
TRANSF_PICKER:AddOutcomeWeight(9, 1)
TRANSF_PICKER:AddOutcomeWeight(10, 1)
TRANSF_PICKER:AddOutcomeWeight(11, 1)
TRANSF_PICKER:AddOutcomeWeight(12, 1)
TRANSF_PICKER:AddOutcomeWeight(13, 1)
TRANSF_PICKER:AddOutcomeWeight(14, 1)

---@param pl EntityPlayer
local function getRandomTransformation(pl, counterextras)
    local anyTransformationAvailable = false
    local invalidTransformations = {[0]=true}
    for _, outcome in pairs(TRANSF_PICKER:GetOutcomes()) do
        if((pl:GetPlayerFormCounter(TRANSF_DATA[outcome.Value][1])+(counterextras[TRANSF_DATA[outcome.Value][1]] or 0))>=3) then
            invalidTransformations[outcome.Value] = true
        else
            anyTransformationAvailable = true
        end
    end

    if(anyTransformationAvailable) then
        local rng = pl:GetCardRNG(ToyboxMod.CARD_GREEN_APPLE)
        local outcome = 0
        while(invalidTransformations[outcome]) do
            outcome = TRANSF_PICKER:PickOutcome(rng)
        end
        return outcome
    end

    return 0
end

---@param pl EntityPlayer
local function useFoilCard(_, _, pl, _)
    local data = ToyboxMod:getExtraDataTable()

    data.GREEN_APPLE_TRANSFORMATION_TABLE = data.GREEN_APPLE_TRANSFORMATION_TABLE or {}

    local count = {}
    for _, idata in ipairs(data.GREEN_APPLE_TRANSFORMATION_TABLE) do
        for i, id in ipairs(idata) do
            if(i>(idata.LastIndex or 0) and TRANSF_DATA[id]) then
                count[TRANSF_DATA[id][1]] = (count[TRANSF_DATA[id][1]] or 0)+1
            end
        end
    end

    local toadd = {Time=DELAY_BETWEEN_ADDS*NUM_TRANSFORMATION_ADDS+DELAY_BETWEEN_FIRST_ADD, Player=pl, LastIndex=0}
    for i=1, NUM_TRANSFORMATION_ADDS do
        local outcome = getRandomTransformation(pl, count)
        toadd[i] = outcome
        if(TRANSF_DATA[outcome]) then
            count[TRANSF_DATA[outcome][1]] = (count[TRANSF_DATA[outcome][1]] or 0)+1
        end
    end
    table.insert(data.GREEN_APPLE_TRANSFORMATION_TABLE, toadd)

    data.GREEN_APPLE_CANCEL = false
    local numentries = #data.GREEN_APPLE_TRANSFORMATION_TABLE
    Game():GetHUD():ShowFortuneText((numentries>0 and ""),(numentries>1 and ""),(numentries>2 and ""))
    data.GREEN_APPLE_CANCEL = true
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useFoilCard, ToyboxMod.CARD_GREEN_APPLE)

local function cancelOtherFortunes(_)
    if(ToyboxMod:getExtraData("GREEN_APPLE_CANCEL")) then
        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_FORTUNE_DISPLAY, cancelOtherFortunes)

local font = Font("font/upheaval.fnt")

local function updateGreenAppleFortune(_)
    local data = ToyboxMod:getExtraDataTable()
    if(not (data.GREEN_APPLE_TRANSFORMATION_TABLE and #data.GREEN_APPLE_TRANSFORMATION_TABLE>0)) then return end

    local hud = Game():GetHUD()
    local fortunesp = hud:GetFortuneSprite()

    if(fortunesp:IsFinished()) then
        data.GREEN_APPLE_TRANSFORMATION_TABLE = nil
        data.GREEN_APPLE_CANCEL = false
        return
    end
    
    local centerPos = Vector(0,10)

    local framedata = fortunesp:GetLayerFrameData(0)
    local nullframedata = fortunesp:GetNullFrame("Center")
    if(nullframedata) then
        centerPos = centerPos+nullframedata:GetPos()
    end

    local basepos = Vector(Isaac.GetScreenWidth()/2, 48)+framedata:GetPos()
    local lineheight = 21
    local columnwidth = 90
    local percolumn = 3
    local icondistance = 24

    local num = #data.GREEN_APPLE_TRANSFORMATION_TABLE

    local numcolumns = math.min(3, math.ceil(num/percolumn))

    local columnpos = basepos-Vector(columnwidth,0)*(numcolumns-1)/2

    local needsToResetTime = false
    for i=1, num do
        local tb = data.GREEN_APPLE_TRANSFORMATION_TABLE[i]

        if(not Game():IsPaused()) then
            tb.Time = math.max(0, (tb.Time or 0)-1)
            if(tb.Time%DELAY_BETWEEN_ADDS==DELAY_BETWEEN_ADDS-1 and tb.Time<=DELAY_BETWEEN_ADDS*NUM_TRANSFORMATION_ADDS) then
                tb.LastIndex = (tb.LastIndex or 0)+1
                local indexJustGot = tb.LastIndex
                if(indexJustGot>0) then
                    local iddata = TRANSF_DATA[tb[indexJustGot]]
                    if(iddata) then
                        local pl = (tb.Player or Isaac.GetPlayer())
                        Isaac.CreateTimer(function()
                            if(pl) then
                                pl:IncrementPlayerFormCounter(iddata[1], 1)
                            end
                        end, 1,1,true)

                        sfx:Play(iddata[2])
                    else
                        sfx:Play(SoundEffect.SOUND_PLOP)
                    end
                end
            end
        end
        
        if(tb.Time~=0) then
            needsToResetTime = true
        end
    end

    if(needsToResetTime and fortunesp:GetFrame()>15) then
        fortunesp:SetFrame(15)
    end

    for c=1, numcolumns do
        for l=1, NUM_TRANSFORMATION_ADDS do
            local offset = Vector(0, lineheight*(l-1))
            local linepos = columnpos+(offset+centerPos)*framedata:GetScale()-centerPos

            local iconpos = linepos-Vector(icondistance,-8)
            local tableidx = l+(c-1)*percolumn
            local tb = data.GREEN_APPLE_TRANSFORMATION_TABLE[tableidx]
            if(tb) then
                for i=1, tb.LastIndex or 0 do
                    local finalpos = iconpos+Vector(icondistance*(i-1),0)
                    ICON_SPRITE:SetFrame(tb[i])
                    ICON_SPRITE:Render(finalpos)
                end
            end

            --font:DrawString("[] [] []", linepos.X-boxsize, linepos.Y,  KColor(1,1,1,1), boxsize*2, true)
        end

        columnpos = columnpos+Vector(columnwidth,0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, updateGreenAppleFortune)

local function addProgressOnLeave(_)
    local data = ToyboxMod:getExtraDataTable()
    data.GREEN_APPLE_TRANSFORMATION_TABLE = data.GREEN_APPLE_TRANSFORMATION_TABLE or {}

    for _, idata in ipairs(data.GREEN_APPLE_TRANSFORMATION_TABLE) do
        for i, id in ipairs(idata) do
            if(i>(idata.LastIndex or 0) and TRANSF_DATA[id]) then
                (idata.Player or Isaac.GetPlayer()):IncrementPlayerFormCounter(TRANSF_DATA[id][1], 1)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, addProgressOnLeave)