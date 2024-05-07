local mod = MilcomMOD

local HP_SPRITE = Sprite()
HP_SPRITE:Load("gfx/ui/atlas_a/ui_mantle_hp.anm2", true)
HP_SPRITE:Play("RockMantle", true)

local TRANSF_SPRITE = Sprite()
TRANSF_SPRITE:Load("gfx/ui/atlas_a/ui_mantle_transformations.anm2", true)
TRANSF_SPRITE:Play("RockMantle", true)
TRANSF_SPRITE.Offset = Vector(0,-1)

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

local function renderMantleShards(player, hasUnknown)
    local data = mod:getAtlasATable(player)

    HP_SPRITE:Play("Shard", true)

    for i, sData in pairs(data.MANTLE_SHARDS) do
        sData.Velocity = Vector(
            mod:lerp(sData.Velocity.X, 0, 0.05),
            (sData.Velocity.Y<mod.MANTLE_SHARD_GRAVITY and mod:lerp(sData.Velocity.Y, mod.MANTLE_SHARD_GRAVITY, 0.05) or mod:lerp(sData.Velocity.Y, mod.MANTLE_SHARD_GRAVITY*2, 0.025))
        )
        sData.Position = sData.Position+sData.Velocity

        if(not hasUnknown) then
            HP_SPRITE:SetFrame(sData.Frame)
            HP_SPRITE.Rotation = sData.Rotation

            local a = mod:clamp(1-sData.Lifeframes/sData.Lifespan, 1, 0)
            HP_SPRITE.Color = Color(sData.Color.R, sData.Color.G, sData.Color.B, sData.Color.A*a, sData.Color.RO, sData.Color.GO, sData.Color.BO)

            HP_SPRITE:Render(sData.Position)
        end

        sData.Rotation = sData.Rotation + 4

        if(sData.Lifeframes>sData.Lifespan) then data.MANTLE_SHARDS[i] = nil
        else sData.Lifeframes = sData.Lifeframes+1 end
    end
end

---@param sprite Sprite
---@param pos Vector
local function renderMantles(_, offset, sprite, pos, u, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    player = player:ToPlayer()
    local renderPos = pos+Vector(4,0)
    local data = mod:getAtlasATable(player)

    local hasCurseOfTheUnknown = false
    if(Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0) then hasCurseOfTheUnknown=true end
    local selHealthIndex = mod:getSelMantleIdToDestroy(player, mod:getHeldMantle(player))

    HP_SPRITE.Color = Color(1,1,1,1)
    HP_SPRITE.Rotation = 0

    local heartPosOffsets = Vector(18,0)
    local heartRenderPos = renderPos-heartPosOffsets
    for i=1, data.HP_CAP do
        heartRenderPos = heartRenderPos+heartPosOffsets

        local spriteToRender = mod.MANTLE_DATA[mod:getMantleKeyFromId(data.MANTLES[i].TYPE) or "NONE"].ANIM or mod.MANTLE_DATA.NONE.ANIM
        local hpToRender = data.MANTLES[i].MAXHP-data.MANTLES[i].HP
        if(hpToRender<0) then hpToRender=0 end

        if(hasCurseOfTheUnknown) then
            spriteToRender = mod.MANTLE_DATA.UNKNOWN.ANIM
            hpToRender=0
            if(i>1) then break end
        end

        HP_SPRITE:SetFrame(spriteToRender, hpToRender)

        if(data.MANTLES[i].COLOR and i==1) then
            local s = ""
            if(type(data.MANTLES[i].COLOR)=="table") then 
                for key, val in pairs(data.MANTLES[i].COLOR) do s=s..tostring(key)..": "..tostring(val).." | " end
            else s=(data.MANTLES[i].COLOR) end

            --print(s)
        end

        local updatedColor=false
        if(selHealthIndex==i and not hasCurseOfTheUnknown) then
            updatedColor=true

            local sinColor = math.sin(math.rad(player.FrameCount*10))*0.25+0.5

            if(data.MANTLES[i].TYPE==mod.MANTLE_DATA.NONE.ID) then data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1,sinColor,sinColor,sinColor), 0.5)
            else data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1,sinColor,0,sinColor*0.1), 0.5) end
        end

        if(not updatedColor) then data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1), 0.15) end
        
        HP_SPRITE.Color = data.MANTLES[i].COLOR or Color(1,1,1,1)
        HP_SPRITE:Render(heartRenderPos)
    end

    local hasCollar = player:HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
    
    local extraLivesString = ""
    if(player:GetExtraLives()>0) then
        extraLivesString = "x"..player:GetExtraLives()..(hasCollar and "?" or "")
        f:DrawString(extraLivesString, heartRenderPos.X-5, heartRenderPos.Y-9,KColor(1,1,1,1))
    end

    TRANSF_SPRITE.Scale = Vector(1,1)

    TRANSF_SPRITE:Play(mod.MANTLE_DATA[mod:getMantleKeyFromId(data.TRANSFORMATION) or "NONE"].ANIM or mod.MANTLE_DATA.NONE.ANIM, true)
    if(hasCurseOfTheUnknown) then TRANSF_SPRITE:Play(mod.MANTLE_DATA.UNKNOWN.ANIM) end

    local trfRenderPos = renderPos+(heartRenderPos-renderPos)/2+Vector((player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and -12 or 0)-1,20)
    TRANSF_SPRITE:Render(trfRenderPos)

    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
        TRANSF_SPRITE:Play(mod.MANTLE_DATA[mod:getMantleKeyFromId(data.BIRTHRIGHT_TRANSFORMATION) or "NONE"].ANIM or mod.MANTLE_DATA.NONE.ANIM, true)
        if(hasCurseOfTheUnknown) then TRANSF_SPRITE:Play(mod.MANTLE_DATA.UNKNOWN.ANIM) end
        TRANSF_SPRITE:Render(trfRenderPos+Vector(24,0))

        TRANSF_SPRITE:Play("BirthrightOverlay", true)
        TRANSF_SPRITE.Scale = Vector(1,1)*0.5
        TRANSF_SPRITE:Render(trfRenderPos+Vector(34,4))
    end

    renderMantleShards(player, hasCurseOfTheUnknown)

    return true
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_HEARTS, -1e6, renderMantles)

