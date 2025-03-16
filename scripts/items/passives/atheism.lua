local mod = ToyboxMod

local DEVILCHANCE_INCREASE = 0.15
local function getDevilDealChance(_, chance)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.ATHEISM)) then return end
    return chance+(DEVILCHANCE_INCREASE*PlayerManager.GetNumCollectibles(mod.COLLECTIBLE.ATHEISM)-0.01)
end
mod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, getDevilDealChance)


local function replaceWithAtheismDeal(_)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.ATHEISM)) then return end

    local level = Game():GetLevel()
    local st = RoomSubType.TREASURE_OPTIONS
    local newItemRoom = RoomConfigHolder.GetRandomRoom(math.max(1, Random()), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_TREASURE, RoomShape.ROOMSHAPE_1x1, 0, -1, 0, 10, 0, st, -1)

    local devilroom = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
    if(not devilroom.Data) then
        devilroom:InitSeeds(mod:generateRng())
        devilroom.Data = newItemRoom
        devilroom.OverrideData = newItemRoom
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, replaceWithAtheismDeal)

---@param door GridEntityDoor
local function unlockAtheismDealDoor(_, door)
    if(door:IsLocked() and door.TargetRoomIndex==-1 and door.TargetRoomType==RoomType.ROOM_TREASURE) then
        door:SetLocked(false)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_DOOR_UPDATE, unlockAtheismDealDoor)



local statsSprite = Sprite("gfx/ui/hudstats2.anm2", true)
statsSprite:Play("Idle", true)
local function renderAtheismDealIcon(_)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.ATHEISM)) then return end
    if(not Game():GetHUD():IsVisible()) then return end

    local pos = Vector(20,12)*Options.HUDOffset + Vector(0,160)
    if(Game():GetNumPlayers()>1) then
        pos = pos+Vector(0,12)

        if(Isaac.GetPlayer():GetPlayerType()==PlayerType.PLAYER_JACOB) then
            pos = pos+Vector(0,14)
        end
        if(PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY_B)) then
            pos = pos+Vector(0,9)
        end
    end
    if(PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BETHANY)) then
        pos = pos+Vector(0,8)
    end
    if(PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BETHANY_B)) then
        pos = pos+Vector(0,8)
    end
    if(Game().Difficulty==Difficulty.DIFFICULTY_NORMAL and not Game():AchievementUnlocksDisallowed()) then
        pos = pos-Vector(0,16)
    end

    statsSprite:SetFrame(10)
    statsSprite.Color = Color(0,0,0,1,0,0,0)
    statsSprite:Render(pos)

    statsSprite:SetFrame(9)
    statsSprite.Color = Color(1,1,1,0.5,0,0,0)
    statsSprite:Render(pos-Vector(0,1))
end
mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, renderAtheismDealIcon)

---@param pl EntityPlayer
local function addAtheism(_, _, _, firstTime, _, _, pl)
    pl:AddInnateCollectible(CollectibleType.COLLECTIBLE_DUALITY, 1)

    local devilRoomData = Game():GetLevel():GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX).Data
    if(firstTime and not (devilRoomData and devilRoomData.Type==RoomType.ROOM_TREASURE)) then
        replaceWithAtheismDeal()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addAtheism, mod.COLLECTIBLE.ATHEISM)

---@param pl EntityPlayer
local function removeAtheism(_, pl)
    pl:AddInnateCollectible(CollectibleType.COLLECTIBLE_DUALITY, -1)
end
mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, removeAtheism, mod.COLLECTIBLE.ATHEISM)

---@param pl EntityPlayer
local function addDualitiesOnInit(_, pl)
    if(pl.FrameCount~=0) then return end

    local atheismNum = pl:GetCollectibleNum(mod.COLLECTIBLE.ATHEISM)
    if(atheismNum==0) then return end

    pl:AddInnateCollectible(CollectibleType.COLLECTIBLE_DUALITY, atheismNum)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, addDualitiesOnInit)

---@param pl EntityPlayer
local function checkInnateDuality(_, pl)
    if(pl:HasCollectible(mod.COLLECTIBLE.ATHEISM) and pl:GetCollectibleNum(CollectibleType.COLLECTIBLE_DUALITY)<=pl:GetCollectibleNum(mod.COLLECTIBLE.ATHEISM)) then
        local dualityConfig = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_DUALITY)
        if(pl:IsItemCostumeVisible(dualityConfig, PlayerSpriteLayer.SPRITE_GLOW)) then
            pl:RemoveCostume(dualityConfig)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, checkInnateDuality, 0)