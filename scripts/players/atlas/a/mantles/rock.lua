local mod = MilcomMOD
local sfx = SFXManager()

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_ROCK] = true
end

local function useMantle(_, _, player, _)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        mod:giveMantle(player, mod.MANTLE_DATA.DEFAULT.ID)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_ROCK)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, playMantleSFX, mod.MANTLE_DATA.DEFAULT.ID)