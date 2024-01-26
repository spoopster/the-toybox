local mod = MilcomMOD
local sfx = SFXManager()

mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_ROCK] = true

local function useMantle(_, _, player, _)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        mod:giveMantle(player, mod.MANTLES.DEFAULT)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_ROCK)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK)
end
mod:AddCallback("ATLAS_POST_LOSE_MANTLE", playMantleSFX, mod.MANTLES.DEFAULT)