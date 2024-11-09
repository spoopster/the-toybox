local mod = MilcomMOD

local FREE_PICKUP_ID = -12841
local MIN_DRILL_DIST = 60
local FRAME_COOLDOWN = 15
local WAVE_NUM = 3
local WAVE_DIFFICULTY_UPGRADES = {
    [1] = 0,
    [2] = 0,
}

local NEXT_DIFF = {
    [1] = 5,
    [5] = 10,
    [10] = 15,
    [15] = 15,
}

---@param player EntityPlayer
local function gildedAppleUse(_, _, rng, player, flags, slot, vdata)
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
        mod:setExtraData("DRILLDATA", {
            IS_ACTIVE = 1,
            STORED_ID = nearestShopPickup:ToPickup().ShopItemId,
            NEXT_LAYOUT = {},
            CURRENT_LAYOUT_ENEMIES = {},
            CUR_WAVE = 1,
            MAX_WAVES = WAVE_NUM,
            CURR_DIFFICULTY = (Game().Difficulty==Difficulty.DIFFICULTY_HARD or Game().Difficulty==Difficulty.DIFFICULTY_GREEDIER) and 5 or 1,
            RESTART_CURRENT_WAVE = false,
            IS_BOSS_CHALLENGE = false,
            PREV_ROOM_IDX = Game():GetLevel():GetCurrentRoomIndex(),
            WAVE_COOLDOWN = FRAME_COOLDOWN,
        })
        Isaac.ExecuteCommand("goto s.default.2")
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, gildedAppleUse, mod.COLLECTIBLE_DRILL)

local function spawnWave()
    local data = mod:getExtraDataTable().DRILLDATA
    if(not data) then return end
    if(data.IS_ACTIVE~=1) then return end
    --print(StageAPI.CurrentStage)
    if(not (StageAPI.CurrentStage and StageAPI.CurrentStage.ChallengeWaves)) then return end

    local seed = Isaac.GetPlayer():GetCollectibleRNG(mod.COLLECTIBLE_DRILL):Next()
    local wavesToUse = (data.IS_BOSS_CHALLENGE and StageAPI.CurrentStage.ChallengeWaves.Boss or StageAPI.CurrentStage.ChallengeWaves.Normal)
    local wave = StageAPI.ChooseRoomLayout{
        RoomList = wavesToUse,
        Seed = seed,
        Shape = Game():GetRoom():GetRoomShape(),
        RoomType = RoomType.ROOM_CHALLENGE,
        RequireRoomType = false,
        Doors = nil,
        IgnoreDoors = false,
        DisallowIDs = nil,
        MinDifficulty = data.CURR_DIFFICULTY,
        MaxDifficulty = data.CURR_DIFFICULTY,
    }

    local entitiesToSpawn = StageAPI.ObtainSpawnObjects(wave, seed, true)
    local ents = StageAPI.LoadRoomLayout(nil, {entitiesToSpawn}, false, true, false, true, nil, nil, nil, true)

    data.CURRENT_LAYOUT_ENEMIES = {}
    for _, ent in ipairs(ents) do
        if(ent:ToNPC() and ent:CanShutDoors() and not (ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT))) then
            table.insert(data.CURRENT_LAYOUT_ENEMIES, ent)
        end
    end

    data.WAVE_COOLDOWN = FRAME_COOLDOWN
end

local function postUpdate(_)
    local data = mod:getExtraDataTable().DRILLDATA
    if(not data) then return end
    if(data.IS_ACTIVE~=1) then return end

    if(data.RESTART_CURRENT_WAVE or not data.CURRENT_LAYOUT_ENEMIES) then
        spawnWave()
        data.RESTART_CURRENT_WAVE = nil
    end
    if(not data.CURRENT_LAYOUT_ENEMIES) then return end

    for i, ent in ipairs(data.CURRENT_LAYOUT_ENEMIES) do
        if(not (ent and ent:ToNPC() and ent:Exists() and not ent:IsDead())) then
            table.remove(data.CURRENT_LAYOUT_ENEMIES, i)
        end
    end
    if(#data.CURRENT_LAYOUT_ENEMIES<=0) then
        if(data.WAVE_COOLDOWN and data.WAVE_COOLDOWN>0) then
            data.WAVE_COOLDOWN = data.WAVE_COOLDOWN-1
        else
            if(data.CUR_WAVE==data.MAX_WAVES+1) then
                data.IS_ACTIVE = 2
                Game():ChangeRoom(data.PREV_ROOM_IDX)

                return
            end
            if(WAVE_DIFFICULTY_UPGRADES[data.CUR_WAVE]) then data.CURR_DIFFICULTY = (NEXT_DIFF[data.CURR_DIFFICULTY] or 10) end
            data.CUR_WAVE = data.CUR_WAVE+1

            spawnWave()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local function postNewLevel(_)
    local data = mod:getExtraDataTable().DRILLDATA
    if(not data) then return end

    data.RESTART_CURRENT_WAVE = true
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, math.huge, postNewLevel)

local function postPickupInit(_, pickup)
    if(pickup.FrameCount~=0) then return end
    local data = mod:getExtraDataTable().DRILLDATA
    if(not data) then return end

    --print(data.IS_ACTIVE, Game():GetLevel():GetCurrentRoomIndex()==data.PREV_ROOM_IDX, pickup.ShopItemId, pickup.ShopItemId==data.STORED_ID)

    if(data.IS_ACTIVE~=2 and Game():GetLevel():GetCurrentRoomIndex()~=data.PREV_ROOM_IDX) then return end
    if(pickup:ToPickup().ShopItemId==data.STORED_ID) then
        pickup.ShopItemId = FREE_PICKUP_ID
        data.IS_ACTIVE = 0
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postPickupInit)

local function getFreePickupPrice(_, var, st, id, price)
    if(id==FREE_PICKUP_ID) then return PickupPrice.PRICE_FREE end
end
mod:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, getFreePickupPrice)