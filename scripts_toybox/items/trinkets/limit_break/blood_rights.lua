local mod = ToyboxMod
--* Enemies killed by Blood Rights have a 10% chance to spawn a half red heart

local HEART_CHANCE = 10*0.01

local function postUseItem(_, item, rng, player, flags, slot, vdata)
    if(not mod:playerHasLimitBreak(player)) then return end
    
    for _, enemy in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
        if(enemy:IsEnemy() and enemy:HasMortalDamage() and rng:RandomFloat()<HEART_CHANCE) then
            local heart = Isaac.Spawn(5,10,2,Game():GetRoom():FindFreePickupSpawnPosition(enemy.Position),Vector.Zero,player):ToPickup()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, postUseItem, CollectibleType.COLLECTIBLE_BLOOD_RIGHTS)