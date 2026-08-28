
local sfx = SFXManager()

--* better visual for heal pls

local MANTLE_FLY_NUM = 2
local MANTLE_FLY_CHANCE = 0.5
local MANTLE_POOP_CHANCE = 0.1*1/3
local MANTLE_POOP_RNG = ToyboxMod:generateRng()

local TRANSF_EXTRADROP_CHANCE = 0.1
local TRANSF_DROP_PICKER = WeightedOutcomePicker()
local TRANSF_DROPS = {
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0},
}
TRANSF_DROP_PICKER:AddOutcomeFloat(1, 0.25, 100)
TRANSF_DROP_PICKER:AddOutcomeFloat(2, 0.25, 100)
TRANSF_DROP_PICKER:AddOutcomeFloat(3, 0.15, 100)
TRANSF_DROP_PICKER:AddOutcomeFloat(4, 0.15, 100)
TRANSF_DROP_PICKER:AddOutcomeFloat(5, 0.06, 100)
TRANSF_DROP_PICKER:AddOutcomeFloat(6, 0.06, 100)
TRANSF_DROP_PICKER:AddOutcomeFloat(7, 0.06, 100)
TRANSF_DROP_PICKER:AddOutcomeFloat(8, 0.02, 100)

--! MANTLE
---@param player EntityPlayer
local function addPoopFlies(_, player)
    if(not ToyboxMod:isAtlasA(player)) then return end
    local data = ToyboxMod:getAtlasATable(player)
    local numMantles = ToyboxMod:getNumMantlesByType(player, ToyboxMod.MANTLE_DATA.POOP.ID)
    local rng = player:GetCardRNG(ToyboxMod.CARD_MANTLE_POOP)

    for _=1, numMantles do
        if(rng:RandomFloat()<MANTLE_FLY_CHANCE) then player:AddBlueFlies(MANTLE_FLY_NUM, player.Position, nil) end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_ROOM_CLEAR, addPoopFlies)

local function replaceRockSpawn(_, t,v,vardata,idx,seed)
    local finalChance = 0
    for i=0, ToyboxMod.GAME:GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(ToyboxMod:isAtlasA(pl)) then finalChance = finalChance+ToyboxMod:getNumMantlesByType(pl, ToyboxMod.MANTLE_DATA.POOP.ID) end
    end
    finalChance = finalChance*MANTLE_POOP_CHANCE

    MANTLE_POOP_RNG = MANTLE_POOP_RNG or ToyboxMod:generateRng()
    if(MANTLE_POOP_RNG:RandomFloat()<finalChance) then
        return {
            GridEntityType.GRID_POOP,
            0,
            0,
            seed
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_GRID_ENTITY_SPAWN, replaceRockSpawn, GridEntityType.GRID_ROCK)

--! TRANSF

---@param poop GridEntityPoop
---@param source EntityRef
local function tryHealWhenDestroyedPoop(_, poop, _, source)
    if(poop.State~=1000) then return end
    if(poop:GetVariant()==GridPoopVariant.RED) then return end

    local player = source and source.Entity and ToyboxMod:getPlayerFromEnt(source.Entity)
    if(not (player and ToyboxMod:isAtlasA(player) and ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.POOP.ID))) then return end

    local didHeal = ToyboxMod:addMantleHp(player, 1)
    if(didHeal) then
        local gulpEffect = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, nil):ToEffect()
        gulpEffect.SpriteOffset = Vector(0, -35)
        gulpEffect.DepthOffset = 1000
        gulpEffect:FollowParent(player)
        gulpEffect:GetSprite():Load("gfx_tb/effects/effect_notify.anm2", true)
        gulpEffect:GetSprite():Play("PoopHeal", true)

        sfx:Play(SoundEffect.SOUND_VAMP_GULP)
    end
    ToyboxMod.GAME:Fart(poop.Position, nil, player, 0.8)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_HURT, tryHealWhenDestroyedPoop, GridEntityType.GRID_POOP)

---@param poop GridEntityPoop
---@param dmg integer
---@param source EntityRef
local function instabreakPoop(_, poop, dmg, source)
    local player = source and source.Entity and ToyboxMod:getPlayerFromEnt(source.Entity)
    if(not (player and ToyboxMod:isAtlasA(player) and ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.POOP.ID))) then return end

    return dmg+100
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_GRID_HURT, instabreakPoop, GridEntityType.GRID_POOP)

local function changePoopPickupPool(_, pickup, poop)
    local isAtlasPoop = false
    for _, player in ipairs(ToyboxMod:getAllAtlasA()) do
        player = player:ToPlayer()
        if(ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.POOP.ID)) then
            isAtlasPoop = true
        end
    end
    local rng = ToyboxMod:generateRng(poop.Desc.SpawnSeed)

    if(isAtlasPoop and (pickup or rng:RandomFloat()<TRANSF_EXTRADROP_CHANCE)) then
        return {
            Type = 5,
            Variant = 0,
            SubType = NullPickupSubType.NO_COLLECTIBLE_CHEST,
        }
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POOP_SPAWN_DROP, changePoopPickupPool)