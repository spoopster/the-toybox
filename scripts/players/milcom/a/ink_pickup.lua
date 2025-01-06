local mod = MilcomMOD
local sfx = SFXManager()

local inkValue = {
    [mod.PICKUP_INK_1] = 1,
    [mod.PICKUP_INK_2] = 2,
    [mod.PICKUP_INK_5] = 5,
}

local invalidReplacementSubTypes = {
    [PickupVariant.PICKUP_COIN] = {
        [mod.PICKUP_INK_1] = 0,
        [mod.PICKUP_INK_2] = 0,
        [mod.PICKUP_INK_5] = 0,
    },
    [PickupVariant.PICKUP_BOMB] = {
        [BombSubType.BOMB_GIGA] = 0,
        [BombSubType.BOMB_GOLDEN] = 0,
        [BombSubType.BOMB_GOLDENTROLL] = 0,
        [BombSubType.BOMB_SUPERTROLL] = 0,
        [BombSubType.BOMB_TROLL] = 0,
    },
    [PickupVariant.PICKUP_KEY] = {
        [KeySubType.KEY_GOLDEN] = 0,
    },
}

local RANDOM_INK_PICKER = WeightedOutcomePicker()
RANDOM_INK_PICKER:AddOutcomeWeight(mod.PICKUP_INK_1, 96)
RANDOM_INK_PICKER:AddOutcomeWeight(mod.PICKUP_INK_2, 3)
RANDOM_INK_PICKER:AddOutcomeWeight(mod.PICKUP_INK_5, 1)

local function getInkValue(_, pickup)
    if(inkValue[pickup.SubType]) then
        return inkValue[pickup.SubType]
    end
end
mod:AddCallback(ModCallbacks.MC_PICKUP_GET_COIN_VALUE, getInkValue)

---@param pickup EntityPickup
local function postInkUpdate(_, pickup)
    if(not inkValue[pickup.SubType]) then return end

    local sp = pickup:GetSprite()
    if(sp:IsEventTriggered("DropSound")) then
        sfx:Play(SoundEffect.SOUND_GOLD_HEART_DROP, 0.75, 2, false, 1.2)

        local splat = Isaac.Spawn(1000,7,1,pickup.Position,Vector.Zero,pickup):ToEffect()
        splat.SpriteScale = Vector(1,1)*0.6
        splat.Color = Color(0.2,0.2,0.2, 0.5)
    end
    if(sp:GetFrame()==1 and sp:GetAnimation()=="Collect") then
        sfx:Play(SoundEffect.SOUND_SHELLGAME, 0.75, 1, false, 1.1)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postInkUpdate, PickupVariant.PICKUP_COIN)

local function cancelRoomSpawns()
    if(Game():GetRoom():GetType()==RoomType.ROOM_DEFAULT) then
        return true
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, math.huge, cancelRoomSpawns)

---@param pickup EntityPickup
local function tryReplaceRandomPickupSpawns(_, pickup, var, subtype, reqVar, reqSub, rng)
    --print(var, subtype, reqVar, reqSub)
    if((reqVar==PickupVariant.PICKUP_BOMB or reqVar==PickupVariant.PICKUP_KEY) and (reqSub==mod.PICKUP_INK_1 or reqSub==mod.PICKUP_INK_2 or reqSub==mod.PICKUP_INK_5)) then
        return {PickupVariant.PICKUP_COIN, reqSub, false} -- stupid contract from below hack
    end
    if(not (reqVar==0 or reqSub==0)) then return end
    if(not (var==PickupVariant.PICKUP_COIN or var==PickupVariant.PICKUP_BOMB or var==PickupVariant.PICKUP_KEY)) then return end
    if(not PlayerManager.AnyoneIsPlayerType(mod.PLAYER_MILCOM_A)) then return end

    if(invalidReplacementSubTypes[var][subtype]~=0) then
        local selSub = RANDOM_INK_PICKER:PickOutcome(rng)

        return {PickupVariant.PICKUP_COIN, selSub, false}
    end
end
--mod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, tryReplaceRandomPickupSpawns)