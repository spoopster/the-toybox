local mod = MilcomMOD

---@param player EntityPlayer
local function makePlayerSlippery(_, player)
    if(mod:getPlayerNumFromPlayerEnt(player)==0) then
        player.Friction = 1.3
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, 1e6, makePlayerSlippery)