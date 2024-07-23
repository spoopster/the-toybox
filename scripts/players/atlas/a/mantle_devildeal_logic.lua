local mod = MilcomMOD

local HP_SPRITE = Sprite()
HP_SPRITE:Load("gfx/ui/tb_ui_mantlehearts.anm2", true)
HP_SPRITE:Play("RockMantle", true)

local TRANSF_SPRITE = Sprite()
TRANSF_SPRITE:Load("gfx/ui/tb_ui_mantleicons.anm2", true)
TRANSF_SPRITE.Color = Color(1,1,1,0.75)
TRANSF_SPRITE:Play("RockIcon", true)
TRANSF_SPRITE.Offset = Vector(0,-1)

local PRICE_WIDTH = 12

local function getMantleDealPrice(pickup)
    if(pickup.Variant==PickupVariant.PICKUP_COLLECTIBLE) then return Isaac.GetItemConfig():GetCollectible(pickup.SubType).DevilPrice end
    return 1
end

---@param pickup EntityPickup
---@param player EntityPlayer
local function forceDevilDealPickup(_, pickup, player)
    if(not (player and player:ToPlayer() and mod:isAtlasA(player:ToPlayer()))) then return end
    player = player:ToPlayer()
    if(not player:IsExtraAnimationFinished()) then return end
    if(not pickup:IsShopItem()) then return end
    if(not (pickup.Price<0 and pickup.Price~=PickupPrice.PRICE_FREE)) then return end
    if(pickup.Wait>0) then return end
    if(player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE)) then return end
    if(mod:atlasHasTransformation(player, mod.MANTLE_DATA.TAR.ID)) then return true end

    local price = getMantleDealPrice(pickup)

    local data = mod:getAtlasATable(player)

    local rIdx = mod:getRightmostMantleIdx(player)
    local dmgToAdd = 0
    for i=rIdx, math.max(1,(rIdx-price+1) or 1), -1 do
        dmgToAdd = dmgToAdd+data.MANTLES[i].HP
    end

    mod:addMantleHp(player, -dmgToAdd)
    pickup.AutoUpdatePrice = false
    pickup.Price = PickupPrice.PRICE_FREE
    pickup.Visible = false

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, forceDevilDealPickup)

---@param pickup EntityPickup
local function pickupRenderAtlasPrice(_, pickup, offset)
    if(not mod:isAnyPlayerAtlasA()) then return end
    if(not pickup:IsShopItem()) then return end
    if(not (pickup.Price<0 and pickup.Price~=PickupPrice.PRICE_FREE)) then return end

    local mantlesToRender = getMantleDealPrice(pickup)
    local renderPos = Isaac.WorldToScreen(pickup.Position)+Vector(0,28)

    for i=0, mantlesToRender do
        local o = Vector(PRICE_WIDTH*(i-(mantlesToRender+1)/2)+1,0)

        if(i==0) then
            TRANSF_SPRITE:Render(renderPos+o)
        else
            HP_SPRITE:Render(renderPos+o)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, pickupRenderAtlasPrice, PickupVariant.PICKUP_COLLECTIBLE)
