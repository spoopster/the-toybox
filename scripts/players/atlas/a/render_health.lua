local mod = MilcomMOD

local HP_SPRITE = Sprite()
HP_SPRITE:Load("gfx/ui/atlas_a/ui_mantle_hp.anm2", true)
HP_SPRITE:Play("Test", true)

---@param sprite Sprite
---@param pos Vector
local function renderTest(_, offset, sprite, pos, u)
    if(offset.X==1) then return end

    --print(pos)

    --return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_HEARTS, renderTest)

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

local function renderHearts(_)
    for pIdx, player in pairs(mod:getTruePlayers()) do

    if(pIdx>=4) then goto invalidPlayer end
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end

    do
        player = player:ToPlayer()
        local renderPos = mod:getHeartHudPosition(pIdx)
        local data = mod:getAtlasATable(player)

        local hasCurseOfTheUnknown = false
        if(Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN ~= 0) then hasCurseOfTheUnknown=true end
        local selHealthIndex = mod:getSelMantleIdToDestroy(player, mod:getHeldMantle(player))

        HP_SPRITE.Color = Color(1,1,1,1)
        HP_SPRITE.Rotation = 0

        for i=1, data.HP_CAP do
            local spriteToRender = mod.MANTLE_TYPE_TO_ANM[data.MANTLES[i].TYPE or mod.MANTLES.NONE] or "Empty"
            local hpToRender = data.MANTLES[i].MAXHP-data.MANTLES[i].HP
            if(hpToRender<0) then hpToRender=0 end

            if(hasCurseOfTheUnknown) then
                spriteToRender = mod.MANTLE_TYPE_TO_ANM[1000]
                hpToRender=0
                if(i>1) then break end
            end

            HP_SPRITE:SetFrame(spriteToRender, hpToRender)

            if(selHealthIndex==i and not hasCurseOfTheUnknown) then
                local sinColor = math.sin(math.rad(player.FrameCount*10))*0.25+0.5

                if(data.MANTLES[i].TYPE==mod.MANTLES.NONE) then HP_SPRITE.Color = Color(1,1,1,1,sinColor,sinColor,sinColor)
                else HP_SPRITE.Color = Color(1,1,1,1,sinColor,0,sinColor*0.1) end
            end
            
            HP_SPRITE:Render(renderPos)

            HP_SPRITE.Color = Color(1,1,1,1)

            renderPos = renderPos+Vector(19,0)
        end

        renderMantleShards(player, hasCurseOfTheUnknown)
    end

    ::invalidPlayer::

    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_HUD_RENDER, 1e6, renderHearts)

local function postRender(_)
    local player = Isaac.GetPlayer()
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)

    --local mantles = data.MANTLES
    local xPos = 60
    local yPos = 40

    --[[
    Isaac.RenderText("1, "..mod:getMantleNameFromType(mantles[1].TYPE)..", "..mantles[1].HP.."  |  "..
    "2, "..mod:getMantleNameFromType(mantles[2].TYPE)..", "..mantles[2].HP.."  |  "..
    "3, "..mod:getMantleNameFromType(mantles[3].TYPE)..", "..mantles[3].HP
    , xPos, yPos, 1,1,1,1)
    --]]

    Isaac.RenderText("CURRENT TRANSF", xPos, yPos, 1,1,1,0.5)
    Isaac.RenderText(mod:getMantleNameFromType(data.TRANSFORMATION), xPos, yPos+13, 1,1,1,0.5)

    Isaac.RenderText("OLD TRANSF", xPos, yPos+30, 1,1,1,0.5)
    Isaac.RenderText(mod:getMantleNameFromType(data.BIRTHRIGHT_TRANSFORMATION), xPos, yPos+43, 1,1,1,0.5)

    Isaac.RenderText(tostring(data.SALT_AUTOTARGET_ENABLED), xPos, yPos+77, 1,1,1,0.5)
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, postRender)