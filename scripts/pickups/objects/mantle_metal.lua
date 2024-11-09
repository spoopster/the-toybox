local mod = MilcomMOD
local sfx = SFXManager()

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.METAL.ID)
    else
        player:AddSoulHearts(2)
        local numHearts = math.ceil(player:GetSoulHearts()/2)+player:GetBoneHearts()
        for i=numHearts-1, 0, -1 do
            if(not ((i==numHearts-1 and player:GetSoulHearts()%2~=0) or player:IsBoneHeart(i))) then
                mod:setSoulShieldBit(player, i, 1)
            end
        end

        sfx:Play(mod.SFX_ATLASA_METALBLOCK)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_METAL)

if(mod.ATLAS_A_MANTLESUBTYPES) then mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_METAL] = true end