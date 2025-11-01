

-- [[
---@param player EntityPlayer
local function jumpOffset(_, player, offset)
    if(player:GetPlayerType()~=ToyboxMod.PLAYER_TYPE.MILCOM_A) then return end
    local renderMode = Game():GetRoom():GetRenderMode()

    local data = ToyboxMod:getMilcomATable(player)
    if(Game():GetRoom():GetFrameCount()<1) then
        data.CURRENT_JUMPHEIGHT = 0
        data.JUMP_FRAMES = 0
    else
        local isMoving = player:GetMovementJoystick():Length()>1e-4
        if((isMoving or (not isMoving and data.CURRENT_JUMPHEIGHT>1e-6)) and player:GetFlyingOffset():Length()==0) then -- if you're moving/you're not moving but still in air AND your not flying
            local maxHeight = math.floor((data.MAX_JUMPDURATION)*(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 0.3 or 1)*((1/player.MoveSpeed)^0.5))
            data.CURRENT_JUMPHEIGHT = data.MAX_JUMPHEIGHT*math.abs(math.sin(data.JUMP_FRAMES*math.pi/maxHeight))
            if(ToyboxMod:renderingAboveWater() and not Game():IsPaused()) then data.JUMP_FRAMES = (data.JUMP_FRAMES+1)%(maxHeight*2) end
        else
            data.CURRENT_JUMPHEIGHT = 0
        end
    end

    local jumpHeight = -data.CURRENT_JUMPHEIGHT
    if(renderMode==RenderMode.RENDER_WATER_REFLECT) then jumpHeight = -jumpHeight end

    return Vector(0, jumpHeight)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, jumpOffset)
--]]