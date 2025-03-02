local mod = MilcomMOD
--* On room clear, chance to spawn Micro Battery if active item is not fully charged

local BATTERY_CHANCE = 0.25

---@param player EntityPlayer
local function trySpawnMicroBattery(_, player)
    if(not mod:playerHasLimitBreak(player)) then return end
    if(not player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY_PACK)) then return end

    local numUnchargedActives = 0
    for _, slot in pairs(ActiveSlot) do
        local item = player:GetActiveItem(slot)
        if(item~=0) then
            --print(player:GetActiveCharge(), Isaac.GetItemConfig():GetCollectible(item).MaxCharges)
            numUnchargedActives = numUnchargedActives+(player:GetActiveCharge(slot)<Isaac.GetItemConfig():GetCollectible(item).MaxCharges and 1 or 0)
        end
    end

    if(numUnchargedActives>0 and player:GetTrinketRNG(mod.TRINKET.LIMIT_BREAK):RandomFloat()<BATTERY_CHANCE*numUnchargedActives) then
        local battery = Isaac.Spawn(5,90,2,Game():GetRoom():FindFreePickupSpawnPosition(player.Position,40),Vector.Zero,player):ToPickup()
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, trySpawnMicroBattery)