local function renderHearts(_)
    for pIdx, player in pairs(mod:getTruePlayers()) do

    if(pIdx>=4) then goto invalidPlayer end
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end

    do
        player = player:ToPlayer()
        local renderPos = mod:getHeartHudPosition(pIdx)+Vector(4,0)
        local data = mod:getAtlasATable(player)

        local hasCurseOfTheUnknown = false
        if(Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0) then hasCurseOfTheUnknown=true end
        local selHealthIndex = mod:getSelMantleIdToDestroy(player, mod:getHeldMantle(player))

        HP_SPRITE.Color = Color(1,1,1,1)
        HP_SPRITE.Rotation = 0

        local heartPosOffsets = Vector(18,0)
        local heartRenderPos = renderPos-heartPosOffsets
        for i=1, data.HP_CAP do
            heartRenderPos = heartRenderPos+heartPosOffsets

            local spriteToRender = mod.MANTLE_DATA[mod:getMantleKeyFromId(data.MANTLES[i].TYPE) or "NONE"].ANIM or mod.MANTLE_DATA.NONE.ANIM
            local hpToRender = data.MANTLES[i].MAXHP-data.MANTLES[i].HP
            if(hpToRender<0) then hpToRender=0 end

            if(hasCurseOfTheUnknown) then
                spriteToRender = mod.MANTLE_DATA.UNKNOWN.ANIM
                hpToRender=0
                if(i>1) then break end
            end

            HP_SPRITE:SetFrame(spriteToRender, hpToRender)

            if(data.MANTLES[i].COLOR and i==1) then
                local s = ""
                if(type(data.MANTLES[i].COLOR)=="table") then 
                    for key, val in pairs(data.MANTLES[i].COLOR) do s=s..tostring(key)..": "..tostring(val).." | " end
                else s=(data.MANTLES[i].COLOR) end

                --print(s)
            end

            local updatedColor=false
            if(selHealthIndex==i and not hasCurseOfTheUnknown) then
                updatedColor=true

                local sinColor = math.sin(math.rad(player.FrameCount*10))*0.25+0.5

                if(data.MANTLES[i].TYPE==mod.MANTLE_DATA.NONE.ID) then data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1,sinColor,sinColor,sinColor), 0.5)
                else data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1,sinColor,0,sinColor*0.1), 0.5) end
            end

            if(not updatedColor) then data.MANTLES[i].COLOR = Color.Lerp(data.MANTLES[i].COLOR or Color(1,1,1,1), Color(1,1,1,1), 0.15) end
            
            HP_SPRITE.Color = data.MANTLES[i].COLOR or Color(1,1,1,1)
            HP_SPRITE:Render(heartRenderPos)
        end

        local hasCollar = player:HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR)
        
        local extraLivesString = ""
        if(player:GetExtraLives()>0) then
            extraLivesString = "x"..player:GetExtraLives()..(hasCollar and "?" or "")
            f:DrawString(extraLivesString, heartRenderPos.X-5, heartRenderPos.Y-9,KColor(1,1,1,1))
        end

        TRANSF_SPRITE.Scale = Vector(1,1)

        TRANSF_SPRITE:Play(mod.MANTLE_DATA[mod:getMantleKeyFromId(data.TRANSFORMATION) or "NONE"].ANIM or mod.MANTLE_DATA.NONE.ANIM, true)
        if(hasCurseOfTheUnknown) then TRANSF_SPRITE:Play(mod.MANTLE_DATA.UNKNOWN.ANIM) end

        local trfRenderPos = renderPos+(heartRenderPos-renderPos)/2+Vector((player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and -12 or 0)-1,20)
        TRANSF_SPRITE:Render(trfRenderPos)

        if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)) then
            TRANSF_SPRITE:Play(mod.MANTLE_DATA[mod:getMantleKeyFromId(data.BIRTHRIGHT_TRANSFORMATION) or "NONE"].ANIM or mod.MANTLE_DATA.NONE.ANIM, true)
            if(hasCurseOfTheUnknown) then TRANSF_SPRITE:Play(mod.MANTLE_DATA.UNKNOWN.ANIM) end
            TRANSF_SPRITE:Render(trfRenderPos+Vector(24,0))

            TRANSF_SPRITE:Play("BirthrightOverlay", true)
            TRANSF_SPRITE.Scale = Vector(1,1)*0.5
            TRANSF_SPRITE:Render(trfRenderPos+Vector(34,4))
        end

        renderMantleShards(player, hasCurseOfTheUnknown)
    end

    ::invalidPlayer::

    end
end
--mod:AddPriorityCallback(ModCallbacks.MC_POST_HUD_RENDER, 1e6, renderHearts)