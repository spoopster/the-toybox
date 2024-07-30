local mod = MilcomMOD
local sfx = SFXManager()

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    local dataTable = mod:getExtraDataTable()

    local numToRemove = 0
    if(player:GetMaxHearts()>0) then
        numToRemove = (2-player:GetMaxHearts()%2)
        if(isHorse) then numToRemove = player:GetMaxHearts() end
    end

    print(numToRemove)
    player:AddHearts(-numToRemove)
    player:AddMaxHearts(-numToRemove)
    player:AddBoneHearts(math.ceil(numToRemove/2))

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
    player:AnimatePill(color)
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_OSSIFICATION)