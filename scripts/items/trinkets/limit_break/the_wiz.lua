local mod = ToyboxMod
--* Reduced spread

local WIZ_ANGLE_MULT = 0.3

---@param player EntityPlayer
local function getWizParams(_, player)
    if(not mod:playerHasLimitBreak(player)) then return end
    player = player:ToPlayer()

    if(player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ)) then
        local weap = player:GetWeapon(1)
        if(not weap) then return end

        local params = player:GetMultiShotParams(weap:GetWeaponType())
        params:SetMultiEyeAngle(params:GetMultiEyeAngle()*WIZ_ANGLE_MULT)
        return params
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, getWizParams)