local VALID_BEGGARS = {
    [SlotVariant.BEGGAR] = true,
    [SlotVariant.DEVIL_BEGGAR] = true,
    [SlotVariant.ROTTEN_BEGGAR] = true,
    [SlotVariant.BOMB_BUM] = true,
    [SlotVariant.BATTERY_BUM] = true,
    [SlotVariant.SHELL_GAME] = true,
    [SlotVariant.HELL_GAME] = true,
    [SlotVariant.KEY_MASTER] = true,
}

local FREE_USES = 15

local function tryGiveCard(_, slot, coll, low)
    if(not VALID_BEGGARS[slot.Variant]) then return end

    local player = coll and coll:ToPlayer()
    if(not (player and player:GetCard(0)==ToyboxMod.CARD_FOIL_CARD)) then return end

    if(slot:GetState()==SlotState.IDLE) then
        ToyboxMod:addFreeSlotUses(slot, FREE_USES, player)

        ToyboxMod:setEntityData(slot, "FOIL_CARD_RENDER", true)
        ToyboxMod:setEntityData(slot, "FOIL_CARD_ACTIVE", true)

        for pocketSlot = 0, 3 do
            local pocket = player:GetPocketItem(pocketSlot)
            if(pocket:GetSlot()==ToyboxMod.CARD_FOIL_CARD and pocket:GetType()==PocketItemType.CARD) then
                player:RemovePocketItem(pocketSlot)
                break
            end
        end

        ToyboxMod.SFX:Play(SoundEffect.SOUND_THUMBSUP_AMPLIFIED)

        return true
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, CallbackPriority.EARLY, tryGiveCard)

local function updateFoilCardSlot(_, slot)
    if(not VALID_BEGGARS[slot.Variant]) then return end
    if(not ToyboxMod:getEntityData(slot, "FOIL_CARD_ACTIVE")) then return end

    if((ToyboxMod:getEntityData(slot, "FREE_SLOT_USES") or -1)<0) then
        ToyboxMod:setEntityData(slot, "FOIL_CARD_ACTIVE", nil)
        ToyboxMod:setEntityData(slot, "FOIL_CARD_RENDER", nil)

        return
    end

    if(ToyboxMod:getEntityData(slot, "FOIL_CARD_RENDER")) then
        slot:GetSprite().PlaybackSpeed = 1
    end

    if(slot:GetDonationValue()<3) then
        slot:SetDonationValue(slot:GetDropRNG():RandomInt(3,4))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, updateFoilCardSlot)

local CARD_SPRITE = Sprite("gfx_tb/pickups/card_foil_card.anm2", true)
CARD_SPRITE:Play("HUD", true)

---@param slot EntitySlot
local function postSlotRender(_, slot, offset)
    if(not VALID_BEGGARS[slot.Variant]) then return end
    if(not ToyboxMod:getEntityData(slot, "FOIL_CARD_RENDER")) then return end

    local spr = slot:GetSprite()
    local layer = spr:GetLayer("Coin")
    if(not layer) then return end

    layer:SetVisible(false)

    local frame = spr:GetLayerFrameData(layer:GetLayerID())
    if(frame and frame:IsVisible()) then
        CARD_SPRITE.Scale = frame:GetScale()

        local pos = Isaac.WorldToRenderPosition(slot.Position)+offset
        CARD_SPRITE:Render(pos+frame:GetPos())

        ToyboxMod:setEntityData(slot, "FOIL_CARD_SEEN_VISIBLE_FRAME", true)
    elseif(ToyboxMod:getEntityData(slot, "FOIL_CARD_SEEN_VISIBLE_FRAME")) then
        ToyboxMod:setEntityData(slot, "FOIL_CARD_RENDER", nil)
        ToyboxMod:setEntityData(slot, "FOIL_CARD_SEEN_VISIBLE_FRAME", nil)
        layer:SetVisible(true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_RENDER, postSlotRender)

---@param ent Entity?
---@param hook InputHook
---@param action ButtonAction
local function cancelCardInput(_, ent, hook, action)
    if(hook==InputHook.IS_ACTION_TRIGGERED) then
        if(action==ButtonAction.ACTION_ITEM) then
            local pl = ent and ent:ToPlayer()
            if(pl and ToyboxMod:isAtlasA(pl) or not (pl and pl:GetCard(0)==ToyboxMod.CARD_FOIL_CARD)) then return end

            if(pl:GetPlayerType()==PlayerType.PLAYER_JACOB and Options.JacobEsauControls~=1) then
                if(Input.IsActionPressed(ButtonAction.ACTION_DROP, pl.ControllerIndex)) then
                    return false
                end
            end
        elseif(action==ButtonAction.ACTION_PILLCARD) then
            local pl = ent and ent:ToPlayer()
            if(pl and ToyboxMod:isAtlasA(pl) or not (pl and pl:GetCard(0)==ToyboxMod.CARD_FOIL_CARD)) then return end

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