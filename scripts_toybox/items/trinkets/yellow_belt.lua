local BLOCK_CHANCE = 0.1
local BLOCK_IFRAMES = 30*1.5

---@param pl EntityPlayer
local function tryCancelDamage(_, pl, damage, flags, source, count)
    if(not pl:HasTrinket(ToyboxMod.TRINKET_YELLOW_BELT)) then return end

    local chance = BLOCK_CHANCE*pl:GetTrinketMultiplier(ToyboxMod.TRINKET_YELLOW_BELT)

    if(pl:GetTrinketRNG(ToyboxMod.TRINKET_YELLOW_BELT):RandomFloat()<chance) then
        pl:SetColor(Color(1,1,1,1,0.3,0.3,0,0,0,0,0), BLOCK_IFRAMES, 0, true, false)
        pl:SetMinDamageCooldown(BLOCK_IFRAMES*(pl:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE)+1))

        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, tryCancelDamage, 0)