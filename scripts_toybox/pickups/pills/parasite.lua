
local sfx = SFXManager()

local EXTRA_FLIES = 2

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    local dataTable = ToyboxMod:getExtraDataTable()

    local numFlies = EXTRA_FLIES
    for _, ent in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 2000, EntityPartition.ENEMY)) do
        if(ent:IsEnemy() and ent:IsActiveEnemy()) then
            numFlies = numFlies+1
        end
    end
    if(isHorse) then numFlies = numFlies*2-EXTRA_FLIES end

    player:AddBlueFlies(numFlies, player.Position, player)

    player:AnimateHappy()
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_PARASITE)