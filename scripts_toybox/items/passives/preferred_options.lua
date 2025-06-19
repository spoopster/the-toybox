
--im tired of making this

local function getItemAtPos(pos)
    for _, pickup in ipairs(Isaac.FindByType(5,100)) do
        if(pickup.Position:Distance(pos)<3) then
            return pickup:ToPickup()
        end
    end
end

local function markRoomAsDone(_, rng)
    if(Game():GetRoom():GetType()~=RoomType.ROOM_BOSS) then return end
    ToyboxMod:setExtraData("PREFERRED_OPTIONS_MARKROOMFORCLEAR", 1)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, math.huge, markRoomAsDone)

local function spawnNewItem(_)
    if(ToyboxMod:getExtraData("PREFERRED_OPTIONS_MARKROOMFORCLEAR")~=1) then return end
    ToyboxMod:setExtraData("PREFERRED_OPTIONS_MARKROOMFORCLEAR", 0)

    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_PREFERRED_OPTIONS)) then return end

    local room = Game():GetRoom()
    if(room:GetType()~=RoomType.ROOM_BOSS) then return end

    local centrePos = (room:GetTopLeftPos()+room:GetBottomRightPos())/2
    local centreItem = getItemAtPos(centrePos+Vector(0,80))
    local leftItem = getItemAtPos(centrePos+Vector(-40,80))

    if(not (centreItem or leftItem)) then return end

    local posToSpawn, pickupIndex
    if(centreItem) then
        centreItem.Position = centrePos+Vector(-40,80)
        posToSpawn = centrePos+Vector(40,80)

        if(centreItem.OptionsPickupIndex==0) then centreItem:SetNewOptionsPickupIndex() end
        pickupIndex = centreItem.OptionsPickupIndex
    elseif(leftItem) then
        posToSpawn = centrePos+Vector(0,80)
        pickupIndex = leftItem.OptionsPickupIndex
    end

    local newItem = Isaac.Spawn(5,100,(ToyboxMod:getExtraData("PREFERRED_OPTIONS_LASTITEM") or CollectibleType.COLLECTIBLE_BREAKFAST),posToSpawn,Vector.Zero,nil):ToPickup()
    newItem.OptionsPickupIndex = pickupIndex
    newItem.Price = (ToyboxMod:getExtraData("PREFERRED_OPTIONS_LASTPRICE") or 0)
    if(newItem.Price<0) then
        newItem.ShopItemId = -2
    end

    newItem:GetSprite():GetLayer("head"):SetCustomShader("spriteshaders/hologramshader")
    ToyboxMod:setEntityData(newItem, "PREFERREDOPTIONS_HOLOGRAM", 1)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, spawnNewItem)

---@param pickup EntityPickup
local function updateHologramVisual(_, pickup)
    if(not ToyboxMod:getEntityData(pickup, "PREFERREDOPTIONS_HOLOGRAM")) then return end

    local scaledFramec = pickup.FrameCount/30
    local layer = pickup:GetSprite():GetLayer("head")
    local ogColor = layer:GetColor()
    ogColor:SetColorize(scaledFramec,0,0,0)

    layer:SetColor(ogColor)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, updateHologramVisual, PickupVariant.PICKUP_COLLECTIBLE)

-- UPDATING PREFERRED ITEM 

local function setNewPrefferedItem(id, price)
    if(Game():GetRoom():GetType()~=RoomType.ROOM_BOSS) then return end
    local conf = Isaac.GetItemConfig():GetCollectible(id)
    if(not conf) then return end
    if(conf.Hidden or conf:HasTags(ItemConfig.TAG_QUEST)) then return end

    --print("New preferred item:", id, price)

    ToyboxMod:setExtraData("PREFERRED_OPTIONS_LASTITEM", id)
    ToyboxMod:setExtraData("PREFERRED_OPTIONS_LASTPRICE", price)
end

---@param collider Entity
---@param pickup EntityPickup
local function preferFreePickup(_, pickup, collider, low)
    collider = collider:ToPlayer()
    if(pickup.Price~=0) then return end
    if(not collider) then return end
    if(not collider:CanPickupItem()) then return end
    if(not collider:ToPlayer():IsExtraAnimationFinished()) then return end
    if(pickup.Wait>0) then return end
    if(pickup.Touched) then return end
    if(pickup.SubType==0) then return end

    setNewPrefferedItem(pickup.SubType, pickup.Price)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, math.huge, preferFreePickup, 100)

---@param pl EntityPlayer
local function preferShopPickup(_, pickup, pl, price)
    setNewPrefferedItem(pl.QueuedItem.Item.ID, price)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, preferShopPickup, 100)