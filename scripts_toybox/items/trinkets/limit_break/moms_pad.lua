
--* 25% chance for enemy to get perma-feared

local PERMA_CHANCE = 0.25

---@param player EntityPlayer
---@param rng RNG
local function useItem(_, item, rng, player, flags, slot, vdata)
    if(not ToyboxMod:playerHasLimitBreak(player)) then return end

    for _, enemy in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 1000, EntityPartition.ENEMY)) do
        if(enemy:IsEnemy() and rng:RandomFloat()<PERMA_CHANCE) then
            ToyboxMod:setEntityData(enemy, "PERMA_FEARED", player)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useItem, CollectibleType.COLLECTIBLE_MOMS_PAD)

---@param npc EntityNPC
local function postNpcUpdate(_, npc)
    local source = ToyboxMod:getEntityData(npc, "PERMA_FEARED")
    if(source) then
        npc.Color = Color(0.8,0.1,0.8,1,0.1,0,0.1)
        if(npc:GetFearCountdown()<=0) then
            npc:AddEntityFlags(EntityFlag.FLAG_FEAR)
            npc:SetFearCountdown(2^32)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, postNpcUpdate)
