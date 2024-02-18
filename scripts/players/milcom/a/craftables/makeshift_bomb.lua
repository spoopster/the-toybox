local mod = MilcomMOD

local function postPlayerUpdate(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    if(not mod:playerHasCraftable(player, "MAKESHIFT_BOMBS")) then return end


end
--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate)

local function postPlayerUseBomb(_, player, bomb)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    if(not mod:playerHasCraftable(player, "MAKESHIFT_BOMB")) then return end

    
end
--mod:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, postPlayerUseBomb)

---@param player EntityPlayer
---@param bomb EntityBomb
local function onDetonate(_, player, bomb, isIncubus)
    if(player:GetPlayerType()~=mod.PLAYER_MILCOM_A) then return end
    if(not mod:playerHasCraftable(player, "MAKESHIFT_BOMB")) then return end

    --idk do something
end
--mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_PLAYER_BOMB_DETONATE, onDetonate)