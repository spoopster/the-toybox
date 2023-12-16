local mod = MilcomMOD

---@param player EntityPlayer
local function renderPlayer(player, pos)
    player:RenderGlow(pos)
    player:RenderBody(pos)
    player:RenderHead(pos)
    player:RenderTop(pos)
end

---@param player EntityPlayer
local function hoppingLogic(_, player, offset)
    if(player:GetPlayerType()~=mod.MILCOM_A_ID) then return end
    local dataTable = mod:getMilcomATable(player)

    if(dataTable.RENDERING_PLAYER==true) then return end
    dataTable.RENDERING_PLAYER=true

    player.PositionOffset = dataTable.POS_OFFSET

    local isMoving = player:GetMovementJoystick():Length()>1e-4
    
    if((isMoving or (not isMoving and dataTable.CURRENT_JUMPHEIGHT>1e-6)) and player:GetFlyingOffset():Length()==0) then
        dataTable.CURRENT_JUMPHEIGHT = dataTable.MAX_JUMPHEIGHT*math.abs(math.sin(dataTable.JUMP_FRAMES*math.pi/dataTable.MAX_JUMPDURATION))

        if(not Game():IsPaused()) then dataTable.JUMP_FRAMES = (dataTable.JUMP_FRAMES+1)%(dataTable.MAX_JUMPDURATION*2) end
    else
        dataTable.CURRENT_JUMPHEIGHT = 0
    end

    print(Game():GetRoom():GetRenderScrollOffset())

    local renderPos = Isaac.WorldToScreen(player.Position+Vector(0,-dataTable.CURRENT_JUMPHEIGHT))+offset-Game():GetRoom():GetRenderScrollOffset()
    renderPos = renderPos+player:GetFlyingOffset()

    if(player:IsFullSpriteRendering()) then
        player.PositionOffset = Vector.Zero
        local pos = renderPos-Isaac.WorldToScreen(player.Position)+Game():GetRoom():GetRenderScrollOffset()
        player:Render(pos)
        
        player.PositionOffset = dataTable.POS_OFFSET
    else
        renderPlayer(player, renderPos)
    end    

    dataTable.RENDERING_PLAYER=false
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, hoppingLogic, 0)
