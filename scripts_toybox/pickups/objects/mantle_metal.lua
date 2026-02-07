
local sfx = SFXManager()

local SOULHEARTS = 2
local CARBATTERY_SOULHEARTS = 4

---@param player EntityPlayer
---@param flags DamageFlag
local function useMantle(_, _, player, flags)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CONGLOMERATE) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.METAL.ID)
    else
        player:AddSoulHearts((flags & UseFlag.USE_CARBATTERY ~= 0) and CARBATTERY_SOULHEARTS or SOULHEARTS)
        local numHearts = math.ceil(player:GetSoulHearts()/2)+player:GetBoneHearts()
        for i=numHearts-1, 0, -1 do
            if(not ((i==numHearts-1 and player:GetSoulHearts()%2~=0) or player:IsBoneHeart(i))) then
                ToyboxMod:setSoulShieldBit(player, i, 1)
            end
        end

        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
        end

        sfx:Play(ToyboxMod.SFX_ATLASA_METALBLOCK)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_METAL)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_METAL] = true end