local mod = MilcomMOD
--* Enemies damaged by Magic Fingers have a 7.77% chance to be turned to gold

local MIDAS_CHANCE = 7.77*0.01
local MIDAS_DUR = 30*3

local function postUseItem(_, item, rng, player, flags, slot, vdata)
    if(not mod:playerHasLimitBreak(player)) then return end
    
    for _, enemy in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
        if(enemy:ToNPC() and enemy:IsEnemy() and rng:RandomFloat()<MIDAS_CHANCE) then
            enemy:ToNPC():AddMidasFreeze(EntityRef(player), MIDAS_DUR)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, postUseItem, CollectibleType.COLLECTIBLE_MAGIC_FINGERS)