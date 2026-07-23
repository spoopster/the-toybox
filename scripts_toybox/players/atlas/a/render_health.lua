

local HP_SPRITE = Sprite()
HP_SPRITE:Load("gfx_tb/ui/ui_mantlehearts.anm2", true)
HP_SPRITE:Play("RockMantle", true)

local TRANSF_SPRITE = Sprite()
TRANSF_SPRITE:Load("gfx_tb/ui/ui_mantleicons.anm2", true)
TRANSF_SPRITE:Play("RockMantle", true)
TRANSF_SPRITE.Offset = Vector(0,-1)

local VANILLA_HP_SPRITE = Sprite()
VANILLA_HP_SPRITE:Load("gfx_tb/ui/ui_hearts.anm2", true)
VANILLA_HP_SPRITE:Play("HolyMantle", true)

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

---@param sprite Sprite
---@param pos Vector
---@param player EntityPlayer
local function renderMantles(offset, sprite, pos, u, player)
    player = player:ToPlayer()
    local renderPos = pos+Vector(0,0)
    local data = ToyboxMod:getAtlasATable(player)

    local isStrawman = (player.Parent~=nil)

    local hasCurseOfTheUnknown = false
    if(ToyboxMod.GAME:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0) then hasCurseOfTheUnknown=true end
    local selHealthIndex = ToyboxMod:getSelMantleIdToDestroy(player, ToyboxMod:getHeldMantle(player))

    HP_SPRITE.Color = Color(1,1,1,1)
    HP_SPRITE.Rotation = 0

    local heartPosOffsets = Vector(12,0)
    local heartRenderPos = renderPos-heartPosOffsets--+Vector(0,10)

    local alphaMult = (isStrawman and 0.5 or 0.75)

    TRANSF_SPRITE.Scale = Vector(1,1)
    TRANSF_SPRITE.Color = Color(1,1,1,alphaMult)*Color(1,1,1,(player:HasInstantDeathCurse() and 0.5 or 1))
    TRANSF_SPRITE:Play(ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(data.TRANSFORMATION) or "NONE"].ANIM or ToyboxMod.MANTLE_DATA.NONE.ANIM, true)
    if(hasCurseOfTheUnknown) then TRANSF_SPRITE:Play(ToyboxMod.MANTLE_DATA.UNKNOWN.ANIM) end
    local trfRenderPos = heartRenderPos+heartPosOffsets*(0.5+data.HP_CAP/2)+Vector(-0.5,0)--+(heartRenderPos-renderPos)/2+Vector(-5,0)
    trfRenderPos = trfRenderPos+(isStrawman and Vector(0,-13) or Vector(0,14))

    local shouldRender2Transformations = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and not (hasCurseOfTheUnknown or data.TRANSFORMATION==ToyboxMod.MANTLE_DATA.TAR.ID)
    if(shouldRender2Transformations) then trfRenderPos = trfRenderPos-Vector(8,0) end

    TRANSF_SPRITE:Render(trfRenderPos)

    if(shouldRender2Transformations) then
        TRANSF_SPRITE:Play(ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(data.BIRTHRIGHT_TRANSFORMATION) or "NONE"].ANIM or ToyboxMod.MANTLE_DATA.NONE.ANIM, true)
        if(hasCurseOfTheUnknown) then TRANSF_SPRITE:Play(ToyboxMod.MANTLE_DATA.UNKNOWN.ANIM) end
        TRANSF_SPRITE.Color = Color(1,1,1,alphaMult*0.5)
        TRANSF_SPRITE:Render(trfRenderPos+Vector(16,0))

        --TRANSF_SPRITE:Play("BirthrightOverlay", true)
        --TRANSF_SPRITE.Scale = Vector(1,1)*0.5
        --TRANSF_SPRITE:Render(trfRenderPos+Vector(20,6))
    end
    for i=1, data.HP_CAP do
        heartRenderPos = heartRenderPos+heartPosOffsets

        local spriteToRender = ToyboxMod.MANTLE_DATA[ToyboxMod:getMantleKeyFromId(data.MANTLES[i].TYPE) or "NONE"].ANIM or ToyboxMod.MANTLE_DATA.NONE.ANIM
        local hpToRender = data.MANTLES[i].MAXHP-data.MANTLES[i].HP
        if(hpToRender<0) then hpToRender=0 end

        if(hasCurseOfTheUnknown) then
            spriteToRender = ToyboxMod.MANTLE_DATA.UNKNOWN.ANIM
            hpToRender=0
            if(i>1) then break end
        end

        HP_SPRITE:SetFrame(spriteToRender, hpToRender)

        local updatedColor=false
        if(selHealthIndex==i and not hasCurseOfTheUnknown) then
            updatedColor=true

            local curSin = (math.sin(math.rad(player.FrameCount*10))+1)*0.5
            local sinColor = curSin*0.3+0.1

            if(data.MANTLES[i].TYPE==ToyboxMod.MANTLE_DATA.NONE.ID) then data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1,sinColor,sinColor,sinColor), 0.5)
            else data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1,sinColor,0,sinColor*0.1), 0.5) end
        end

        if(not updatedColor) then data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1), 0.15) end
        
        local finalColor = Color.Lerp((data.MANTLES[i].COLOR or Color(1,1,1,1)), Color.Default, 0)*sprite.Color*Color(1,1,1,(player:HasInstantDeathCurse() and 0.33 or 1))
        HP_SPRITE.Color = finalColor
        HP_SPRITE:Render(heartRenderPos)

        if(ToyboxMod:getMantleHeartData(player, i, "SOUL_SHIELD")==1 and not hasCurseOfTheUnknown) then
            ToyboxMod:renderSteelSoulSprite(player, heartRenderPos)
        end
    end
end

---@param player EntityPlayer
local function postRenderHearts(_, offset, sprite, pos, u, player)
    if(not ToyboxMod:isAtlasA(player)) then return end

    if(not player:HasInstantDeathCurse()) then
        renderMantles(offset, sprite, pos, u, player)
    else
        ToyboxMod.GAME:GetHUD():GetHeartsSprite():GetLayer(0):SetColor(Color(1,1,1,1))
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, -1e6, postRenderHearts)

---@param sprite Sprite
---@param player EntityPlayer
local function preRenderMangos(_, offset, sprite, pos, u, player)
    if(not ToyboxMod:isAtlasA(player)) then return end

    if(player:HasInstantDeathCurse()) then
        renderMantles(offset, sprite, pos, u, player)

        local sp = ToyboxMod.GAME:GetHUD():GetHeartsSprite()
        if(player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) then
            sp:SetFrame("HolyMantle", 0)
            sp:Render(pos)
        end

        sp:GetLayer(0):SetColor(Color(1,1,1,0.0))
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_HEARTS, CallbackPriority.LATE+100, preRenderMangos)