local mod = MilcomMOD
--im tired of making this
--[[

local function isPolaroidNegative(pickup)
    if(pickup and pickup.Type==5 and pickup.Variant==100 and (pickup.SubType==CollectibleType.COLLECTIBLE_POLAROID or pickup.SubType==CollectibleType.COLLECTIBLE_NEGATIVE)) then
        return true
    end

    return false
end
local function getItemAtPos(pos)
    for _, pickup in ipairs(Isaac.FindByType(5,100)) do
        if(pickup.Position:Distance(pos)<3) then
            return pickup:ToPickup()
        end
    end
end

local function spawnCleanAward(_, rng)
    if(Game():GetRoom():GetType()~=RoomType.ROOM_BOSS) then return end
    mod:setExtraData("PREFERRED_OPTIONS_MARKROOMFORCLEAR", 1)
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, math.huge, spawnCleanAward)

local function spawnNewItem(_)
    if(mod:getExtraData("PREFERRED_OPTIONS_MARKROOMFORCLEAR")~=1) then return end
    mod:setExtraData("PREFERRED_OPTIONS_MARKROOMFORCLEAR", -1)

    local room = Game():GetRoom()
    if(room:GetType()~=RoomType.ROOM_BOSS) then return end

    local centrePos = (room:GetTopLeftPos()+room:GetBottomRightPos())/2

    local centreItem = getItemAtPos(centrePos+Vector(0,80))
    local leftItem = getItemAtPos(centrePos+Vector(-40,80))
    if(isPolaroidNegative(centreItem) or isPolaroidNegative(leftItem)) then return end

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

    if(posToSpawn) then
        local newItem = Isaac.Spawn(5,100,(mod:getExtraData("PREFERRED_OPTIONS_LASTITEM") or CollectibleType.COLLECTIBLE_BREAKFAST),posToSpawn,Vector.Zero,nil):ToPickup()
        newItem.OptionsPickupIndex = pickupIndex
        newItem.Price = (mod:getExtraData("PREFERRED_OPTIONS_LASTPRICE") or 0)

        mod:setExtraData("PREFERRED_OPTIONS_MARKROOMFORCLEAR", 0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, spawnNewItem)

---@param collider Entity
---@param pickup EntityPickup
local function setNewPreferredItem(_, pickup, collider, low)
    collider = collider:ToPlayer()
    if(not collider) then return end
    if(not collider:CanPickupItem()) then return end
    if(not collider:ToPlayer():IsExtraAnimationFinished()) then return end
    if(pickup.Wait>0) then return end
    if(pickup.Touched) then return end
    if(pickup.SubType==0) then return end

    if(not mod:getExtraData("PREFERRED_OPTIONS_MARKROOMFORCLEAR")==0) then return end

    print("Collided w/ item")
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, math.huge, setNewPreferredItem, 100)
--]]