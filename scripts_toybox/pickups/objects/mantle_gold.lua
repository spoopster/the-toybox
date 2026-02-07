
local sfx = SFXManager()

local COINS_REMOVE = 1
local REMOVE_CHANCE = 0.1--0.05

local CARBATTERY_REMOVE_CHANCE = 0.05

---@param player EntityPlayer
---@param flags UseFlag
local function useMantle(_, _, player, flags)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CONGLOMERATE) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.GOLD.ID)
    else
        local rng = player:GetCardRNG(ToyboxMod.CARD_MANTLE_GOLD)

        if(player:GetNumCoins()>=COINS_REMOVE) then
            sfx:Play(SoundEffect.SOUND_CASH_REGISTER)

            player:AddCoins(-COINS_REMOVE)
            local dir = Vector.FromAngle(rng:RandomInt(0,360)):Resized(4)
            local pickup = Isaac.Spawn(5,0,NullPickupSubType.NO_COLLECTIBLE,player.Position,dir,player)

            if(rng:RandomFloat()<1-(flags & UseFlag.USE_CARBATTERY ~= 0 and CARBATTERY_REMOVE_CHANCE or REMOVE_CHANCE)) then
                player:SetCard(1, player:GetCard(0))
                player:SetCard(0, ToyboxMod.CARD_MANTLE_GOLD)
            end

            player:AnimateCard(ToyboxMod.CARD_MANTLE_GOLD, "HideItem")
        else
            sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)

            player:SetCard(1, player:GetCard(0))
            player:SetCard(0, ToyboxMod.CARD_MANTLE_GOLD)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_GOLD)



if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_GOLD] = true end