local mod = MilcomMOD
local sfx = SFXManager()

--* polish

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_POOP] = true
end

local function useMantle(_, _, player, _)
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.POOP.ID)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_POOP)

local ENUM_POOPFLIES_NUM = 2
local ENUM_POOPFLIES_CHANCE = 0.5
local ENUM_POOPDROP_CHANCE = 0.1
local ENUM_POOPDROP_PICKER = WeightedOutcomePicker()
local ENUM_POOPDROPS = {
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, 0},
    {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0},
}
ENUM_POOPDROP_PICKER:AddOutcomeFloat(1, 0.25, 100)
ENUM_POOPDROP_PICKER:AddOutcomeFloat(2, 0.25, 100)
ENUM_POOPDROP_PICKER:AddOutcomeFloat(3, 0.15, 100)
ENUM_POOPDROP_PICKER:AddOutcomeFloat(4, 0.15, 100)
ENUM_POOPDROP_PICKER:AddOutcomeFloat(5, 0.06, 100)
ENUM_POOPDROP_PICKER:AddOutcomeFloat(6, 0.06, 100)
ENUM_POOPDROP_PICKER:AddOutcomeFloat(7, 0.06, 100)
ENUM_POOPDROP_PICKER:AddOutcomeFloat(8, 0.02, 100)


---@param player EntityPlayer
local function addPoopFlies(_, player)
    if(not mod:isAtlasA(player)) then return end

    local data = mod:getAtlasATable(player)

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.POOP.ID)
    local rng = player:GetCardRNG(mod.CONSUMABLE_MANTLE_POOP)

    for _=1, numMantles do
        if(rng:RandomFloat()<ENUM_POOPFLIES_CHANCE) then player:AddBlueFlies(ENUM_POOPFLIES_NUM, player.Position, nil) end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, addPoopFlies)

---@param poop GridEntityPoop
local function poopUpdate(_, poop)
    if(Game():IsPaused()) then return end
    if(poop:GetVariant()==GridPoopVariant.RED) then return end
    local data = mod:getGridEntityDataTable(poop)

    if(data.POOP_DMG==nil) then data.POOP_DMG = poop:GetSaveState().State end
    if(data.POOP_SPAWNEDPICKUP==nil) then data.POOP_SPAWNEDPICKUP = -1 end
    
    if(data.POOP_DMG and poop.State==1000 and poop.State~=data.POOP_DMG) then
        local shouldDoTransfEffect = false
        for _, player in ipairs(mod:getAllAtlasA()) do
            player = player:ToPlayer()
            if(mod:atlasHasTransformation(player, mod.MANTLE_DATA.POOP.ID)) then
                local didHeal = mod:addMantleHp(player, 1)
                shouldDoTransfEffect = true

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
            local poof = Isaac.Spawn(1000,16,1,poop.Position,Vector.Zero,nil):ToEffect()
            local col = Color(1,1,1,1)
            col:SetColorize(0,0,0,1)
            col:SetColorize(124/255, 86/255, 52/255,1)

            poof.Color = col

            poof.SpriteScale = Vector(1,1)*0.75

            sfx:Play(SoundEffect.SOUND_FART)
            data.POOP_SPAWNEDPICKUP = 0
        end
    end

    if(data.POOP_SPAWNEDPICKUP>0) then data.POOP_SPAWNEDPICKUP = data.POOP_SPAWNEDPICKUP-1 end
    if(poop.State==1000 and data.POOP_SPAWNEDPICKUP==0) then
        data.POOP_SPAWNEDPICKUP = -100

        local isAtlasPoop = false
        for _, player in ipairs(mod:getAllAtlasA()) do
            player = player:ToPlayer()
            if(mod:atlasHasTransformation(player, mod.MANTLE_DATA.POOP.ID)) then
                isAtlasPoop = true
            end
        end

        local pickupSpawned = false
        local selPickup
        for _, pickup in ipairs(Isaac.FindByType(5)) do
            if(pickup.Position:Distance(poop.Position)<2) then
                if(pickup.FrameCount==1) then
                    pickupSpawned = true
                    selPickup = pickup:ToPickup()
                    break
                end
            end
        end
        
        local rng = mod:generateRng(poop.Desc.SpawnSeed)
        local selPickupData = ENUM_POOPDROPS[ENUM_POOPDROP_PICKER:PickOutcome(rng)]

        if(isAtlasPoop and (not pickupSpawned) and rng:RandomFloat()<ENUM_POOPDROP_CHANCE) then
            local pickup = Isaac.Spawn(selPickupData[1], selPickupData[2], selPickupData[3], poop.Position, Vector.Zero, nil)
        elseif(isAtlasPoop and pickupSpawned) then
            selPickup:ToPickup():Morph(selPickupData[1], selPickupData[2], selPickupData[3])
        end
    end

    data.POOP_DMG = poop.State
end
mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_UPDATE, poopUpdate)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(not mod:isAtlasA(player)) then return end

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, playMantleSFX, mod.MANTLE_DATA.POOP.ID)