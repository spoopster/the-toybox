local mod = MilcomMOD
local sfx = SFXManager()

local HORSE_INVINCIBILITY = 7*30

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = mod:getEntityDataTable(player)
    player:UseCard(Card.CARD_HANGED_MAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
    if(isHorse) then
        local eff = player:GetEffects()
        local shEff = eff:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
        if(shEff) then shEff.Cooldown = shEff.Cooldown+HORSE_INVINCIBILITY
        else
            eff:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, 1)
            eff:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS).Cooldown = HORSE_INVINCIBILITY
        end
    end

    player:AnimateHappy()
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
    sfx:Play(SoundEffect.SOUND_POWERUP_SPEWER)
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_I_BELIEVE)