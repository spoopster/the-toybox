
local sfx = SFXManager()

local CARBATTERY_QUEUE_COUNT = 2
local CARBATTERY_QUEUE_FRAMESDELAY = 10

local POOP_PICKER = WeightedOutcomePicker()
POOP_PICKER:AddOutcomeWeight(EntityPoopVariant.NORMAL, 1)
POOP_PICKER:AddOutcomeWeight(EntityPoopVariant.GOLDEN, 2)
POOP_PICKER:AddOutcomeWeight(EntityPoopVariant.PETRIFIED, 10)
POOP_PICKER:AddOutcomeWeight(EntityPoopVariant.CORN, 10)
POOP_PICKER:AddOutcomeWeight(EntityPoopVariant.FLAMING, 10)
POOP_PICKER:AddOutcomeWeight(EntityPoopVariant.STINKY, 10)
POOP_PICKER:AddOutcomeWeight(EntityPoopVariant.BLACK, 10)
POOP_PICKER:AddOutcomeWeight(EntityPoopVariant.HOLY, 10)
if(FiendFolio) then
    POOP_PICKER:AddOutcomeWeight(1000, 5) -- Cursed Poop
    POOP_PICKER:AddOutcomeWeight(1001, 10) -- Shampoo
    POOP_PICKER:AddOutcomeWeight(1002, 1) -- Evil Poop
    POOP_PICKER:AddOutcomeWeight(1003, 5) -- Fuzzy Poop
end

local CREEP_SPAWN_FREQ = 1

local function playerHoldPoop(player)
    local rng = player:GetCardRNG(ToyboxMod.CARD_MANTLE_POOP)
    local st = POOP_PICKER:PickOutcome(rng)

    local heldPoop = Isaac.Spawn(EntityType.ENTITY_POOP, st, 0, player.Position,Vector.Zero,player)
    for i=1,20 do heldPoop:Update() end
    if(st==1000) then
        heldPoop:GetData().FFCursedPoop = true
        heldPoop:GetSprite():ReplaceSpritesheet(0, "gfx_tb/grid/grid_cursed_poop.png")
        heldPoop:GetSprite():LoadGraphics()
    elseif(st==1001) then
        heldPoop:GetData().FFShampoo = true
        heldPoop:GetSprite():ReplaceSpritesheet(0, "gfx_tb/grid/grid_shampoo.png")
        heldPoop:GetSprite():LoadGraphics()
    elseif(st==1002) then
        heldPoop:GetData().FFEvilPoop = true
        heldPoop:GetSprite():ReplaceSpritesheet(0, "gfx_tb/grid/evilpoop/grid_evilpoop.png")
        heldPoop:GetSprite():LoadGraphics()
    elseif(st==1003) then
        heldPoop:GetData().FFFuzzyPoop = true
        heldPoop:GetSprite():ReplaceSpritesheet(0, "gfx_tb/grid/grid_fuzzy_poop.png")
        heldPoop:GetSprite():LoadGraphics()
    end

    ToyboxMod:setEntityData(heldPoop, "DRIPPY_POOP", 0)
    player:TryHoldEntity(heldPoop)
end

---@param player EntityPlayer
---@param flags UseFlag
local function useMantle(_, _, player, flags)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CONGLOMERATE) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.POOP.ID)
    else
        local data = ToyboxMod:getEntityDataTable(player)
        if(player:GetHeldEntity()) then
            data.MANTLEPOOP_QUEUE = (data.MANTLEPOOP_QUEUE or 0)+1
        else
            playerHoldPoop(player)
        end

        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            data.MANTLEPOOP_QUEUE = (data.MANTLEPOOP_QUEUE or 0)+CARBATTERY_QUEUE_COUNT
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_POOP)

local function updateDripPoop(_, poop)
    local data = ToyboxMod:getEntityDataTable(poop)
    if(not (data.DRIPPY_POOP and data.DRIPPY_POOP==0)) then return end

    if(poop.FrameCount%CREEP_SPAWN_FREQ==0) then
        local creep = Isaac.Spawn(1000, EffectVariant.CREEP_LIQUID_POOP, 0, poop.Position, Vector.Zero, poop)
        if(poop.Velocity:Length()<0.1) then data.DRIPPY_POOP=1 end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, updateDripPoop, EntityType.ENTITY_POOP)

local function tryHoldNewPoop(_, pl)
    if(pl:GetHeldEntity()) then return end
    local data = ToyboxMod:getEntityDataTable(pl)
    if(not (data.MANTLEPOOP_QUEUE and data.MANTLEPOOP_QUEUE>0)) then return end

    if(math.abs((data.MANTLEPOOP_QUEUE-data.MANTLEPOOP_QUEUE//1)-1/CARBATTERY_QUEUE_FRAMESDELAY)<0.01) then
        data.MANTLEPOOP_QUEUE = data.MANTLEPOOP_QUEUE//1
        playerHoldPoop(pl)
    else
        data.MANTLEPOOP_QUEUE = data.MANTLEPOOP_QUEUE-1/CARBATTERY_QUEUE_FRAMESDELAY
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, tryHoldNewPoop)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_POOP] = true end