

--TODO:
--  the "drill" effect in the challenge rooms
--  maybe disable "pre_spawn_clean_award" while the drill is active?
--     this should disable item recharge and item spawns when challenge room is finished
--  make it not timed charge (3 or 4 charges?)
--  add boss challenge room logic for price stuff
--     >25c = boss wave (2 waves + 1 per extra 25c) 
--     if is devil item, boss wave with num waves = devilprice    

---fucking dumb

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

        --
        --nearestShopPickup.ShopItemId = FREE_PICKUP_ID
        local ogPrice = nearestShopPickup.Price
        local spawnData = {nearestShopPickup.Type, nearestShopPickup.Variant, nearestShopPickup.SubType}
        nearestShopPickup:Morph(spawnData[1], spawnData[2], spawnData[3], false, true, false)

        local prevIdx = Game():GetLevel():GetPreviousRoomIndex()
        local ogIdx = Game():GetLevel():GetCurrentRoomIndex()

        Ambush.SetMaxChallengeWaves(math.max(1, math.ceil(ogPrice/PRICE_PER_WAVE)))
        ToyboxMod:setExtraData("DRILLDATA", nil)

        Isaac.ExecuteCommand("goto s.challenge.0")
        Game():StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
        

        ToyboxMod:setExtraData("DRILLDATA", {
            IS_ACTIVE = 1,
            FORCE_SET_AMBUSH = 1,
            ITEM_ID = spawnData,
            OG_IDX = ogIdx,
            PRE_IDX = prevIdx,

            IGNORE_RESET_DATA = 1,
        })
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, gildedAppleUse, ToyboxMod.COLLECTIBLE_DRILL)

local function postUpdate(_)
    local data = ToyboxMod:getExtraDataTable().DRILLDATA
    if(not data) then return end
    if(data.IS_ACTIVE~=1) then return end

    print(data.IS_ACTIVE, data.FORCE_SET_AMBUSH~=0, data.ITEM_ID, Game():GetRoom():GetType())

    if(data.IGNORE_RESET_DATA~=0) then
        data.IGNORE_RESET_DATA = 0
        ToyboxMod:setExtraData("DRILLDATA", data)
    elseif(Game():GetRoom():GetType()~=RoomType.ROOM_CHALLENGE) then
        Ambush.SetMaxChallengeWaves(3)
        ToyboxMod:setExtraData("DRILLDATA", nil)
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
        data.IS_ACTIVE = -1
        Game():StartRoomTransition(data.OG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
        
    elseif(not Game():GetRoom():IsAmbushActive()) then
        Ambush.StartChallenge()
        
        for _, pickup in ipairs(Isaac.FindByType(5)) do
            pickup:Remove()
        end
    end

    ToyboxMod:setExtraData("DRILLDATA", data)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local function preNewRoom(_)
    local data = ToyboxMod:getExtraDataTable().DRILLDATA
    if(not data) then return end

    if(data.IS_ACTIVE==-1) then
        data.IS_ACTIVE = 0

        local curIdx = Game():GetLevel():GetCurrentRoomIndex()
        if(curIdx==data.OG_IDX) then
            Game():ChangeRoom(data.PRE_IDX, -1)
            Game():ChangeRoom(data.OG_IDX)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_NEW_ROOM, preNewRoom)

local function preIdxUpdate(_)
    ToyboxMod:setExtraData("DRILL_PREIDX", Game():GetLevel():GetCurrentRoomIndex())
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, preIdxUpdate)

local function getFreePickupPrice(_, var, st, id, price)
    if(id==FREE_PICKUP_ID) then return PickupPrice.PRICE_FREE end
end
ToyboxMod:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, getFreePickupPrice)
--]]