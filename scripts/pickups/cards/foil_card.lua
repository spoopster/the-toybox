local mod = MilcomMOD
local sfx = SFXManager()

local INCREMENT_CHANCE = 0.5
local COINS_PER_VALUE = 3

---@param pickup EntityPickup
local function foilCardInit(_, pickup)
    if(pickup.SubType~=mod.CARD_FOIL_CARD) then return end

    local sp = pickup:GetSprite()
    sp:SetRenderFlags(AnimRenderFlags.GOLDEN)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, foilCardInit, PickupVariant.PICKUP_TAROTCARD)

---@param pl EntityPlayer
local function usePrismstone(_, _, pl, _)
    local val = (mod:getExtraData("FOILCARD_VALUE") or 0)

    if(val>0) then
        pl:AddCoins(val*COINS_PER_VALUE)
        mod:setExtraData("FOILCARD_VALUE", 0)

        sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, usePrismstone, mod.CARD_FOIL_CARD)

local function incrementFoilCardCounter()
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        for _, slot in pairs(PillCardSlot) do
            if(pl:GetCard(slot)==mod.CARD_FOIL_CARD) then
                if(pl:GetCardRNG(mod.CARD_FOIL_CARD):RandomFloat()<INCREMENT_CHANCE) then
                    mod:setExtraData("FOILCARD_VALUE", (mod:getExtraData("FOILCARD_VALUE") or 0)+1)
                end
            end
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ROOM_CLEAR, incrementFoilCardCounter)

--[[
local function postHudRender(_)
    if(not Game():GetHUD():IsVisible()) then return end

    Isaac.RenderText(tostring((mod:getExtraData("FOILCARD_VALUE") or 0)), 100, 100, 1,1,1,1)
end
mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postHudRender)
--]]