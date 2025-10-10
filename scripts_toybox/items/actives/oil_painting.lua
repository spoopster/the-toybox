local sfx = SFXManager()

local VALUE_FONT = Font()
VALUE_FONT:Load("font/luaminioutlined.fnt")

local VALUE_ADD_PICKER = WeightedOutcomePicker()
VALUE_ADD_PICKER:AddOutcomeWeight(1, 1)
VALUE_ADD_PICKER:AddOutcomeWeight(2, 1)
VALUE_ADD_PICKER:AddOutcomeWeight(3, 1)
VALUE_ADD_PICKER:AddOutcomeWeight(4, 1)

---@param player EntityPlayer
---@param rng RNG
---@param slot ActiveSlot
local function useOilPainting(_, _, rng, player, _, slot, vdata)
    local value = vdata
    if(slot~=-1 and player:GetActiveItem(slot)==ToyboxMod.COLLECTIBLE_OIL_PAINTING) then
        value = math.min(player:GetActiveItemDesc(slot).VarData, player:GetMaxCoins())
    end

    player:AddCoins(value)

    sfx:Play(SoundEffect.SOUND_CASH_REGISTER)

    return {
        Discharge = true,
        Remove = true,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useOilPainting, ToyboxMod.COLLECTIBLE_OIL_PAINTING)

local function increasePaintingValue(_)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_OIL_PAINTING)
        for _, slot in pairs(ActiveSlot) do
            local data = pl:GetActiveItemDesc(slot)
            if(data.Item==ToyboxMod.COLLECTIBLE_OIL_PAINTING) then
                data.VarData = data.VarData+VALUE_ADD_PICKER:PickOutcome(rng)
            end
        end
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ROOM_CLEAR, increasePaintingValue)

---@param pl EntityPlayer
---@param slot ActiveSlot
---@param offset Vector
local function renderPaintingValue(_, pl, slot, offset, alpha, scale, chargebaroffset)
    if(pl:GetActiveItem(slot)~=ToyboxMod.COLLECTIBLE_OIL_PAINTING) then return end
    --if(slot~=ActiveSlot.SLOT_PRIMARY) then return end

    local val = math.min(pl:GetActiveItemDesc(slot).VarData, pl:GetMaxCoins())
    local str = "+"..tostring(val)
    local rpos = offset+Vector(24,18)*scale
    local boxwidth = 30

    VALUE_FONT:DrawStringScaled(str, rpos.X-boxwidth, rpos.Y, scale, scale, KColor(1,1,1,alpha), boxwidth*2, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderPaintingValue)