local mod = ToyboxMod
local sfx = SFXManager()

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

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.POOP.ID)
    else
        local rng = player:GetCardRNG(mod.CONSUMABLE.MANTLE_POOP)
        local st = POOP_PICKER:PickOutcome(rng)

        local heldPoop = Isaac.Spawn(EntityType.ENTITY_POOP, st, 0, player.Position,Vector.Zero,player)
        for i=1,20 do heldPoop:Update() end
        if(st==1000) then
            heldPoop:GetData().FFCursedPoop = true
            heldPoop:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_cursed_poop.png")
            heldPoop:GetSprite():LoadGraphics()
        elseif(st==1001) then
            heldPoop:GetData().FFShampoo = true
            heldPoop:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_shampoo.png")
            heldPoop:GetSprite():LoadGraphics()
        elseif(st==1002) then
            heldPoop:GetData().FFEvilPoop = true
            heldPoop:GetSprite():ReplaceSpritesheet(0, "gfx/grid/evilpoop/grid_evilpoop.png")
            heldPoop:GetSprite():LoadGraphics()
        elseif(st==1003) then
            heldPoop:GetData().FFFuzzyPoop = true
            heldPoop:GetSprite():ReplaceSpritesheet(0, "gfx/grid/grid_fuzzy_poop.png")
            heldPoop:GetSprite():LoadGraphics()
        end

        mod:setEntityData(heldPoop, "DRIPPY_POOP", 0)
        player:TryHoldEntity(heldPoop)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE.MANTLE_POOP)

local function updateDripPoop(_, poop)
    local data = mod:getEntityDataTable(poop)
    if(not (data.DRIPPY_POOP and data.DRIPPY_POOP==0)) then return end

    if(poop.FrameCount%CREEP_SPAWN_FREQ==0) then
        local creep = Isaac.Spawn(1000, EffectVariant.CREEP_LIQUID_POOP, 0, poop.Position, Vector.Zero, poop)
        if(poop.Velocity:Length()<0.1) then data.DRIPPY_POOP=1 end
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, updateDripPoop, EntityType.ENTITY_POOP)

if(mod.ATLAS_A_MANTLESUBTYPES) then mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE.MANTLE_POOP] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(mod.CONSUMABLE.MANTLE_POOP).Weight = (mod.CONFIG.MANTLE_WEIGHT or 0.5)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)