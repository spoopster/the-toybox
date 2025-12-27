
local sfx = SFXManager()

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.METAL.ID)
    else
        player:AddSoulHearts(2)
        local numHearts = math.ceil(player:GetSoulHearts()/2)+player:GetBoneHearts()
        for i=numHearts-1, 0, -1 do
            if(not ((i==numHearts-1 and player:GetSoulHearts()%2~=0) or player:IsBoneHeart(i))) then
                ToyboxMod:setSoulShieldBit(player, i, 1)
            end
        end

        sfx:Play(ToyboxMod.SFX_ATLASA_METALBLOCK)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_METAL)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_METAL] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(ToyboxMod.CARD_MANTLE_METAL).Weight = (ToyboxMod.CONFIG.MANTLE_WEIGHT or 0.5)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)