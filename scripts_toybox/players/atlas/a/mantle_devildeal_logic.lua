

local HP_SPRITE = Sprite()
HP_SPRITE:Load("gfx/ui/tb_ui_mantlehearts.anm2", true)
HP_SPRITE:Play("RockMantle", true)

local TRANSF_SPRITE = Sprite()
TRANSF_SPRITE:Load("gfx/ui/tb_ui_mantleicons.anm2", true)
TRANSF_SPRITE.Color = Color(1,1,1,0.75)
TRANSF_SPRITE:Play("RockIcon", true)
TRANSF_SPRITE.Offset = Vector(0,-1)

local PRICE_WIDTH = 12

local PICKUP_PRICE_TO_MANTLE_PRICE = {
    [PickupPrice.PRICE_TWO_HEARTS] = 2,
    [PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS] = 2,
    [PickupPrice.PRICE_SPIKES] = 0,
    [PickupPrice.PRICE_SOUL] = 0,
    [PickupPrice.PRICE_FREE] = 0,
}

---@param pickup EntityPickup
local function pickupRenderAtlasPrice(_, pickup, offset)
    if(not ToyboxMod:isAnyPlayerAtlasA()) then return end
    if(not pickup:IsShopItem()) then return end
    if(pickup.Price>=0) then return end

    local mantlePrice = PICKUP_PRICE_TO_MANTLE_PRICE[pickup.Price] or 1
    if(mantlePrice<=0) then return end

    local renderPos = Isaac.WorldToScreen(pickup.Position)+Vector(0,28)
    for i=0, mantlePrice do
        local o = Vector(PRICE_WIDTH*(i-(mantlePrice+1)/2)+1,0)

        if(i==0) then
            TRANSF_SPRITE:Render(renderPos+o)
        else
            HP_SPRITE:Render(renderPos+o)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, pickupRenderAtlasPrice, PickupVariant.PICKUP_COLLECTIBLE)

---@param pl EntityPlayer
local function removeMantlePrice(_, pickup, pl, price)
    if(not (pl and pl:ToPlayer() and ToyboxMod:isAtlasA(pl:ToPlayer()))) then return end
    if(pl:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE)) then return end
    if(price>=0) then return end

    local mantlePrice = PICKUP_PRICE_TO_MANTLE_PRICE[price] or 1
    if(mantlePrice<=0) then return end

    if(ToyboxMod:atlasHasTransformation(pl, ToyboxMod.MANTLE_DATA.TAR.ID)) then
        ToyboxMod:setAtlasAData(pl, "MARKED_FOR_DEATH_DEVILDEAL", 1)

        return
    end

    local data = ToyboxMod:getAtlasATable(pl)
    local rIdx = ToyboxMod:getRightmostMantleIdx(pl)
    local dmgToAdd = 0
    for i=rIdx, math.max(1,(rIdx-mantlePrice+1) or 1), -1 do
        dmgToAdd = dmgToAdd+data.MANTLES[i].HP
    end

    ToyboxMod:addMantleHp(pl, -dmgToAdd)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, removeMantlePrice)

---@param pl EntityPlayer
local function killMarkedForDeathTar(_, pl)
    if(not ToyboxMod:isAtlasA(pl)) then return end

    if(ToyboxMod:getAtlasAData(pl, "MARKED_FOR_DEATH_DEVILDEAL")==1) then
        if(ToyboxMod:atlasHasTransformation(pl, ToyboxMod.MANTLE_DATA.TAR.ID)) then
            if(not pl.QueuedItem.Item) then
                pl:PlayExtraAnimation("Death")
                pl:Kill()
                ToyboxMod:setAtlasAData(pl, "MARKED_FOR_DEATH_DEVILDEAL", 0)
            end
        else
            ToyboxMod:setAtlasAData(pl, "MARKED_FOR_DEATH_DEVILDEAL", 0)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, killMarkedForDeathTar)