local mod = ToyboxMod
local sfx = SFXManager()

local EXTRA_FLIES = 2

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    local dataTable = mod:getExtraDataTable()

    local numFlies = #(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY))+EXTRA_FLIES
    if(isHorse) then numFlies = numFlies*2-EXTRA_FLIES end

    player:AddBlueFlies(numFlies, player.Position, player)

    player:AnimateHappy()
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_EFFECT.PARASITE)