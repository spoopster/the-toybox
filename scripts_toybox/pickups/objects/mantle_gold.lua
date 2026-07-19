
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

            if(flags & UseFlag.USE_OWNED == UseFlag.USE_OWNED) then
                if(rng:RandomFloat()<1-(flags & UseFlag.USE_CARBATTERY ~= 0 and CARBATTERY_REMOVE_CHANCE or REMOVE_CHANCE)) then
                    player:AddCard(ToyboxMod.CARD_MANTLE_GOLD)
                end
            end

            player:AnimateCard(ToyboxMod.CARD_MANTLE_GOLD, "HideItem")
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_GOLD)

---@param ent Entity?
---@param hook InputHook
---@param action ButtonAction
local function cancelCardInput(_, ent, hook, action)
    if(hook==InputHook.IS_ACTION_TRIGGERED) then
        if(action==ButtonAction.ACTION_ITEM) then
            local pl = ent and ent:ToPlayer()
            if(not (pl and pl:GetCard(0)==ToyboxMod.CARD_MANTLE_GOLD and pl:GetNumCoins()<COINS_REMOVE)) then return end

            if(pl:GetPlayerType()==PlayerType.PLAYER_JACOB and Options.JacobEsauControls~=1) then
                if(Input.IsActionPressed(ButtonAction.ACTION_DROP, pl.ControllerIndex)) then
                    return false
                end
            end
        elseif(action==ButtonAction.ACTION_PILLCARD) then
            local pl = ent and ent:ToPlayer()
            if(not (pl and pl:GetCard(0)==ToyboxMod.CARD_MANTLE_GOLD and pl:GetNumCoins()<COINS_REMOVE)) then return end

            if(pl:GetPlayerType()==PlayerType.PLAYER_ESAU) then
                if(Input.IsActionPressed(ButtonAction.ACTION_DROP, pl.ControllerIndex)) then
                    return false
                end
            else
                return false
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, cancelCardInput)


if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_GOLD] = true end