--- todo:
--- add png + name + desc
--- 
--- finish icons

local TRINKET_MENU_ACTIVE = false
local SEL_IDX = 0

local ITEMS_SAVED_IDX = 0
local ITEMS_SAVED_PAGE = 0

local PER_LINE = 20
local LINES_PER_PAGE = 6
local PAGE_OFFSET = PER_LINE*LINES_PER_PAGE

local TIME_HELD_INPUTS = 0
local DELAY_BEFORE_AUTOHOLD = 20
local AUTOHOLD_MOVE_FREQ = 5

local MAX_DIST_BETWEEN_BULLETS = 15
local MAX_BULLET_TOTAL_DIST = 80

local TEXT_FONT = Font()
TEXT_FONT:Load("font/teammeatfont12.fnt")
local TEXT_COLOR = KColor(120/255, 114/255, 97/255, 1)

local TABS_SPRITE = Sprite("gfx_tb/ui/trinket collection/tabs.anm2", true)
TABS_SPRITE:Play("Tabs", true)

local COLLECTION_SPRITE = Sprite("gfx_tb/ui/trinket collection/menu.anm2", true)
COLLECTION_SPRITE:Play("Idle", true)

local ICONS_SPRITE = Sprite("gfx_tb/ui/trinket collection/icon_special.anm2", true)

local ITEM_SPRITE = Sprite("gfx_tb/ui/trinket collection/item.anm2", true)
ITEM_SPRITE:Play("Idle", true)

local NUM_TRINKETS = 0
local IDX_TO_TRINKETID = {}
local FIRST_TRINKET_ID = {}
local MOD_ANM_TABLE = {}

---@param modRef ModReference|String
---@param path string
function ToyboxMod:addModAnm2(modRef, path)
    local cachedSprite = Sprite(path, true)
    cachedSprite:Play(cachedSprite:GetDefaultAnimation(), true)

    if(modRef=="BaseGame") then
        MOD_ANM_TABLE[modRef] = cachedSprite
    else
        local name
        if(type(modRef)=="string") then
            name = modRef
        else
            name = modRef.Name
        end

        MOD_ANM_TABLE[XMLData.GetEntryByName(XMLNode.MOD, name).id] = cachedSprite
    end
end

ToyboxMod:addModAnm2("BaseGame", "gfx_tb/ui/trinket collection/trinkets_base_game.anm2")
ToyboxMod:addModAnm2("Toybox (Playtester Build)", "gfx_tb/ui/trinket collection/trinkets_toybox.anm2")

local function getTrinkets()
    if(NUM_TRINKETS~=0) then return end

    local conf = Isaac.GetItemConfig()

    local num = XMLData.GetNumEntries(XMLNode.TRINKET)
    for i=1, num do
        local node = XMLData.GetEntryByOrder(XMLNode.TRINKET, i)

        local trinketconf = conf:GetTrinket(node.id)
        if(trinketconf and not trinketconf.Hidden) then
            NUM_TRINKETS = NUM_TRINKETS+1
            table.insert(IDX_TO_TRINKETID, node.id)
        end

        if(not FIRST_TRINKET_ID[node.sourceid]) then
            FIRST_TRINKET_ID[node.sourceid] = node.id
        end
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.LATE, getTrinkets)

getTrinkets()

if(EID) then
    local ogFunc = EID.OnMenuRender
    EID:RemoveCallback(ModCallbacks.MC_MAIN_MENU_RENDER, ogFunc)

    function EID:OnMenuRender()
        if(EID.Config["RGON_ShowOnCollectionPage"] and MenuManager:GetActiveMenu()==MainMenuType.COLLECTION and TRINKET_MENU_ACTIVE) then
            local selItem = IDX_TO_TRINKETID[SEL_IDX+1]

            local descObj = EID:getDescriptionObj(5, 350, tonumber(selItem), nil, false)
            EID:printDescription(descObj, nil)
        end

        if(not TRINKET_MENU_ACTIVE) then
            ogFunc(self)
        end
    end
    EID:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, EID.OnMenuRender)
end

