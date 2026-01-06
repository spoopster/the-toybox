--[[
Tint effects (WIP)

]]

local RED_DMG = 1.2
local BLUE_TEARS = 1
local GREEN_LUCK = 5
local BROWN_SIZE = 0.5

local CYAN_FLY_INTERVAL = 30*2
local CYAN_MAXFLIES = 3

local PINK_RESPAWN_CHANCE = 0.15

local YELLOW_COIN_TIMEOUT = 30*2

local BLACK_RETRIGGERS = 2
local BLACK_CANCEL_RETRIGGER = false
local BLACK_INVALID_ROOMTYPES = {
    [RoomType.ROOM_BOSS] = true,
    [RoomType.ROOM_BOSSRUSH] = true,
}

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(flag==CacheFlag.CACHE_DAMAGE and ToyboxMod:hasTintedRoomTint("RED")) then
        ToyboxMod:addBasicDamageUp(pl, RED_DMG)
    elseif(flag==CacheFlag.CACHE_FIREDELAY and ToyboxMod:hasTintedRoomTint("BLUE")) then
        ToyboxMod:addBasicTearsUp(pl, BLUE_TEARS)
    elseif(flag==CacheFlag.CACHE_LUCK and ToyboxMod:hasTintedRoomTint("GREEN")) then
        pl.Luck = pl.Luck+GREEN_LUCK
    elseif(flag==CacheFlag.CACHE_SIZE and ToyboxMod:hasTintedRoomTint("BROWN")) then
        pl.SpriteScale = pl.SpriteScale*BROWN_SIZE
        pl.SizeMulti = pl.SizeMulti*BROWN_SIZE
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
local function playerUpdate(_, pl)
    if(ToyboxMod:hasTintedRoomTint("CYAN") and pl.FrameCount%CYAN_FLY_INTERVAL==0) then
        local numflies = 0
        local plhash = GetPtrHash(pl)
        for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR,FamiliarVariant.BLUE_FLY)) do
            if(GetPtrHash(ent:ToFamiliar().Player)==plhash and ToyboxMod:getEntityData(ent, "CYANROOM_FLY")) then
                numflies = numflies+1
            end
        end
        if(numflies<CYAN_MAXFLIES) then
            local fly = pl:AddBlueFlies(1, pl.Position, nil)
            ToyboxMod:setEntityData(fly, "CYANROOM_FLY", true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, playerUpdate)

local function newRoom(_)
    for _, pl in ipairs(PlayerManager.GetPlayers()) do
        if(ToyboxMod:hasTintedRoomTint("WHITE") and not pl:HasCollectible(CollectibleType.COLLECTIBLE_WAFER)) then
            ToyboxMod:addItemForRoom(pl, CollectibleType.COLLECTIBLE_WAFER, 1)
        end
        if(ToyboxMod:hasTintedRoomTint("PURPLE") and not pl:HasCollectible(CollectibleType.COLLECTIBLE_SPOON_BENDER)) then
            ToyboxMod:addItemForRoom(pl, CollectibleType.COLLECTIBLE_SPOON_BENDER, 1)
        end
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_NEW_ROOM_TINTED, newRoom)

---@param npc EntityNPC
local function npcDeath(_, npc)
    if(ToyboxMod:hasTintedRoomTint("PINK") and ToyboxMod:isValidEnemy(npc) and not (npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:IsBoss())) then
        local rng = npc:GetDropRNG()
        if(rng:RandomFloat()<PINK_RESPAWN_CHANCE) then
            local newNpc = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, Vector.Zero, pl):ToNPC()
            newNpc:AddCharmed(EntityRef(pl), -1)
        end
    end
    if(ToyboxMod:hasTintedRoomTint("YELLOW")) then
        local rng = npc:GetDropRNG()
        local dir = Vector.FromAngle(rng:RandomInt(1,360))*3
        local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,0,npc.Position,dir,nil):ToPickup()
        coin.Timeout = YELLOW_COIN_TIMEOUT
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, npcDeath)

local function blackRetriggerClear(_, _)
    local room = Game():GetRoom()
    if(not BLACK_CANCEL_RETRIGGER and ToyboxMod:hasTintedRoomTint("BLACK") and not BLACK_INVALID_ROOMTYPES[room:GetType()]) then
        BLACK_CANCEL_RETRIGGER = true
        for _=1, BLACK_RETRIGGERS do
            room:TriggerClear(true)
        end
        BLACK_CANCEL_RETRIGGER = false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_TRIGGER_CLEAR, blackRetriggerClear)
---@param pl EntityPlayer
local function blackRetriggerClearPlayer(_, pl)
    if(not BLACK_CANCEL_RETRIGGER and ToyboxMod:hasTintedRoomTint("BLACK") and BLACK_INVALID_ROOMTYPES[Game():GetRoom():GetType()]) then
        BLACK_CANCEL_RETRIGGER = true
        for _=1, BLACK_RETRIGGERS do
            pl:TriggerRoomClear()
        end
        BLACK_CANCEL_RETRIGGER = false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, blackRetriggerClearPlayer)