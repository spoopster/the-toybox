
local sfx = SFXManager()

-- make the default collectible evil breakfast be like

local CANCEL_CHECK_EFFECT = false
local REPLACE_CHANCE = 0.2
local MARKED_SEEDS = {}

local POOL_PICKER = WeightedOutcomePicker()
POOL_PICKER:AddOutcomeWeight(ItemPoolType.POOL_CURSE, 5)
POOL_PICKER:AddOutcomeWeight(ItemPoolType.POOL_RED_CHEST, 1)

---@param tear EntityTear
---@param pl EntityPlayer
local function replaceTearVariant(_, tear, pl)
    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_CURSED_EULOGY) and tear.Variant==TearVariant.BLUE) then
        tear:ChangeVariant(TearVariant.BLOOD)
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, replaceTearVariant)

local function tryReplacePool(_, pool, dec, seed)
    if(CANCEL_CHECK_EFFECT) then return end

    local totalEulogyNum = PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_CURSED_EULOGY)
    if(totalEulogyNum<=0) then return end

    local rng = ToyboxMod:generateRng(seed)

    if(rng:RandomFloat()<totalEulogyNum*REPLACE_CHANCE) then
        local pickedPool = POOL_PICKER:PickOutcome(rng)
        if(Game().Difficulty>=Difficulty.DIFFICULTY_GREED and pickedPool==ItemPoolType.POOL_CURSE) then
            pickedPool = ItemPoolType.POOL_GREED_CURSE
        end

        CANCEL_CHECK_EFFECT = true
        local pickedItem = Game():GetItemPool():GetCollectible(pickedPool, true, rng:RandomInt(2^32-1), CollectibleType.COLLECTIBLE_BREAKFAST)
        CANCEL_CHECK_EFFECT = false

        table.insert(MARKED_SEEDS, seed)
        return pickedItem
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, tryReplacePool)

---@param pickup EntityPickup
local function doEvilEffect(_, pickup)
    local shouldDoEvilEffect = false

    local poolSeed = ToyboxMod:generateRng(pickup.InitSeed):RandomInt(2^32-1)
    for _, seed in ipairs(MARKED_SEEDS) do
        if(seed==poolSeed) then
            shouldDoEvilEffect = true

            break
        end
    end

    if(shouldDoEvilEffect) then
        local evilEffect = Isaac.Spawn(1000,15,2,pickup.Position,Vector.Zero,pickup):ToEffect()
        evilEffect.Color = Color(0.25,0.25,0.25,1)
        sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 0.5, 2, false, 0.85)

        pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, doEvilEffect)

local function clearSeedsTable(_)
    MARKED_SEEDS = {}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, clearSeedsTable)