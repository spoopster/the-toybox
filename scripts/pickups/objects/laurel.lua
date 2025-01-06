local mod = MilcomMOD
local sfx = SFXManager()

local INVINCIBILITY_DURATION = 5*30

---@param player EntityPlayer
local function useLaurel(_, _, player, _)
    player:SetColor(Color(1,1,1,1,1,1,1), 10, 1, true, false)
    sfx:Play(SoundEffect.SOUND_LIGHTBOLT_CHARGE)
    sfx:Play(SoundEffect.SOUND_LIGHTBOLT)

    Game():ShakeScreen(10)

    local eff = player:GetEffects()
    local shEff = eff:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS)
    if(shEff) then shEff.Cooldown = shEff.Cooldown+INVINCIBILITY_DURATION
    else
        eff:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, 1)
        eff:GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS).Cooldown = INVINCIBILITY_DURATION
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useLaurel, mod.CONSUMABLE_LAUREL)

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(mod.CONSUMABLE_LAUREL).Weight = 0
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)