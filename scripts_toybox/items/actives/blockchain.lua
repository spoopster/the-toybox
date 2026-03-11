local sfx = SFXManager()

local BASE_PRICE = 1
local PRICE_INCREMENT = 1
local PRICE_INCREMENT_FREQ = 10

---@param pl EntityPlayer
---@param slot ActiveSlot
local function getBlockchainPrice(pl, slot)
    if(slot==-1) then
        return BASE_PRICE
    end
    if(pl:GetActiveItem(slot)~=ToyboxMod.COLLECTIBLE_BLOCKCHAIN) then
        return BASE_PRICE
    end

    return BASE_PRICE+(pl:GetActiveItemDesc(slot).VarData//PRICE_INCREMENT_FREQ)*PRICE_INCREMENT
end

---@param pl EntityPlayer
---@param slot ActiveSlot
local function useBlockchain(_, _, rng, pl, flags, slot)
    local price = getBlockchainPrice(pl, slot)
    if(pl:GetNumCoins()>=price) then
        pl:AddCoins(-price)

        local dir = Vector.FromAngle(rng:RandomInt(0,360)):Resized(4)
        local pickup = Isaac.Spawn(5,0,NullPickupSubType.NO_COLLECTIBLE,pl.Position,dir,pl):ToPickup()

        local upgradeSfx = false

        if(slot~=-1) then
            pl:SetActiveVarData(pl:GetActiveItemDesc(slot).VarData+1, slot)
            if(pl:GetActiveItemDesc(slot).VarData%PRICE_INCREMENT_FREQ==0) then
                upgradeSfx = true
            end
        end

        sfx:Play((upgradeSfx and ToyboxMod.SFX_RETRO_UPGRADE or ToyboxMod.SFX_RETRO_COIN), 1, 2, false, 0.95+math.random()*0.1)

        return {
            Discharge = true,
            Remove = false,
            ShowAnim = true,
        }
    else
        sfx:Play(ToyboxMod.SFX_RETRO_FAIL, 1, 2, false, 0.95+math.random()*0.1)

        return {
            Discharge = false,
            Remove = false,
            ShowAnim = false,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useBlockchain, ToyboxMod.COLLECTIBLE_BLOCKCHAIN)

local itemSprite = Sprite("gfx_tb/ui/custom_active_renders.anm2", false)
itemSprite:Play("ActiveSilhouette", true)
local itemGfxPath = Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_BLOCKCHAIN).GfxFileName
for i=0, 5 do
    itemSprite:ReplaceSpritesheet(i, itemGfxPath, false)
end
itemSprite:LoadGraphics()

local priceSprite = Sprite("gfx_tb/ui/ui_active_price.anm2", true)
priceSprite:Play("Blockchain", true)

---@param player EntityPlayer
local function renderUnder(_, player, slot, offset, a, scale)
    if(player:GetNumCoins()>=getBlockchainPrice(player, slot)) then
        return {
            HideItem = true,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, renderUnder, ToyboxMod.COLLECTIBLE_BLOCKCHAIN)

---@param player EntityPlayer
local function renderOver(_, player, slot, offset, a, scale)
    local price = getBlockchainPrice(player, slot)
    if(player:GetNumCoins()>=price) then
        itemSprite.Color = Color(1,1,1,a)
        itemSprite.Scale = Vector(scale, scale)
        itemSprite:Render(offset+Vector(16,16)*scale)
    end

    local priceSize = math.max(1, math.ceil(math.log(price+1, 10)))
    local priceDigitSize = Vector(4,0)*scale
    local pricePos = offset+Vector(20,20)*scale+priceSize*priceDigitSize

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
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderOver, ToyboxMod.COLLECTIBLE_BLOCKCHAIN)