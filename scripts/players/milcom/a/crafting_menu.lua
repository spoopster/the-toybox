local mod = MilcomMOD
local sfx = SFXManager()
local f = Font()

local SFXMENU_CANTCHANGEPOS = SoundEffect.SOUND_STATIC
local SFXMENU_CHANGEPOS = SoundEffect.SOUND_PLOP
local SFXMENU_ITEMCRAFTED = SoundEffect.SOUND_CASH_REGISTER
local SFXMENU_CANTCRAFTITEM = SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ
sfx:Preload(SFXMENU_CANTCHANGEPOS)
sfx:Preload(SFXMENU_CHANGEPOS)
sfx:Preload(SFXMENU_ITEMCRAFTED)
sfx:Preload(SFXMENU_CANTCRAFTITEM)

f:Load("font/pftempestasevencondensed.fnt")

local MAP_TIMER = 0
local IS_MENU_ACTIVE = false
local RENDERING_CRAFTMENU = false

local function mapFramesLogic(_)
    if(not mod:isAnyPlayerMilcomA()) then return end

    --RENDERING_CRAFTMENU = false

    --if(mod:isMapButtonHeld()) then MAP_TIMER = MAP_TIMER+1
    --elseif(MAP_TIMER>0) then MAP_TIMER = MAP_TIMER-1 end

    --MAP_TIMER = mod:clamp(MAP_TIMER, 18, 0)

    --if(not mod:isMapButtonHeld() and IS_MENU_ACTIVE==true) then IS_MENU_ACTIVE=false
    --elseif(mod:isMapButtonHeld() and IS_MENU_ACTIVE==false) then IS_MENU_ACTIVE=true end

    --if(IS_MENU_ACTIVE and MAP_TIMER<18) then MAP_TIMER=MAP_TIMER+1
    --elseif(not IS_MENU_ACTIVE and MAP_TIMER>0) then MAP_TIMER=MAP_TIMER-1 end
end
--mod:AddCallback(ModCallbacks.MC_POST_RENDER, mapFramesLogic)

---@param player EntityPlayer
local function postPlayerRender(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    local data = mod:getMilcomATable(player)

    local inputs = {"LEFT", "RIGHT", "UP", "DOWN"}

    for _, input in ipairs(inputs) do
        if(Input.IsActionPressed(ButtonAction["ACTION_SHOOT"..input], player.ControllerIndex)) then data["SHIFT_INPUTFRAMES_"..input]=data["SHIFT_INPUTFRAMES_"..input]+0.5
        else data["SHIFT_INPUTFRAMES_"..input] = 0 end
    end

    if(Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex)) then data.MENU_OPEN_FRAMES = data.MENU_OPEN_FRAMES+1
    else data.MENU_OPEN_FRAMES=0 end


    if(data.MENU_OPEN_FRAMES>0) then data.SHOULD_RENDER_MENU=true
    else data.SHOULD_RENDER_MENU=false end

    local toAdd = -1
    if(data.SHOULD_RENDER_MENU==true) then toAdd = 1 end
    data.RENDER_FRAMES = mod:clamp(data.RENDER_FRAMES+toAdd, 18, 0)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postPlayerRender)

local heldCraftableSprite = Sprite()
heldCraftableSprite:Load("gfx/ui/milcom_a/crafting/milcom_a_craftables_heldup.anm2", true)
heldCraftableSprite:Play("Main", true)

local menuSprite = Sprite()
menuSprite:Load("gfx/ui/milcom_a/crafting/milcom_a_crafting.anm2", true)

local menuBackgroundSprite = Sprite()
menuBackgroundSprite:Load("gfx/ui/milcom_a/crafting/milcom_a_crafting.anm2", true)
menuBackgroundSprite:Play("Background", true)

local menuCraftableSprite = Sprite()
menuCraftableSprite:Load("gfx/ui/milcom_a/crafting/milcom_a_crafting.anm2", true)
menuCraftableSprite:Play("Craftable", true)

