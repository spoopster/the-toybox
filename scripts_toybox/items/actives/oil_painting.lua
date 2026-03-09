local sfx = SFXManager()

local VALUE_FONT = Font()
VALUE_FONT:Load("font/luaminioutlined.fnt")

local VALUE_ADD_PICKER = WeightedOutcomePicker()
VALUE_ADD_PICKER:AddOutcomeWeight(0, 1)
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

local priceSprite = Sprite("gfx_tb/ui/ui_active_price.anm2", true)
priceSprite:Play("Basic", true)

---@param player EntityPlayer
local function renderPaintingValue(_, player, slot, offset, a, scale)
    local price = math.min(player:GetActiveItemDesc(slot).VarData, player:GetMaxCoins())
    local priceSize = math.max(1, math.ceil(math.log(price+1, 10)))
    local priceDigitSize = Vector(4,0)*scale
    local pricePos = offset+Vector(20,22)*scale+priceSize*priceDigitSize

    priceSprite.Scale = Vector(scale,scale)

    priceSprite:SetFrame(10)
    priceSprite:Render(pricePos)
    for _=1, priceSize do
        pricePos = pricePos-priceDigitSize

        priceSprite:SetFrame(price%10)
        priceSprite:Render(pricePos)

        price = price//10
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderPaintingValue, ToyboxMod.COLLECTIBLE_OIL_PAINTING)