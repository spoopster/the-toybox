
local sfx = SFXManager()

local COINS_REMOVE = 1
local REMOVE_CHANCE = 0.05

local function useMantle(_, _, player, _)
    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.GOLD.ID)
    else
        local rng = player:GetCardRNG(ToyboxMod.CONSUMABLE.MANTLE_GOLD)

        if(player:GetNumCoins()>=COINS_REMOVE) then
            sfx:Play(SoundEffect.SOUND_CASH_REGISTER)

            player:AddCoins(-COINS_REMOVE)
            local dir = Vector.FromAngle(rng:RandomInt(0,360)):Resized(4)
            local pickup = Isaac.Spawn(5,0,NullPickupSubType.NO_COLLECTIBLE,player.Position,dir,player)

            if(rng:RandomFloat()<1-REMOVE_CHANCE) then
                player:SetCard(1, player:GetCard(0))
                player:SetCard(0, ToyboxMod.CONSUMABLE.MANTLE_GOLD)
            end
        else
            sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)

            player:SetCard(1, player:GetCard(0))
            player:SetCard(0, ToyboxMod.CONSUMABLE.MANTLE_GOLD)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CONSUMABLE.MANTLE_GOLD)



if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CONSUMABLE.MANTLE_GOLD] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(ToyboxMod.CONSUMABLE.MANTLE_GOLD).Weight = (ToyboxMod.CONFIG.MANTLE_WEIGHT or 0.5)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)