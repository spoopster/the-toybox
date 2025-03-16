local mod = ToyboxMod
local sfx = SFXManager()

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    local dataTable = mod:getExtraDataTable()

    local blackHearts = player:GetBlackHearts()
    local numSouls = player:GetSoulHearts()

    local numConverted = 0
    for i=0, math.ceil(numSouls/2)-1 do
        if((blackHearts>>i)%2==0) then numConverted = numConverted+1 end
        player:SetBlackHeart(i*2)
    end

    if(numConverted==0) then player:AddBlackHearts(2) end

    if(isHorse) then
        numConverted = numConverted+1
        player:AddBlackHearts(2)

        local rng = player:GetPillRNG(effect)
        for i=1, numConverted do
            local dir = Vector.FromAngle(rng:RandomInt(360))*60
            player:ThrowFriendlyDip(DipSubType.BLACK, player.Position, player.Position+dir)
        end
    end

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
    player:AnimateHappy()
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_EFFECT.YOUR_SOUL_IS_MINE)