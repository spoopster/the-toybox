local mod = MilcomMOD

local FREE_PICKUP_ID = -12841
local MIN_DRILL_DIST = 60

local PRICE_PER_WAVE = 5

---@param player EntityPlayer
local function gildedAppleUse(_, _, rng, player, flags, slot, vdata)
    if(Game():GetRoom():GetType()==RoomType.ROOM_CHALLENGE) then
        return {
            Discharge = false,
            Remove = false,
            ShowAnim = true,
        }
    end

    local nearestShopPickup
    for _, pickup in ipairs(Isaac.FindByType(5)) do
        pickup = pickup:ToPickup()
        if(pickup:IsShopItem() and pickup.Price~=PickupPrice.PRICE_FREE) then
            if(nearestShopPickup==nil or (nearestShopPickup and pickup.Position:Distance(player.Position)<nearestShopPickup.Position:Distance(player.Position))) then
                nearestShopPickup = pickup
            end
        end
    end

    if(nearestShopPickup and nearestShopPickup.Position:Distance(player.Position)<=MIN_DRILL_DIST) then
        nearestShopPickup = nearestShopPickup:ToPickup()

        local ogPrice = nearestShopPickup.Price
        nearestShopPickup.ShopItemId = FREE_PICKUP_ID

        Ambush.SetMaxChallengeWaves(math.max(1, math.ceil(ogPrice/PRICE_PER_WAVE)))
        mod:setExtraData("DRILLDATA", nil)
        Isaac.ExecuteCommand("goto s.challenge.0")

        mod:setExtraData("DRILLDATA", {
            IS_ACTIVE = 1,
            FORCE_SET_AMBUSH = 1,
            ITEM_ID = nearestShopPickup.SubType,

            IGNORE_RESET_DATA = 1,
        })
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, gildedAppleUse, mod.COLLECTIBLE_DRILL)

local function postUpdate(_)
    local data = mod:getExtraDataTable().DRILLDATA
    if(not data) then return end
    if(data.IS_ACTIVE~=1) then return end

    print(data.IS_ACTIVE, data.FORCE_SET_AMBUSH~=0, data.ITEM_ID, Game():GetRoom():GetType())

    if(data.IGNORE_RESET_DATA~=0) then
        data.IGNORE_RESET_DATA = 0
        mod:setExtraData("DRILLDATA", data)
    elseif(Game():GetRoom():GetType()~=RoomType.ROOM_CHALLENGE) then
        Ambush.SetMaxChallengeWaves(3)
        mod:setExtraData("DRILLDATA", nil)
    end

    if(Game():GetRoom():GetType()~=RoomType.ROOM_CHALLENGE) then
        return
    end

    if(data.FORCE_SET_AMBUSH~=0) then
        data.FORCE_SET_AMBUSH = 0
        Game():GetRoom():SetAmbushDone(false)
    end

    if(Game():GetRoom():IsAmbushDone()) then
        Ambush.SetMaxChallengeWaves(3)
        data.IS_ACTIVE = 0
    elseif(not Game():GetRoom():IsAmbushActive()) then
        Ambush.StartChallenge()
        
        for _, pickup in ipairs(Isaac.FindByType(5)) do
            pickup:Remove()
        end
    end

    mod:setExtraData("DRILLDATA", data)
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local function getFreePickupPrice(_, var, st, id, price)
    if(id==FREE_PICKUP_ID) then return PickupPrice.PRICE_FREE end
end
mod:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, getFreePickupPrice)
--]]