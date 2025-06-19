
local sfx = SFXManager()

local ENEMY_DAMAGE = 30

local function useYanny(_, _, player, _)
    local uhesdlfkjsdjsdjfdf = Isaac.Spawn(1000,16,1,player.Position,Vector.Zero,player):ToEffect()
    uhesdlfkjsdjsdjfdf.Color = Color(0.5,0.2,0.2,1)

    sfx:Play(SoundEffect.SOUND_DEATH_CARD)

    Game():ShakeScreen(10)

    for _, enemy in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 2000, EntityPartition.ENEMY)) do
        enemy:TakeDamage(ENEMY_DAMAGE, 0, EntityRef(player), 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useYanny, ToyboxMod.CONSUMABLE.YANNY)

local function postYannyInit(_, pickup)
    if(pickup.SubType==ToyboxMod.CONSUMABLE.YANNY) then
        ToyboxMod:setPersistentData("HAS_SEEN_YANNY", 1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postYannyInit, PickupVariant.PICKUP_TAROTCARD)

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(ToyboxMod.CONSUMABLE.YANNY).Weight = 0
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)