local menuTierSprite = Sprite()
menuTierSprite:Load("gfx/ui/milcom_a/crafting/milcom_a_crafting.anm2", true)
menuTierSprite:Play("Tier", true)

local menuMaxCrossSprite = Sprite()
menuMaxCrossSprite:Load("gfx/ui/milcom_a/crafting/milcom_a_crafting.anm2", true)
menuMaxCrossSprite:Play("MaxedCross", true)

local menuSelectionSprite = Sprite()
menuSelectionSprite:Load("gfx/ui/milcom_a/crafting/milcom_a_crafting.anm2", true)
menuSelectionSprite:Play("Selection", true)

--[[
layers:
    - 0 = the item (frames are diff items)
    - 1 = the border (frames are the level/tier)
    - 2 = bg
    - 3 = left arrow (frame 0 is idle, frame 1 is pressing arrow)
    - 4 = right arrow (ditto)
    - 5 = up arrow (ditto)
    - 6 = down arrow (ditto)
]]

local priceHudSprite = Sprite()
priceHudSprite:Load("gfx/ui/milcom_a/pickups/milcom_a_hudpickups.anm2", true)

local CRAFTING_SPACES_DATA = {
    [0] = {Scale=Vector(1,1), Color=Color(1,1,1,1), YPos=0},
    [1] = {Scale=Vector(1,1)*0.975, Color=Color(0.95,0.95,0.95,1), YPos=0},
    [2] = {Scale=Vector(1,1)*0.95, Color=Color(0.9,0.9,0.9,1), YPos=0},
    [3] = {Scale=Vector(1,1)*0.9, Color=Color(0.8,0.8,0.8,1), YPos=0},
    [4] = {Scale=Vector(1,1)*0.85, Color=Color(0.8,0.8,0.8,1), YPos=0},
    [5] = {Scale=Vector(1,1)*0.775, Color=Color(0.7,0.7,0.7,0.5), YPos=0},
    [6] = {Scale=Vector(1,1)*0.7, Color=Color(0.5,0.5,0.5,0), YPos=0},
    [7] = {Scale=Vector(1,1)*0.6, Color=Color(0,0,0,0), YPos=0},
}
local INVENTORY_SPACES_DATA = {
    [-1] = {Scale=Vector(1,1)*0.9, Color=Color(0.95,0.95,0.95,0.75), YPos=0},
    [-2] = {Scale=Vector(1,1)*0.75, Color=Color(0.8,0.8,0.8,0.5), YPos=0},
    [-3] = {Scale=Vector(1,1)*0.6, Color=Color(0.3,0.3,0.3,0), YPos=0},
    [-4] = {Scale=Vector(1,1)*0.5, Color=Color(0,0,0,0), YPos=0},
    [-5] = {Scale=Vector(1,1)*0.5, Color=Color(0,0,0,0), YPos=0},
    [-6] = {Scale=Vector(1,1)*0.4, Color=Color(0,0,0,0), YPos=0},
    [-7] = {Scale=Vector(1,1)*0.4, Color=Color(0,0,0,0), YPos=0},
    [0] = {Scale=Vector(1,1), Color=Color(1,1,1,1), YPos=0},
    [1] = {Scale=Vector(1,1)*0.975, Color=Color(0.95,0.95,0.95,1), YPos=0},
    [2] = {Scale=Vector(1,1)*0.95, Color=Color(0.9,0.9,0.9,1), YPos=0},
    [3] = {Scale=Vector(1,1)*0.9, Color=Color(0.8,0.8,0.8,1), YPos=0},
    [4] = {Scale=Vector(1,1)*0.85, Color=Color(0.8,0.8,0.8,1), YPos=0},
    [5] = {Scale=Vector(1,1)*0.775, Color=Color(0.7,0.7,0.7,0.5), YPos=0},
    [6] = {Scale=Vector(1,1)*0.7, Color=Color(0.5,0.5,0.5,0), YPos=0},
    [7] = {Scale=Vector(1,1)*0.6, Color=Color(0,0,0,0), YPos=0},
}