local function mainMenuRender(_)
    local mg = MenuManager
    local cidx = 0

    if(mg.GetActiveMenu()==MainMenuType.COLLECTION) then
        if(Input.IsActionTriggered(ButtonAction.ACTION_MENUTAB, cidx)) then
            if(TRINKET_MENU_ACTIVE) then
                CollectionMenu.SetSelectedPage(ITEMS_SAVED_PAGE)
                CollectionMenu.SetSelectedElement(ITEMS_SAVED_IDX)
            else
                ITEMS_SAVED_IDX = CollectionMenu.GetSelectedElement()
                ITEMS_SAVED_PAGE = CollectionMenu.GetSelectedPage()
            end
            TRINKET_MENU_ACTIVE = not TRINKET_MENU_ACTIVE
        end
    end

    local renderPos = Isaac.WorldToMenuPosition(MainMenuType.COLLECTION, Vector(0,0))-Vector(39,15)

    if(TRINKET_MENU_ACTIVE) then
        COLLECTION_SPRITE:Render(renderPos)

        local startIdx = PAGE_OFFSET*(SEL_IDX//PAGE_OFFSET)
        local startPos = COLLECTION_SPRITE:GetNullFrame("FirstItemPos"):GetPos()+renderPos

        local isSelectedUndiscovered = false
        
        -- inputs
        local horizontalVal = Input.GetActionValue(ButtonAction.ACTION_MENURIGHT,cidx)-Input.GetActionValue(ButtonAction.ACTION_MENULEFT,cidx)
        local verticalVal = Input.GetActionValue(ButtonAction.ACTION_MENUDOWN,cidx)-Input.GetActionValue(ButtonAction.ACTION_MENUUP,cidx)
        
        local toAdd = 0

        TIME_HELD_INPUTS = TIME_HELD_INPUTS+1
        if(math.abs(verticalVal)>0.1) then
            toAdd = toAdd+(verticalVal>0 and 1 or -1)*PER_LINE
        elseif(math.abs(horizontalVal)>0.1) then
            toAdd = toAdd+(horizontalVal>0 and 1 or -1)
        else
            TIME_HELD_INPUTS = 0
        end

        if(toAdd~=0) then
            if(TIME_HELD_INPUTS==1 or (TIME_HELD_INPUTS>=DELAY_BEFORE_AUTOHOLD and (TIME_HELD_INPUTS-DELAY_BEFORE_AUTOHOLD)%AUTOHOLD_MOVE_FREQ==0)) then
                SEL_IDX = SEL_IDX+toAdd
            end
        end

        if(SEL_IDX<0) then
            SEL_IDX = PER_LINE*math.ceil(NUM_TRINKETS/PER_LINE)+SEL_IDX
        end
        if(SEL_IDX>=NUM_TRINKETS) then
            if(SEL_IDX==NUM_TRINKETS and toAdd==1) then
                SEL_IDX = 0
            elseif(SEL_IDX//PER_LINE~=NUM_TRINKETS//PER_LINE) then
                SEL_IDX = SEL_IDX%PER_LINE
            else
                SEL_IDX = NUM_TRINKETS-1
            end
        end


        -- render sprites
        for i=startIdx+1, math.min(startIdx+PAGE_OFFSET, NUM_TRINKETS) do
            local id = IDX_TO_TRINKETID[i]

            local node = XMLData.GetEntryById(XMLNode.TRINKET, id)
            local cachedSprite = MOD_ANM_TABLE[node.sourceid] ---@type Sprite
            local frame = id-(FIRST_TRINKET_ID[node.sourceid] or 0)

            local modIdx = (i-1)%PAGE_OFFSET
            local finalPos = startPos+Vector(modIdx%PER_LINE, modIdx//PER_LINE)*16

            local renderInvalidIcon = false
            local renderUndiscoveredIcon = false
            if(cachedSprite) then
                if(cachedSprite:GetCurrentAnimationData():GetLength()<=frame) then
                    renderInvalidIcon = true
                else
                    cachedSprite:SetFrame(frame)
                end
            else
                renderInvalidIcon = true
            end

            if(renderInvalidIcon) then
                ICONS_SPRITE:SetFrame("No Sprite", 0)
                ICONS_SPRITE:Render(finalPos)
            elseif(renderUndiscoveredIcon) then
                ICONS_SPRITE:SetFrame("Undiscovered", 0)
                ICONS_SPRITE:Render(finalPos)
            else
                cachedSprite:Render(finalPos)
            end
        end

        -- render selected trinket
        -- border
        local modIdx = SEL_IDX%PAGE_OFFSET
        local borderPos = startPos+Vector(modIdx%PER_LINE, modIdx//PER_LINE)*16

        ICONS_SPRITE:SetFrame("Border", 0)
        ICONS_SPRITE:Render(borderPos)

        -- data
        local dataPos = COLLECTION_SPRITE:GetNullFrame("BigItemIcon"):GetPos()+renderPos
        local conf = Isaac.GetItemConfig():GetTrinket(IDX_TO_TRINKETID[SEL_IDX+1])

        ITEM_SPRITE:ReplaceSpritesheet(0, conf.GfxFileName, true)
        ITEM_SPRITE:Render(dataPos)

        local name = conf.Name
        local localizedName = Isaac.GetString("Items", name)
        if(localizedName~="StringTable::InvalidKey") then
            name = localizedName
        end

        local desc = conf.Description
        local localizedDesc = Isaac.GetString("Items", desc)
        if(localizedDesc~="StringTable::InvalidKey") then
            desc = localizedDesc
        end

        TEXT_FONT:DrawString(name, dataPos.X+18, dataPos.Y-16, TEXT_COLOR)
        TEXT_FONT:DrawString(desc, dataPos.X+18, dataPos.Y-1, TEXT_COLOR)

        -- render buttons
        local bulletPos = COLLECTION_SPRITE:GetNullFrame("Bullet"):GetPos()+renderPos
        local numPages = math.ceil(NUM_TRINKETS/PAGE_OFFSET)
        local selPage = math.ceil((SEL_IDX+1)/PAGE_OFFSET)
        local bulletDist = math.min(MAX_DIST_BETWEEN_BULLETS, MAX_BULLET_TOTAL_DIST/numPages)
        if(numPages<=1) then
            bulletDist=0
        end

        bulletPos.Y = bulletPos.Y-bulletDist*(numPages/2+0.5)
        for i=1, numPages do
            ICONS_SPRITE:SetFrame("Bullets", (i==selPage and 1 or 0))
            ICONS_SPRITE:Render(bulletPos+Vector(0,bulletDist*i))
        end
    end

    local tabsRenderPos = renderPos+Vector(64,4)
    TABS_SPRITE:SetFrame((TRINKET_MENU_ACTIVE and 1 or 0))
    TABS_SPRITE:Render(tabsRenderPos)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_MAIN_MENU_RENDER, CallbackPriority.IMPORTANT, mainMenuRender)