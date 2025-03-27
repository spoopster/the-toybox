local mod = ToyboxMod
local sfx = SFXManager()

--* better visual for heal pls

local MANTLE_FLY_NUM = 2
local MANTLE_FLY_CHANCE = 0.5
local MANTLE_POOP_CHANCE = 0.1*1/3
local MANTLE_POOP_RNG = mod:generateRng()

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
    if(not mod:isAtlasA(player)) then return end
    local data = mod:getAtlasATable(player)
    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.POOP.ID)
    local rng = player:GetCardRNG(mod.CONSUMABLE.MANTLE_POOP)

    for _=1, numMantles do
        if(rng:RandomFloat()<MANTLE_FLY_CHANCE) then player:AddBlueFlies(MANTLE_FLY_NUM, player.Position, nil) end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, addPoopFlies)

local function replaceRockSpawn(_, t,v,vardata,idx,seed)
    local finalChance = 0
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(mod:isAtlasA(pl)) then finalChance = finalChance+mod:getNumMantlesByType(pl, mod.MANTLE_DATA.POOP.ID) end
    end
    finalChance = finalChance*MANTLE_POOP_CHANCE

    MANTLE_POOP_RNG = MANTLE_POOP_RNG or mod:generateRng()
    if(MANTLE_POOP_RNG:RandomFloat()<finalChance) then
        return {
            GridEntityType.GRID_POOP,
            0,
            0,
            seed
        }
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_ROOM_GRID_ENTITY_SPAWN, replaceRockSpawn, GridEntityType.GRID_ROCK)

--! TRANSF
local function poopHeal(_, poop)
    local shouldDoTransfEffect = nil
    for _, player in ipairs(mod:getAllAtlasA()) do
        player = player:ToPlayer()
        if(mod:atlasHasTransformation(player, mod.MANTLE_DATA.POOP.ID)) then
            local didHeal = mod:addMantleHp(player, 1)
            shouldDoTransfEffect = {player, didHeal}

            if(didHeal) then
                local gulpEffect = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, nil):ToEffect()
                gulpEffect.SpriteOffset = Vector(0, -35)
                gulpEffect.DepthOffset = 1000
                gulpEffect:FollowParent(player)

                sfx:Play(SoundEffect.SOUND_VAMP_GULP)
            end
        end
    end
    if(shouldDoTransfEffect) then
        if(shouldDoTransfEffect[2]) then
            Game():Fart(poop.Position, nil, shouldDoTransfEffect[1], 0.8)
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_POOP_DESTROY, poopHeal)

local function changePoopPickupPool(_, pickup, poop)
    local isAtlasPoop = false
    for _, player in ipairs(mod:getAllAtlasA()) do
        player = player:ToPlayer()
        if(mod:atlasHasTransformation(player, mod.MANTLE_DATA.POOP.ID)) then
            isAtlasPoop = true
        end
    end
    local rng = mod:generateRng(poop.Desc.SpawnSeed)

    if(isAtlasPoop and (pickup or rng:RandomFloat()<TRANSF_EXTRADROP_CHANCE)) then
        return {
            Type = 5,
            Variant = 0,
            SubType = NullPickupSubType.NO_COLLECTIBLE_CHEST,
        }
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POOP_SPAWN_DROP, changePoopPickupPool)