local CRAFT_GRID_DATA = {
    [0] = {ALPHA=1},
    [1] = {ALPHA=1},
    [2] = {ALPHA=1},
    [3] = {ALPHA=1},
    [4] = {ALPHA=0},
    [5] = {ALPHA=0},
}
local INV_GRID_DATA = {
    [-2]= {ALPHA=0},
    [-1]= {ALPHA=0},
    [0] = {ALPHA=1},
    [1] = {ALPHA=1},
    [2] = {ALPHA=1},
    [3] = {ALPHA=1},
    [4] = {ALPHA=1},
    [5] = {ALPHA=0},
    [6] = {ALPHA=0},
}

local VALID_CRAFTABLE_IDS = {}
local function updateValidCraftables(player)
    VALID_CRAFTABLE_IDS = {}
    for i, d in ipairs(mod.CRAFTABLES_A) do
        local isValid = true
        if(isValid and (mod:hasNextLevel(d.NAME) and mod:playerHasCraftable(player, d.NAME))) then isValid=false end
        if(isValid and (d.PREV_CRAFTABLE and not mod:playerHasCraftable(player, d.PREV_CRAFTABLE))) then isValid=false end
        if(isValid and (d.APPEAR_CONDITION and not d.APPEAR_CONDITION(player))) then isValid = false end

        if(isValid) then VALID_CRAFTABLE_IDS[#VALID_CRAFTABLE_IDS+1] = i end
    end
end

local function renderCraftingMenuNOCOOP(_)
    --if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    if(mod:getNumberOfTruePlayers()>1) then return end
    local player = Isaac.GetPlayer()
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    local data = mod:getMilcomATable(player)
    if(data.RENDER_FRAMES==0) then return end

    updateValidCraftables(player)

    local renderPos = Vector(mod:getScreenCenter().X, mod:getScreenBottomRight().Y-90)

    local a = data.RENDER_FRAMES/18
    priceHudSprite.Color = Color(1,1,1,a)
    menuSprite.Color = Color(1,1,1,a)
    menuSprite.Scale = Vector(1,1)

    --ACTUALLY CHANGING THE SELECTED STUFF

    if(data.SHIFTING_FRAMES_CRAFT) then
        data.SHIFTING_FRAMES_CRAFT = data.SHIFTING_FRAMES_CRAFT + 1
        if(data.SHIFTING_FRAMES_CRAFT > data.SHIFTING_LENGTH_CRAFT) then
            data.SHIFTING_LENGTH_CRAFT = nil
            data.SHIFTING_FRAMES_CRAFT = nil
            data.SHIFTING_DIRECTION_CRAFT = nil
        end
    end
    if(data.SHIFTING_FRAMES_INV) then
        data.SHIFTING_FRAMES_INV = data.SHIFTING_FRAMES_INV + 1
        if(data.SHIFTING_FRAMES_INV > data.SHIFTING_LENGTH_INV) then
            data.SHIFTING_LENGTH_INV = nil
            data.SHIFTING_FRAMES_INV = nil
            data.SHIFTING_DIRECTION_INV = nil
        end
    end

    --CRAFTING MENU
    local DISPLAYED_ITEMS = {}
    local DISPLAY_NUM = (#CRAFTING_SPACES_DATA-1)*2

    --[[ NORMAL RENDER
    for i = -DISPLAY_NUM/2, DISPLAY_NUM/2, 1 do
        local indexOffset=0; local shiftPercent
        if(data.SHIFTING_FRAMES_CRAFT) then
            shiftPercent = data.SHIFTING_FRAMES_CRAFT / data.SHIFTING_LENGTH_CRAFT
            indexOffset = ((1 - shiftPercent) * data.SHIFTING_DIRECTION_CRAFT)
        end
        local percent = ((#DISPLAYED_ITEMS+indexOffset))/DISPLAY_NUM

        local xPos = math.sin(math.rad(180*(percent-0.5)))*140

        local color = CRAFTING_SPACES_DATA[math.abs(i)].Color
        local scale = CRAFTING_SPACES_DATA[math.abs(i)].Scale
        local yPos = CRAFTING_SPACES_DATA[math.abs(i)].YPos

        if(shiftPercent) then
            color = Color.Lerp(CRAFTING_SPACES_DATA[math.abs(i+data.SHIFTING_DIRECTION_CRAFT)].Color, color, shiftPercent)
            scale = mod:lerp(CRAFTING_SPACES_DATA[math.abs(i+data.SHIFTING_DIRECTION_CRAFT)].Scale, scale, shiftPercent)
            yPos = mod:lerp(CRAFTING_SPACES_DATA[math.abs(i+data.SHIFTING_DIRECTION_CRAFT)].YPos, yPos, shiftPercent)
        end

        local c = Color(color.R,color.G,color.B,color.A*a,color.RO,color.GO,color.BO)
        color = c

        DISPLAYED_ITEMS[#DISPLAYED_ITEMS+1] = {
            Item = mod:getCraftableFromCategory(player, mod:getValidCraftingIndex(data.SELECTED_CRAFT_INDEX+i)),
            Color = color,
            Scale = scale,
            Position = Vector(xPos,yPos),
            IsSelected = (data.SELECTED_MENU==1 and i==0),
        }
    end
    --]]

    -- [[ "GRID" RENDER
    local MINMAX = {-3,3}
    for i = MINMAX[1]-1, MINMAX[2]+1 do
        local indexOffset=0; local shiftPercent
        if(data.SHIFTING_FRAMES_CRAFT) then
            shiftPercent = data.SHIFTING_FRAMES_CRAFT / data.SHIFTING_LENGTH_CRAFT
            indexOffset = ((1 - shiftPercent) * data.SHIFTING_DIRECTION_CRAFT)
        end

        local aMult = CRAFT_GRID_DATA[math.abs(i)].ALPHA
        if(shiftPercent) then
            aMult = mod:lerp(CRAFT_GRID_DATA[math.abs(i+data.SHIFTING_DIRECTION_CRAFT)].ALPHA, aMult, shiftPercent)
        end
        aMult = aMult^4

        local xPos = (i+indexOffset)*40

        local vIdx = VALID_CRAFTABLE_IDS[((data.SELECTED_CRAFT_INDEX+i)-1)%(#VALID_CRAFTABLE_IDS)+1]
        local name = mod.CRAFTABLES_A[vIdx].NAME
        DISPLAYED_ITEMS[#DISPLAYED_ITEMS+1] = {
            Item = {
                ID = vIdx,
                NAME = name,
                LEVEL = mod.CRAFTABLES_A[vIdx].LEVEL,
                IS_PURCHASEABLE = (mod:playerHasCraftable(player, name) and not mod:hasNextLevel(name)),
            },
            Color = Color(1,1,1,aMult*a),
            Scale = Vector(1,1),
            Position = Vector(xPos,0),
            IsSelected = (data.SELECTED_MENU==1 and i==0),
        }
    end
    --]]

    --INVENTORY MENU
    local DISPLAYED_INVITEMS = {}
    local DISPLAY_INVNUM = (#INVENTORY_SPACES_DATA-1)*2

    --[[ NORMAL RENDER
    for i = -6, 6, 1 do
        local indexOffset=0; local shiftPercent
        if(data.SHIFTING_FRAMES_INV) then
            shiftPercent = data.SHIFTING_FRAMES_INV / data.SHIFTING_LENGTH_INV
            indexOffset = ((1 - shiftPercent) * data.SHIFTING_DIRECTION_INV)
        end
        local percent = ((#DISPLAYED_INVITEMS+indexOffset))/DISPLAY_INVNUM

        local xPos = math.sin(math.rad(180*(percent-0.5)))*140

        local color = INVENTORY_SPACES_DATA[i].Color
        local scale = INVENTORY_SPACES_DATA[i].Scale
        local yPos = INVENTORY_SPACES_DATA[i].YPos        

        if(shiftPercent) then
            color = Color.Lerp(INVENTORY_SPACES_DATA[i+data.SHIFTING_DIRECTION_INV].Color, color, shiftPercent)
            scale = mod:lerp(INVENTORY_SPACES_DATA[i+data.SHIFTING_DIRECTION_INV].Scale, scale, shiftPercent)
            yPos = mod:lerp(INVENTORY_SPACES_DATA[i+data.SHIFTING_DIRECTION_INV].YPos, yPos, shiftPercent)
        end

        local c = Color(color.R,color.G,color.B,color.A*a,color.RO,color.GO,color.BO)
        color = c

        if(xPos<0) then
            xPos = -(math.abs(xPos)^(2/3))
        end

        if(data.OWNED_CRAFTABLES[data.SELECTED_INV_INDEX+i]) then
            DISPLAYED_INVITEMS[#DISPLAYED_INVITEMS+1] = {
                Item = {
                    NAME=data.OWNED_CRAFTABLES[data.SELECTED_INV_INDEX+i],
                    LEVEL=mod.CRAFTABLES_A[ data.OWNED_CRAFTABLES[data.SELECTED_INV_INDEX+i] ].LEVEL or 1,
                },
                Color = color,
                Scale = scale,
                Position = Vector(xPos,yPos),
                IsSelected = (data.SELECTED_MENU==2 and i==0),
            }
        else
            DISPLAYED_INVITEMS[#DISPLAYED_INVITEMS+1] = {
                Position = Vector(0,0),
                Exists = false,
            }
        end
    end
    --]]

    -- [[ "GRID" RENDER
    local MINMAX_I = {0,4}
    for i = MINMAX_I[1]-1, MINMAX_I[2]+1, 1 do
        local indexOffset=0; local shiftPercent
        if(data.SHIFTING_FRAMES_INV) then
            shiftPercent = data.SHIFTING_FRAMES_INV / data.SHIFTING_LENGTH_INV
            indexOffset = ((1 - shiftPercent) * data.SHIFTING_DIRECTION_INV)
        end

        local aMult = INV_GRID_DATA[i].ALPHA
        if(shiftPercent) then
            aMult = mod:lerp(INV_GRID_DATA[i+data.SHIFTING_DIRECTION_INV].ALPHA, aMult, shiftPercent)
        end
        aMult = aMult^4

        local xPos = (i+indexOffset)*40

        if(data.OWNED_CRAFTABLES[data.SELECTED_INV_INDEX+i]) then
            local name = data.OWNED_CRAFTABLES[data.SELECTED_INV_INDEX+i]
            local id = mod:getCraftableIdByName(name)
            DISPLAYED_INVITEMS[#DISPLAYED_INVITEMS+1] = {
                Item = {
                    ID = id,
                    NAME = name,
                    LEVEL = mod.CRAFTABLES_A[id].LEVEL or 1,
                },
                Color = Color(1,1,1,aMult*a),
                Scale = Vector(1,1),
                Position = Vector(xPos,0),
                IsSelected = (data.SELECTED_MENU==2 and i==0),
            }
        else
            DISPLAYED_INVITEMS[#DISPLAYED_INVITEMS+1] = {
                Position = Vector(0,0),
                Exists = false,
            }
        end
    end
    --]]


    --LOGIC FOR INPUTS
    if(not Game():IsPaused()) then
        local change = 0
        if((data.SELECTED_MENU==1 and data.SHIFTING_FRAMES_CRAFT==nil) or (data.SELECTED_MENU==2 and data.SHIFTING_FRAMES_INV==nil)) then
            local input = 0
            local changeToSet = 0
            if(data.SHIFT_INPUTFRAMES_RIGHT>0) then
                input = data.SHIFT_INPUTFRAMES_RIGHT
                changeToSet = 1
            elseif(data.SHIFT_INPUTFRAMES_LEFT>0) then
                input = data.SHIFT_INPUTFRAMES_LEFT
                changeToSet = -1
            end

            local length = data.SHIFTING_DURATION
            if(input>=data.SHIFTING_DURATION*data.SHIFTING_FAST_REQ+1) then length = data.SHIFTING_DURATIONFAST end

            if(input==1 or (input%(length+1)==0)) then
                change = changeToSet

                if(data.SELECTED_MENU==1) then data.SHIFTING_LENGTH_CRAFT = length
                elseif(data.SELECTED_MENU==2) then data.SHIFTING_LENGTH_INV = length end
            end
        end

        if(change~=0) then
            if(data.SELECTED_MENU==1) then
                data.SHIFTING_FRAMES_CRAFT = 0
                data.SHIFTING_DIRECTION_CRAFT = change
                data.SELECTED_CRAFT_INDEX = ((data.SELECTED_CRAFT_INDEX+change)-1)%#VALID_CRAFTABLE_IDS+1

                sfx:Play(SFXMENU_CHANGEPOS, 0.8)
            elseif(data.SELECTED_MENU==2) then
                if(not ((data.SELECTED_INV_INDEX==1 and change==-1) or (data.SELECTED_INV_INDEX==#data.OWNED_CRAFTABLES and change==1))) then
                    data.SHIFTING_FRAMES_INV = 0
                    data.SHIFTING_DIRECTION_INV = change
                    data.SELECTED_INV_INDEX = mod:getValidInventoryIndex(data.SELECTED_INV_INDEX+change, #data.OWNED_CRAFTABLES)

                    sfx:Play(SFXMENU_CHANGEPOS, 0.8)
                else
                    sfx:Play(SFXMENU_CANTCHANGEPOS, 0.8)
                end
            end
        end

        if(not (data.SHIFT_INPUTFRAMES_DOWN==0 and data.SHIFT_INPUTFRAMES_UP==0)) then
            local menuChange = 0
            if(data.SHIFT_INPUTFRAMES_UP==1) then
                menuChange = 1
            elseif(data.SHIFT_INPUTFRAMES_DOWN==1) then
                menuChange = -1
            end

            local menuData = mod:changeMenuLogic(data.SELECTED_MENU, menuChange, #data.OWNED_CRAFTABLES)
            data.SELECTED_MENU = menuData.NEWLEVEL

            if(menuData.PLAYSFX==1) then sfx:Play(SFXMENU_CHANGEPOS, 0.8)
            elseif(menuData.PLAYSFX==0) then sfx:Play(SFXMENU_CANTCHANGEPOS, 0.8) end
        end
    end

    --RENDERING EVERYTHING
    local menuColor = Color(1,1,1,a)
    local selectedItem = nil

    --BACKGROUND+ARROWS
    menuBackgroundSprite.Color = menuColor
    menuBackgroundSprite:SetLayerFrame(6, 0)
    menuBackgroundSprite:SetLayerFrame(5, 0)
    menuBackgroundSprite:SetLayerFrame(4, 0)
    menuBackgroundSprite:SetLayerFrame(3, 0)
    if(data.SHIFT_INPUTFRAMES_RIGHT>0) then
        menuBackgroundSprite:SetLayerFrame(4, 1)
    elseif(data.SHIFT_INPUTFRAMES_LEFT>0) then
        menuBackgroundSprite:SetLayerFrame(3, 1)
    end
    if(data.SHIFT_INPUTFRAMES_UP>0) then
        menuBackgroundSprite:SetLayerFrame(5, 1)
    elseif(data.SHIFT_INPUTFRAMES_DOWN>0) then
        menuBackgroundSprite:SetLayerFrame(6, 1)
    end
    menuBackgroundSprite:Render(renderPos)

    --[[
    local function sortFunction(x,y) return math.abs(x.Position.X)>math.abs(y.Position.X) end

    table.sort(DISPLAYED_ITEMS, sortFunction)
    table.sort(DISPLAYED_INVITEMS, sortFunction)
    --]]

    --CRAFTABLES
    for _, iData in ipairs(DISPLAYED_ITEMS) do
        local itemPos = renderPos+iData.Position
        
        menuTierSprite.Color = iData.Color
        menuTierSprite.Scale = iData.Scale
        menuTierSprite:SetFrame(iData.Item.LEVEL)
        menuTierSprite:Render(itemPos)

        menuCraftableSprite.Color = iData.Color
        menuCraftableSprite.Scale = iData.Scale
        menuCraftableSprite:SetFrame(mod.CRAFTABLES_A[iData.Item.ID].FRAME)
        menuCraftableSprite:Render(itemPos)

        if(iData.Item.IS_PURCHASEABLE==true) then
            menuMaxCrossSprite.Color = iData.Color
            menuMaxCrossSprite.Scale = iData.Scale
            menuMaxCrossSprite:Render(itemPos)
        end
        if(iData.IsSelected) then selectedItem = iData.Item end
    end
    for _, iData in ipairs(DISPLAYED_INVITEMS) do
        if(iData.Exists~=false) then
            local itemPos = renderPos+iData.Position+data.INV_CRAFTABLE_OFFSET
            
            menuTierSprite.Color = iData.Color
            menuTierSprite.Scale = iData.Scale
            menuTierSprite:SetFrame(iData.Item.LEVEL)
            menuTierSprite:Render(itemPos)

            menuCraftableSprite.Color = iData.Color
            menuCraftableSprite.Scale = iData.Scale
            menuCraftableSprite:SetFrame(mod.CRAFTABLES_A[iData.Item.ID].FRAME)
            menuCraftableSprite:Render(itemPos)

            if(iData.IsSelected) then selectedItem = iData.Item end
        end
    end

    -- SELECTION
    menuSelectionSprite.Color = menuColor
    if(data.SELECTED_MENU==1) then
        menuSelectionSprite:Render(renderPos)
    elseif(data.SELECTED_MENU==2) then
        menuSelectionSprite:Render(renderPos+data.INV_CRAFTABLE_OFFSET)
    end

    if(selectedItem) then
        local enumData = mod.CRAFTABLES_A[selectedItem.ID]

        local PRICE_PICKUPS = {enumData.COST.CARDBOARD,enumData.COST.TAPE,enumData.COST.NAILS}
        local OWNED_PICKUPS = {mod.MILCOM_A_PICKUPS.CARDBOARD,mod.MILCOM_A_PICKUPS.DUCT_TAPE,mod.MILCOM_A_PICKUPS.NAILS}
        local CAN_AFFORD = {PRICE_PICKUPS[1]<=OWNED_PICKUPS[1],PRICE_PICKUPS[2]<=OWNED_PICKUPS[2],PRICE_PICKUPS[3]<=OWNED_PICKUPS[3]}

        local textColor = KColor(1,1,1,a)
        local evilTextColor = KColor(1,0.25,0.25,a)

        if(data.SELECTED_MENU==1 and (not selectedItem.IS_PURCHASEABLE)) then
            if(Input.IsActionTriggered(ButtonAction.ACTION_PILLCARD, player.ControllerIndex)) then
                if(CAN_AFFORD[1] and CAN_AFFORD[2] and CAN_AFFORD[3]) then
                    mod:addCraftable(player, selectedItem.NAME)
                    Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_MILCOM_CRAFT_CRAFTABLE, selectedItem.NAME, player, enumData)

                    mod:addCardboard(-enumData.COST.CARDBOARD)
                    mod:addDuctTape(-enumData.COST.TAPE)
                    mod:addNails(-enumData.COST.NAILS)

                    sfx:Play(SFXMENU_ITEMCRAFTED, 1.25)

                    heldCraftableSprite:SetFrame(enumData.FRAME)
                    player:AnimatePickup(heldCraftableSprite, false, "Pickup")
                else
                    sfx:Play(SFXMENU_CANTCRAFTITEM, 1.25)
                end
            end
        end

        local itemPos = renderPos+data.DATA_CRAFTABLE_OFFSET

        menuTierSprite.Color = menuColor
        menuTierSprite:SetFrame(enumData.LEVEL)
        menuTierSprite:Render(itemPos)

        menuCraftableSprite.Color = menuColor
        menuCraftableSprite:SetFrame(enumData.FRAME)
        menuCraftableSprite:Render(itemPos)

        --CRAFTABLE TITLE+DESCRIPTION
        local formattedTitle = mod:separateStringIntoLines(f, enumData.NAME, data.DATA_TITLESIZE.X)
        local titleTotalHeight = 0
        local titleLineHeight = f:GetLineHeight()-2
        for _,_ in ipairs(formattedTitle) do
            titleTotalHeight = titleTotalHeight+titleLineHeight
        end
        titleTotalHeight = titleTotalHeight
        local baseHeight = (data.DATA_TITLESIZE.Y-titleTotalHeight)/2
        for i, titleLine in ipairs(formattedTitle) do
            f:DrawStringScaled(titleLine, itemPos.X+20, itemPos.Y-20+baseHeight+(i-1)*titleLineHeight-3, 1,1, textColor, data.DATA_TITLESIZE.X, true)
        end

        --CRAFTABLE PRICE
        priceHudSprite:Play("Pickups", true)
        --local PRICEORDER = {"CARDBOARD", "TAPE", "NAILS"}
        for i=0,2 do
            local pricePos = Vector(itemPos.X-19+(i/3)*data.DATA_DESCRIPTIONSIZE.X, itemPos.Y+19)
            local price = PRICE_PICKUPS[i+1]--enumData.COST[PRICEORDER[i+1]]

            priceHudSprite:SetFrame(i)
            priceHudSprite:Render(pricePos)


            local col = evilTextColor
            if(CAN_AFFORD[i+1] or data.SELECTED_MENU==2) then col = textColor end
            f:DrawStringScaled(tostring(math.floor((price%100-price%10)/10))..tostring(price%10), pricePos.X+18, pricePos.Y, 1,1, col)
        end

        local formattedDesc = mod:formatMilcomDescription(f, enumData.DESCRIPTION, data.DATA_DESCRIPTIONSIZE.X)
        local descLineHeight = f:GetLineHeight()-2
        for i, descLine in ipairs(formattedDesc) do
            f:DrawStringScaled(descLine, itemPos.X-20, itemPos.Y+38+(i-1)*descLineHeight-3, 1,1, textColor, data.DATA_DESCRIPTIONSIZE.X, true)
        end
    end

    priceHudSprite.Color = Color(1,1,1,a)
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_HUD_RENDER, 1e6, renderCraftingMenuNOCOOP)

local function cancelPillCardMilcom(_, player, hook, action)
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==mod.PLAYER_MILCOM_A)) then return end
    local data = mod:getMilcomATable(player:ToPlayer())
    if(data.SHOULD_RENDER_MENU~=true) then return end
    
    if(action==ButtonAction.ACTION_PILLCARD) then
        if(hook==InputHook.GET_ACTION_VALUE) then return 0 end
        if(hook==InputHook.IS_ACTION_PRESSED) then return false end
        if(hook==InputHook.IS_ACTION_TRIGGERED) then return false end
    end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, cancelPillCardMilcom)