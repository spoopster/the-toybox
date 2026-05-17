local VALID_ROOMTYPES = {
    [RoomType.ROOM_TREASURE] = true,
    [RoomType.ROOM_SHOP] = true,
    --[RoomType.ROOM_SECRET] = true, -- nah thats wack
    [RoomType.ROOM_ANGEL] = true,
    [RoomType.ROOM_DEVIL] = true,
}

local function resetCabanData(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_CABAN_EARTH)) then return end

    ToyboxMod:setExtraData("CABAN_ITEMINDEXES" , {})
    ToyboxMod:setExtraData("CABAN_COLLECTED_NUM", 0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, resetCabanData)

local function trySpawnCabanItem(_)
    local room = Game():GetRoom()
    if(not VALID_ROOMTYPES[room:GetType()]) then return end

    local anyoneHasCaban = PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_CABAN_EARTH)

    local data = ToyboxMod:getExtraDataTable()
    local idx = Game():GetLevel():GetCurrentRoomIndex()
    if(anyoneHasCaban and not (data.CABAN_ITEMINDEXES and data.CABAN_ITEMINDEXES[tostring(idx)])) then
        local pool = Game():GetItemPool()
        local pl = PlayerManager.GetRandomCollectibleOwner(ToyboxMod.COLLECTIBLE_CABAN_EARTH, ToyboxMod:generateRng(room:GetAwardSeed()):Next())
        local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CABAN_EARTH)
        local id = pool:GetCollectible(room:GetItemPool(math.max(1,rng:Next())), true, math.max(1, rng:Next()))

        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
        local posIdx = room:GetGridIndex(pos)

        data.CABAN_ITEMINDEXES = data.CABAN_ITEMINDEXES or {}
        data.CABAN_ITEMINDEXES[tostring(idx)] = posIdx

        local pickup = Isaac.Spawn(5,100,id,pos,Vector.Zero,nil):ToPickup()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, trySpawnCabanItem)

---@param pickup EntityPickup
local function postCabanPickupInit(_, pickup)
    local room = Game():GetRoom()
    local idx = Game():GetLevel():GetCurrentRoomIndex()

    local data = ToyboxMod:getExtraDataTable()
    if(not (data.CABAN_ITEMINDEXES and data.CABAN_ITEMINDEXES[tostring(idx)])) then return end

    local posIdx = data.CABAN_ITEMINDEXES[tostring(idx)]
    if(room:GetGridIndex(pickup.Position)~=posIdx or pickup.Position:Distance(room:GetGridPosition(posIdx))>10) then return end

    local tryInvalidate = false
    if((data.CABAN_COLLECTED_NUM or 0)>=PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_CABAN_EARTH)) then
        tryInvalidate = true
    end

    local sp = pickup:GetSprite()

    pickup:SetAlternatePedestal(PedestalType.DEFAULT)
    sp:ReplaceSpritesheet(5, "gfx_tb/pickups/pickup_caban_altar.png", true)

    if(tryInvalidate and not pickup.Touched) then
        sp:GetLayer("head"):SetCustomShader("spriteshaders/earthshader")
        sp:Stop()
        sp:SetFrame(0)

        local col = pickup.Color
        col:SetColorize(math.random(),0,0,0)
        pickup.Color = col
        ToyboxMod:setEntityData(pickup, "CABAN_INVALID_ITEM", true)
        pickup.Wait = 100
    end
    ToyboxMod:setEntityData(pickup, "CABAN_ITEM", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postCabanPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function postCabanPickupUpdate(_, pickup)
    if(ToyboxMod:getEntityData(pickup, "CABAN_INVALID_ITEM")) then
        pickup:GetSprite():Stop()
        pickup:GetSprite():SetFrame(0)
        pickup.Wait = 100
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postCabanPickupUpdate, PickupVariant.PICKUP_COLLECTIBLE)

local iHateCoding = {}

---@param pickup EntityPickup
---@param coll Entity
local function preCabanColl(_, pickup, coll)
    if(ToyboxMod:getEntityData(pickup, "CABAN_INVALID_ITEM")) then return end
    if(not ToyboxMod:getEntityData(pickup, "CABAN_ITEM")) then return end

    if(coll and coll:ToPlayer()) then
        iHateCoding[tostring(pickup.InitSeed)] = {
            pickup.SubType,
            pickup.Touched,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preCabanColl, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param coll Entity
local function postCabanColl(_, pickup, coll)
    if(ToyboxMod:getEntityData(pickup, "CABAN_INVALID_ITEM")) then return end
    if(not ToyboxMod:getEntityData(pickup, "CABAN_ITEM")) then return end

    if(coll and coll:ToPlayer()) then
        local dat = iHateCoding[tostring(pickup.InitSeed)]

        dat[1] = dat[1] or -1
        if(dat and dat[1] and pickup.SubType~=dat[1] and not dat[2]) then
            local data = ToyboxMod:getExtraDataTable()
            data.CABAN_COLLECTED_NUM = (data.CABAN_COLLECTED_NUM or 0)+1
        end
    end

    iHateCoding[tostring(pickup.InitSeed)] = nil
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, postCabanColl, PickupVariant.PICKUP_COLLECTIBLE)

local function resetmango(_)
    iHateCoding = {}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, resetmango)