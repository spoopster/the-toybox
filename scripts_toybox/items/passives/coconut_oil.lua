local ENUM_FRICTION_BONUS = 0.085

---@param player EntityPlayer
local function makePlayerSlippery(_, player)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_COCONUT_OIL)) then
        player.Friction = player.Friction + math.min(ENUM_FRICTION_BONUS/player.MoveSpeed, 0.1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, makePlayerSlippery)