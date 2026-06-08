
local sfx = SFXManager()

---@param player EntityPlayer
local function gildedAppleUse(_, item, rng, player, flags, slot, vdata)
    sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
    player:AddGoldenHearts(1)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, gildedAppleUse, ToyboxMod.COLLECTIBLE_GILDED_APPLE)

---@param pl EntityPlayer
---@param slot EntitySlot
local function renderWhiteDaisy(_, pl, slot)
    return {
        HideOutline = true,
        CropOffset = Vector(32*(pl:GetActiveCharge(slot)>=pl:GetActiveMaxCharge(slot) and 1 or 0),0),
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYERHUD_RENDER_ACTIVE_ITEM, renderWhiteDaisy, ToyboxMod.COLLECTIBLE_GILDED_APPLE)



-- < BOOK OF VIRTUES > --

local WISP_COIN_SPAWNS = WeightedOutcomePicker()
WISP_COIN_SPAWNS:AddOutcomeFloat(1, 1)
WISP_COIN_SPAWNS:AddOutcomeFloat(2, 1)
WISP_COIN_SPAWNS:AddOutcomeFloat(3, 1)

local WISP_MIDAS_RANGE = 40*1.5
local WISP_MIDAS_DURATION = 30*4

---@param fam EntityFamiliar
local function virtuesWispDeath(_, fam)
    if(not (fam.Variant==FamiliarVariant.WISP and fam.SubType==ToyboxMod.COLLECTIBLE_GILDED_APPLE)) then return end

    local rng = fam:GetDropRNG()
    
    local coins = WISP_COIN_SPAWNS:PickOutcome(rng)
    for _=1, coins do
        local vel = rng:RandomVector()*1.5
        local coin = Isaac.Spawn(5,20,0,fam.Position,vel,nil):ToPickup()
    end

    local poof = Isaac.Spawn(1000,15,0,fam.Position,Vector.Zero,nil):ToEffect()
    local poofSprite = poof:GetSprite()
    poofSprite:Load("gfx/293.000_UltraGreedCoins.anm2", true)
    poofSprite:Play("CrumbleNoDebris", true)
    poofSprite:SetCustomShader("shaders_tb/pixelate")
    poof.Color = Color(1,1,1,1,0,0,0,1/0.75)
    poof.SpriteScale = Vector(1,1)*0.75

    for _, ent in ipairs(Isaac.FindInRadius(fam.Position, WISP_MIDAS_RANGE, EntityPartition.ENEMY)) do
        if(ToyboxMod:isValidEnemy(ent)) then
            ent:AddMidasFreeze(EntityRef(fam.Player), WISP_MIDAS_DURATION, true)
        end
    end

    sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, virtuesWispDeath, EntityType.ENTITY_FAMILIAR)