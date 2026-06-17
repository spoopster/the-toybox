local sfx = SFXManager()
local pickups = {
    PickupVariant.PICKUP_HEART,
    PickupVariant.PICKUP_COIN,
    PickupVariant.PICKUP_KEY,
    PickupVariant.PICKUP_BOMB,
    PickupVariant.PICKUP_TRINKET,
    PickupVariant.PICKUP_PILL,
    PickupVariant.PICKUP_TAROTCARD
}

local ONHIT_TRIGGERS = 3


---@param player EntityPlayer
local function useTammysBody(_, _,_,player,_)
    if (player:GetMaxHearts() == 0) then
        return {
            ShowAnim = false,
            Discharge = false,
            Remove = false,
        }
    end

    player:AddMaxHearts(-2)
    for _=1, ONHIT_TRIGGERS do
        player:TakeDamage(1, DamageFlag.DAMAGE_FAKE, EntityRef(player), 0)
    end

    local room = ToyboxMod.GAME:GetRoom()
    for _, var in ipairs(pickups) do
        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP,var,0,room:FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,nil)
    end

    sfx:Play(SoundEffect.SOUND_VAMP_GULP)

    return true
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useTammysBody, ToyboxMod.COLLECTIBLE_TAMMYS_BODY)