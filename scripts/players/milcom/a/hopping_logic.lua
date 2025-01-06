local mod = MilcomMOD

-- [[
---@param player EntityPlayer
local function jumpOffset(_, player, offset)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    local renderMode = Game():GetRoom():GetRenderMode()

    local data = mod:getMilcomATable(player)
    local isMoving = player:GetMovementJoystick():Length()>1e-4
    if((isMoving or (not isMoving and data.CURRENT_JUMPHEIGHT>1e-6)) and player:GetFlyingOffset():Length()==0) then -- if you're moving/you're not moving but still in air AND your not flying
        local maxHeight = math.floor((data.MAX_JUMPDURATION)*(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 0.3 or 1)*((1/player.MoveSpeed)^2))
        data.CURRENT_JUMPHEIGHT = data.MAX_JUMPHEIGHT*math.abs(math.sin(data.JUMP_FRAMES*math.pi/maxHeight))
        if(mod:renderingAboveWater() and not Game():IsPaused()) then data.JUMP_FRAMES = (data.JUMP_FRAMES+1)%(maxHeight*2) end
    else
        data.CURRENT_JUMPHEIGHT = 0
    end

    local jumpHeight = -data.CURRENT_JUMPHEIGHT
    if(renderMode==RenderMode.RENDER_WATER_REFLECT) then jumpHeight = -jumpHeight end

    return Vector(0, jumpHeight)
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, jumpOffset)
--]]