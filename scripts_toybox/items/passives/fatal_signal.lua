local sfx = SFXManager()

local MARKED_SEEDS = {}

local function shouldRerollItem(id)
    local conf = Isaac.GetItemConfig():GetCollectible(id)

    return (conf.AddMaxHearts>0 or conf.AddHearts>0 or conf.AddSoulHearts>0 or conf.AddBlackHearts>0)
end

---@param sel CollectibleType
---@param seed integer
local function tryReplacePool(_, sel, pool, dec, seed)
    if(CANCEL_CHECK_EFFECT) then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_FATAL_SIGNAL)) then return end

    local rng = ToyboxMod:generateRng(seed)
    local itempool = Game():GetItemPool()
    pool = itempool:GetLastPool()

    local item = sel
    while(shouldRerollItem(item)) do
        CANCEL_CHECK_EFFECT = true
        item = itempool:GetCollectible(pool, false, rng:RandomInt(2^32-1), CollectibleType.COLLECTIBLE_SAD_ONION)
        CANCEL_CHECK_EFFECT = false
    end

    if(sel~=item) then
        if(dec) then
            itempool:RemoveCollectible(item)
        end

        table.insert(MARKED_SEEDS, seed)
        --print(sel, item)
        return item
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, tryReplacePool)

---@param pickup EntityPickup
local function doGlitchEffect(_, pickup)
    local shouldDoGlitchEffect = false

    local poolSeed = ToyboxMod:generateRng(pickup.InitSeed):RandomInt(2^32-1)
    for _, seed in ipairs(MARKED_SEEDS) do
        if(seed==poolSeed) then
            shouldDoGlitchEffect = true

            break
        end
    end

    if(shouldDoGlitchEffect) then
        sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 0.5, 2, false, 0.85)
        ToyboxMod:setEntityData(pickup, "GLITCH_DURATION", 24)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, doGlitchEffect)

local function clearSeedsTable(_)
    MARKED_SEEDS = {}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, clearSeedsTable)

---@param pickup EntityPickup
local function pickupGlitchRender(_, pickup)
    if(Game():IsPaused()) then return end
    local cnt = ToyboxMod:getEntityData(pickup, "GLITCH_DURATION")
    if(not cnt) then return end

    if(cnt%2==0) then
        local layer = pickup:GetSprite():GetLayer("head")
        layer:SetCropOffset(Vector(math.random(-32,32), math.random(-4,4)))
        layer:SetWrapSMode(0)
        layer:SetWrapTMode(0)
    end

    cnt = cnt-1
    if(cnt==0) then cnt = nil end
    ToyboxMod:setEntityData(pickup, "GLITCH_DURATION", cnt)
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, pickupGlitchRender)