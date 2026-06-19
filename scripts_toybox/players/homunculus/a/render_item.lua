local id = -1

local UI_SPRITE = Sprite("gfx_tb/ui/ui_homunculus_inventory.anm2", true)
UI_SPRITE:Play("Idle", true)

local REVIVE_FONT = Font()
REVIVE_FONT:Load("font/pftempestasevencondensed.fnt")

---@param itemId CollectibleType
---@return Sprite
local function getItemSprite(itemId)
    local spr = Sprite("gfx_tb/ui/ui_item_render.anm2", true)
    spr:Play("Idle", true)
    spr.Scale = Vector(0.5,0.5)

    local conf = Isaac.GetItemConfig():GetCollectible(itemId)
    if(conf) then
        spr:ReplaceSpritesheet(0, conf.GfxFileName, true)
    end

    return {Sprite=spr, ID=itemId}
end

---@param pl EntityPlayer
local function renderCollectible(_, offset, sprite, pos, x, pl)
    if(ToyboxMod.GAME:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0) then return end
    if(pl:GetPlayerIndex() < 0) then return end
    if(pl:GetPlayerType() ~= ToyboxMod.PLAYER_HOMUNCULUS_A) then return end

    local hud = ToyboxMod.GAME:GetHUD():GetPlayerHUD(math.min(7,pl:GetPlayerIndex()))
    local h = hud:GetHearts()

    local heartsPerLine = 6
    if(not hud:GetPlayer()) then
        heartsPerLine = 3
    end

    --pos = pos-Vector(0.5,1)

    local max_iMod = 0
    local max_iLines = 1
    for i, heartdata in ipairs(h) do
        if(heartdata:IsVisible()) then
            max_iMod = math.max(max_iMod, (i-1)%heartsPerLine+1)
            max_iLines = math.max(max_iLines, 1+(i-1)//6)
        end
    end

    local finalPos = pos+Vector(max_iMod, (max_iLines-1)/2)*Vector(12,10)+Vector(3,-1)
    if(pl:GetExtraLives()>0) then
        local str = "x"..tostring(pl:GetExtraLives())..(pl:HasChanceRevive() and "?" or "")
        finalPos = finalPos+Vector(REVIVE_FONT:GetStringWidth(str),0)+Vector(4,0)
    end
    if(pl:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) then
        finalPos = finalPos+Vector(12,0)
    end

    local item = ToyboxMod:getEntityData(pl, "HOMUNCULUS_A_ITEM")
    if(not item or item==-1) then
        UI_SPRITE.Color = Color(1,1,1,0.5)
        UI_SPRITE:SetFrame(3)
        UI_SPRITE:Render(finalPos+Vector(0.5,-0.5))
    else
        local itemSprite = ToyboxMod:getEntityData(pl, "HOMUNCULUS_ITEM_SPRITE")
        if(not (itemSprite and itemSprite.ID==item)) then
            itemSprite = getItemSprite(item)

            ToyboxMod:setEntityData(pl, "HOMUNCULUS_ITEM_SPRITE", itemSprite)
        end
        itemSprite.Sprite:Render(finalPos)
    end

    UI_SPRITE.Color = Color(1,1,1,1)
    UI_SPRITE:SetFrame(0)
    UI_SPRITE:Render(finalPos)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, renderCollectible)