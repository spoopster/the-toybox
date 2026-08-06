local MIN_SPEED_MULT = 0.9
local MAX_SPEED_MULT = 1.2

local FLAG_CHANCE = 0.15
local FLAG_CHANCE_PER_LUCK = 0.05
local STACK_MULT = 1

local function TEARFLAG(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end

local TEARFLAGS_BLACKLIST = {
    [28] = true, -- sad bombs
    [29] = true, -- butt bombs
    [35] = true, -- glitter bombs
    [36] = true, -- scatter bombs
    [41] = true, -- black hp drop (serpents kiss)
    [42] = true, -- tractor beam
}
local MAX_FLAGS = TearFlags.TEAR_EFFECT_COUNT

local TEAR_FLAGS = {}
for i=0, MAX_FLAGS-1 do
    if(not TEARFLAGS_BLACKLIST[i]) then
        table.insert(TEAR_FLAGS, TEARFLAG(i))
    end
end

---@param pl EntityPlayer
local function getMutagenFlags(pl)
    local rng = ToyboxMod:generateRng(ToyboxMod.GAME:GetLevel():GetCurrentRoomDesc().SpawnSeed)

    local flags = {}
    for _=1, pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_MUTAGEN) do
        table.insert(flags, TEAR_FLAGS[rng:RandomInt(1,#TEAR_FLAGS)])
    end

    return flags
end

---@param pl EntityPlayer
local function rerollFlags(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_MUTAGEN)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.MUTAGEN_FLAGS = getMutagenFlags(pl)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, rerollFlags)

---@param firstTime boolean
---@param pl EntityPlayer
local function getAsteroidBelt(_, _, _, firstTime, _, _, pl)
    if(firstTime) then
        local data = ToyboxMod:getEntityDataTable(pl)
    data.MUTAGEN_FLAGS = getMutagenFlags(pl)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, getAsteroidBelt, ToyboxMod.COLLECTIBLE_MUTAGEN)

---@param pl EntityPlayer
---@param params TearParams
local function tryAddFlags(_, pl, params, weap, dmg, tearDisp, source)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_MUTAGEN)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.MUTAGEN_FLAGS = data.MUTAGEN_FLAGS or getMutagenFlags(pl)

    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_MUTAGEN)

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_MUTAGEN)
    local chance = FLAG_CHANCE*(1+STACK_MULT*(mult-1))+FLAG_CHANCE_PER_LUCK*pl.Luck

    local addedFlag = 0
    for _, tearflag in ipairs(data.MUTAGEN_FLAGS) do
        if(rng:RandomFloat()<chance) then
            params.TearFlags = params.TearFlags | tearflag
            addedFlag = addedFlag+1
        end
    end

    if(addedFlag) then
        local mul = addedFlag^0.75

        params.TearColor = params.TearColor*Color(0.85^mul,1.3^mul,1.3^mul,1,0,0.3*mul,0.3*mul)
    end

    params.SpeedMultiplier = rng:RandomFloat()*(MAX_SPEED_MULT-MIN_SPEED_MULT)+MIN_SPEED_MULT
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, tryAddFlags)