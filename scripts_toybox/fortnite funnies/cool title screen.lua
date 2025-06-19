
local conf = Isaac.GetItemConfig()
if(not ToyboxMod.CONFIG.AWESOME_FUCKING_TITLESCREEN) then return end

local CHANGED_MENU_SPRITE = false

local MENU_SIZE = Vector(480, 270)
local ITEM_POS_PADDING = Vector(120, 20)
local FRAMES = 0

local PLAYER_FILENAMES = {
    "gfx/ui/player_portraits/tb_atlas_portrait.png",
    "gfx/ui/player_portraits/tb_atlas_tar_portrait.png",
    "gfx/ui/player_portraits/tb_jonas_portrait.png",
    "gfx/ui/player_portraits/tb_milcom_portrait.png",
}
local PLAYER_SPRITE = Sprite("gfx/ui/tb_awesome_title_screen.anm2", true)
PLAYER_SPRITE:Play("Character", true)
PLAYER_SPRITE:ReplaceSpritesheet(0, PLAYER_FILENAMES[math.random(#PLAYER_FILENAMES)], true)

local BIG_ITEMS = {
    --["gfx/items/collectibles/tb_gambling_addiction.png"] = true,
}

local ITEM_FILENAMES = {}

for key, id in pairs(ToyboxMod) do
    local iconf
    if(string.find(key, "COLLECTIBLE_")) then
        iconf = conf:GetCollectible(id)
    end
    if(string.find(key, "TRINKET_")) then
        iconf = conf:GetTrinket(id)
    end

    if(iconf and not iconf.Hidden) then
        table.insert(ITEM_FILENAMES, iconf.GfxFileName)
    end
end


local function getRandomItemGfx()
    return ITEM_FILENAMES[math.random(#ITEM_FILENAMES)]
end
local function randomItemPos()
    return Vector(-ITEM_POS_PADDING.X, math.random(MENU_SIZE.Y+ITEM_POS_PADDING.Y*2)-ITEM_POS_PADDING.Y)
end
local function randomItemVel()
    return Vector(1.5*(math.random()*1.5+0.75), 1*(math.random()+1))
end
local function randomItemOscillation()
    return (math.random()+1)*0.3
end
local function randomItemOffset()
    return math.random(10000)
end
local function randomItemAccel()
    return Vector(0,0)
end

local ITEM_SPRITES = {}
for _=1, 150 do
    local itemgfx = getRandomItemGfx()

    local sp = Sprite("gfx/ui/tb_awesome_title_screen.anm2", true)
    sp:Play("Item", true)
    sp:ReplaceSpritesheet(1, itemgfx, true)

    if(BIG_ITEMS[itemgfx]) then
        sp:SetFrame(1)
    else
        sp:SetFrame(0)
    end

    table.insert(ITEM_SPRITES,{
        SPRITE = sp,
        POS = randomItemPos()+Vector(math.random(MENU_SIZE.X+ITEM_POS_PADDING.X*2), 0),
        VEL = randomItemVel(),
        OSC_INTENSITY = randomItemOscillation(),
        FRAME_OFFSET = randomItemOffset(),
        ACCEL = randomItemAccel(),
    })
end

local function postMenuRender(_)
    local TITLE_SPRITE = TitleMenu.GetSprite()
    if(TITLE_SPRITE:GetLayer(0):GetSpritesheetPath()~="gfx/ui/tb_awesome_title_menu.png") then
        TITLE_SPRITE:ReplaceSpritesheet(0, "gfx/ui/tb_awesome_title_menu.png", true)
        TITLE_SPRITE:ReplaceSpritesheet(1, "gfx/ui/tb_awesome_title_menu.png", true)
        TITLE_SPRITE:ReplaceSpritesheet(2, "gfx/ui/tb_awesome_title_logo.png", true)
        TITLE_SPRITE:ReplaceSpritesheet(3, "gfx/ui/tb_awesome_title_logo.png", true)
    end

    local topLeftCorner = MenuManager:GetViewPosition()
    local bottomRightCorner = topLeftCorner+MENU_SIZE

    local centerCharacterPos = topLeftCorner+Vector(245,156)
    PLAYER_SPRITE.Rotation = math.sin(math.rad(FRAMES))*10
    PLAYER_SPRITE:Render(centerCharacterPos)

    FRAMES = FRAMES+1

    for _, spData in ipairs(ITEM_SPRITES) do
        spData.SPRITE:Render(spData.POS+topLeftCorner)
        spData.POS = spData.POS+Vector(1,0)*spData.VEL.X+Vector(0,math.sin(math.rad((FRAMES+spData.FRAME_OFFSET)*spData.VEL.Y))*0.1*spData.OSC_INTENSITY)
        spData.VEL = spData.VEL+spData.ACCEL

        if(spData.POS.X>MENU_SIZE.X+ITEM_POS_PADDING.X) then
            local itemgfx = getRandomItemGfx()

            spData.SPRITE:ReplaceSpritesheet(1, itemgfx, true)
            spData.POS = randomItemPos()
            spData.VEL = randomItemVel()
            spData.OSC_INTENSITY = randomItemOscillation()
            spData.FRAME_OFFSET = randomItemOffset()
            spData.ACCEL = randomItemAccel()

            if(BIG_ITEMS[itemgfx]) then
                spData.SPRITE:SetFrame(1)
            else
                spData.SPRITE:SetFrame(0)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, postMenuRender)