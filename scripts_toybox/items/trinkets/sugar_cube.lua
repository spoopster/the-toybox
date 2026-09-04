local RED_HEAL = 2
local SOUL_HEAL = 1

local MULT_HEAL = 1

local function healOnUse(_, _, player, flags)
    if(not player:HasTrinket(ToyboxMod.TRINKET_SUGAR_CUBE)) then return end

    if(flags & UseFlag.USE_OWNED == UseFlag.USE_OWNED) then
        local fullHp = (player:GetHearts()>=player:GetEffectiveMaxHearts())

        local heal = (fullHp and SOUL_HEAL or RED_HEAL)+MULT_HEAL*(player:GetTrinketMultiplier(ToyboxMod.TRINKET_SUGAR_CUBE)-1)

        if(fullHp) then
            player:AddSoulHearts(heal)
        else
            player:AddHearts(heal)
        end

        local sub = (fullHp and 4 or 0)
        local notif = Isaac.Spawn(1000, EffectVariant.HEART, sub, player.Position, Vector.Zero, player):ToEffect()
        notif:FollowParent(player)
        notif.SpriteOffset = Vector(0, -40)

        ToyboxMod.SFX:Play(SoundEffect.SOUND_VAMP_GULP)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_USE_CARD, CallbackPriority.LATE+1, healOnUse)