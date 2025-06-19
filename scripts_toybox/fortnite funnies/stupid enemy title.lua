

local MENU_SIZE = Vector(480, 270)
local PADDING = 250

local function getRandomBestiaryEntry()
    local entry = XMLData.GetEntryByOrder(XMLNode.ENTITY, math.random(XMLData.GetNumEntries(XMLNode.ENTITY)))
    if(not (entry.bestiary and entry.bestiary[1] and not entry.bestiary[1].parent)) then
        return getRandomBestiaryEntry()
    end
    return entry
end
local function getbbjasdj()
    local entry = getRandomBestiaryEntry()
    local beast = entry.bestiary[1]

    local sp = Sprite(entry.anm2root..entry.anm2path, true)
    local transforms = {}
    local foundIdx = {0}
    local transFstrjng = beast.transform
    if(not transFstrjng) then
        transFstrjng = "0,0,1"
    end

    while(true) do
        local idx = foundIdx[#foundIdx]
        local newIdx = string.find(transFstrjng, ",", idx+1)
        if(newIdx) then
            table.insert(foundIdx, newIdx)
        else
            break
        end
    end

    table.insert(foundIdx, 0)

    for i=1, #foundIdx-1 do
        table.insert(transforms, string.sub(transFstrjng, foundIdx[i]+1, foundIdx[i+1]-1))
    end

    sp:Load(entry.anm2root..(beast.anm2path or entry.anm2path), true)
    if(beast.anim) then sp:Play(beast.anim, true) end
    if(beast.overlay) then sp:PlayOverlay(beast.overlay, true) end
    sp.Offset = Vector(transforms[1], transforms[2])
    sp.PlaybackSpeed = transforms[3]*0.4

    if(sp:GetLayer("shadow")) then
        sp:GetLayer("shadow"):SetColor(Color(1,1,1,0.3))
    end

    return {
        SPRITE = sp,
        POS = Vector(0, math.random())*MENU_SIZE+Vector(-PADDING,0),
        VEL_INTENSITY = Vector(math.random()+1, (math.random()+0.5)),
        FRAME_OFFSET = math.random(720)
    }
end

local ITEM_SPRITES = {}
for _=1, 150 do
    local entry = getbbjasdj()
    entry.POS = Vector(math.random(-PADDING, MENU_SIZE.X+PADDING), math.random(MENU_SIZE.Y))

    table.insert(ITEM_SPRITES, entry)
end

local counter = 0

local function postMenuRender(_)
    local topLeftCorner = MenuManager:GetViewPosition()
    local bottomRightCorner = topLeftCorner+MENU_SIZE

    for i, spData in ipairs(ITEM_SPRITES) do
        spData.SPRITE:Render(spData.POS+topLeftCorner)

        spData.SPRITE:Update()
        if(spData.SPRITE:IsFinished()) then
            spData.SPRITE:Play(spData.SPRITE:GetAnimation(), true)
        end

        local posToAdd = Vector(1, math.sin(math.rad((counter+spData.FRAME_OFFSET))))*spData.VEL_INTENSITY
        spData.POS = spData.POS+posToAdd
        if(spData.POS.X>MENU_SIZE.X+PADDING) then
            ITEM_SPRITES[i] = getbbjasdj()
        end
    end
    counter = counter+1
end
ToyboxMod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, postMenuRender)