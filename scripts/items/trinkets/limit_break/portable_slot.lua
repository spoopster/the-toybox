local mod = MilcomMOD
--* Lets you switch between Portable Slot and Portable Teller (works like slot but has fortune teller pool)

local tellerOutcomes = {
    ---@param player EntityPlayer
    [0] = function(player) -- FORTUNE
        Game():ShowFortune()

        player:AnimateSad()
    end,
    ---@param player EntityPlayer
    [1] = function(player) -- TRINKET
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local pickup = Isaac.Spawn(5,350,0,pos,Vector.Zero,player):ToPickup()

        player:AnimateCollectible(mod.COLLECTIBLE.PORTABLE_TELLER, "UseItem")
    end,
    ---@param player EntityPlayer
    [2] = function(player) -- SOUL HEART
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local pickup = Isaac.Spawn(5,10,3,pos,Vector.Zero,player):ToPickup()

        player:AnimateCollectible(mod.COLLECTIBLE.PORTABLE_TELLER, "UseItem")
    end,
    ---@param player EntityPlayer
    [3] = function(player) -- CARD
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local pickup = Isaac.Spawn(5,300,0,pos,Vector.Zero,player):ToPickup()

        player:AnimateCollectible(mod.COLLECTIBLE.PORTABLE_TELLER, "UseItem")
    end,
}
local tellerPicker = WeightedOutcomePicker()
tellerPicker:AddOutcomeFloat(0, 67.86, 100)
tellerPicker:AddOutcomeFloat(1, 14.29, 100)
tellerPicker:AddOutcomeFloat(2, 7.14, 100)
tellerPicker:AddOutcomeFloat(3, 10.71, 100)

---@param player EntityPlayer
---@param rng RNG
local function useTeller(_, item, rng, player, flags, slot, vdata)
    if(player:GetNumCoins()>0) then
        local outcome = tellerPicker:PickOutcome(rng)
        tellerOutcomes[outcome](player)

        player:AddCoins(-1)
    end

    return {
        ShowAnim = false,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useTeller, mod.COLLECTIBLE.PORTABLE_TELLER)

---@param player EntityPlayer
local function playerUpdate(_, player)
    if(not mod:playerHasLimitBreak(player)) then
        if(player:HasCollectible(mod.COLLECTIBLE.PORTABLE_TELLER)) then
            for _, slot in pairs(ActiveSlot) do
                if(player:GetActiveItem(slot)==mod.COLLECTIBLE.PORTABLE_TELLER) then
                    player:RemoveCollectible(mod.COLLECTIBLE.PORTABLE_TELLER, true, slot, true)
                    player:AddCollectible(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, 0, false, slot, 0)
                end
            end
        end
        return
    end

    local cid = player.ControllerIndex
    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, cid)) then
        local slotsToCheck = { ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET }
        for _, slot in ipairs(slotsToCheck) do
            local itemInSlot = player:GetActiveItem(slot)
            if(itemInSlot==CollectibleType.COLLECTIBLE_PORTABLE_SLOT or itemInSlot==mod.COLLECTIBLE.PORTABLE_TELLER) then
                local itemToAdd = (itemInSlot==CollectibleType.COLLECTIBLE_PORTABLE_SLOT and mod.COLLECTIBLE.PORTABLE_TELLER or CollectibleType.COLLECTIBLE_PORTABLE_SLOT)
                player:RemoveCollectible(itemInSlot, true, slot, true)
                player:AddCollectible(itemToAdd, 0, false, slot, 0)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, playerUpdate)

--[[] ]
local slotOutcomes = {
    ---@param player EntityPlayer
    [0] = function(player) -- NOTHING
        player:AnimateSad()
    end,
    ---@param player EntityPlayer
    [1] = function(player) -- BOMB
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local pickup = Isaac.Spawn(5,40,0,pos,Vector.Zero,player):ToPickup()

        player:AnimateCollectible(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, "UseItem")
    end,
    ---@param player EntityPlayer
    [2] = function(player) -- KEY
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local pickup = Isaac.Spawn(5,30,0,pos,Vector.Zero,player):ToPickup()

        player:AnimateCollectible(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, "UseItem")
    end,
    ---@param player EntityPlayer
    [3] = function(player) -- HEART
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local pickup = Isaac.Spawn(5,10,0,pos,Vector.Zero,player):ToPickup()

        player:AnimateCollectible(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, "UseItem")
    end,
    ---@param player EntityPlayer
    [4] = function(player) -- PILL
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local pickup = Isaac.Spawn(5,70,0,pos,Vector.Zero,player):ToPickup()

        player:AnimateCollectible(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, "UseItem")
    end,
    ---@param player EntityPlayer
    [5] = function(player) -- 1 COIN
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local pickup = Isaac.Spawn(5,20,0,pos,Vector.Zero,player):ToPickup()

        player:AnimateCollectible(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, "UseItem")
    end,
    ---@param player EntityPlayer
    [6] = function(player) -- 3 COIN
        local room = Game():GetRoom()
        for _=1,2 do
            local pos = room:FindFreePickupSpawnPosition(player.Position, 40)
            local pickup = Isaac.Spawn(5,20,0,pos,Vector.Zero,player):ToPickup()
        end

        player:AnimateCollectible(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, "UseItem")
    end,
    ---@param player EntityPlayer
    [7] = function(player) -- BLACK FLY
        local pos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 40)
        local fly = Isaac.Spawn(13,0,0,pos,Vector.Zero,player):ToPickup()

        player:AnimateSad()
    end,
    ---@param player EntityPlayer
    [8] = function(player) -- PRETTY FLY
        player:AddPrettyFly()
        player:AnimateHappy()
    end,
}
local slotPicker = WeightedOutcomePicker()
slotPicker:AddOutcomeFloat(0, 57.63, 100)
slotPicker:AddOutcomeFloat(1, 4.7, 100)
slotPicker:AddOutcomeFloat(2, 3.1, 100)
slotPicker:AddOutcomeFloat(3, 9.5, 100)
slotPicker:AddOutcomeFloat(4, 4.7, 100)
slotPicker:AddOutcomeFloat(5, 10.5, 100)
slotPicker:AddOutcomeFloat(6, 5.2, 100)
slotPicker:AddOutcomeFloat(7, 3.1, 100)
slotPicker:AddOutcomeFloat(8, 1.57, 100)

---@param player EntityPlayer
---@param rng RNG
local function useSlot(_, item, rng, player, flags, slot, vdata)
    if(not mod:playerHasLimitBreak(player)) then return end

    local outcome = slotPicker:PickOutcome(rng)
    if(outcome==0) then outcome = slotPicker:PickOutcome(rng) end
    slotOutcomes[outcome](player)

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, useSlot, CollectibleType.COLLECTIBLE_PORTABLE_SLOT)
--]]