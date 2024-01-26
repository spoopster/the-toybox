local mod = MilcomMOD

---@param pickup EntityPickup
---@param player EntityPlayer
local function forceDevilDealPickup(_, pickup, player)
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    player = player:ToPlayer()
    if(mod:atlasHasTransformation(player, mod.MANTLES.TAR)) then return end
    if(not player:IsExtraAnimationFinished()) then return end
    if(not pickup:IsShopItem()) then return end
    if(not (pickup.Price<0 and pickup.Price~=PickupPrice.PRICE_FREE)) then return end

    local price = (pickup.Variant==PickupVariant.PICKUP_COLLECTIBLE and Isaac.GetItemConfig():GetCollectible(pickup.SubType).DevilPrice) or 1

    local data = mod:getAtlasATable(player)

    local rIdx = mod:getRightmostMantleIdx(player)
    local dmgToAdd = 0
    for i=rIdx, (rIdx-price+1) or 1, -1 do
        dmgToAdd = dmgToAdd+data.MANTLES[i].HP
    end

    mod:addMantleHp(player, -dmgToAdd)
    pickup.AutoUpdatePrice = false
    pickup.Price = PickupPrice.PRICE_FREE
    pickup.Visible = false

    return true
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, forceDevilDealPickup)

--! TODO: RENDER ATLAS MANTLE COST INSTEAD OF HEART COST IF ATLAS
