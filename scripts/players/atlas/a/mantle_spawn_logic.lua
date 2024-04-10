local mod = MilcomMOD

local HEART_REPLACEMENT_CHANCES = {
    [0]=0.8,
    [1]=0.75,
    [2]=0.7,
    [3]=0.65,
}

---@param pickup EntityPickup
local function postHeartInit(_, pickup)
    if(pickup:GetSprite():GetAnimation()~="Appear") then return end

    local allAtlasA = mod:getAllAtlasA()
    if(#allAtlasA==0) then return end

    local rng = RNG()
    rng:SetSeed(pickup.InitSeed, 35)

    local chance = 0
    for _, player in ipairs(allAtlasA) do
        player = player:ToPlayer()
        chance = chance+HEART_REPLACEMENT_CHANCES[mod:getRightmostMantleIdx(player)]
    end
    chance = chance/Game():GetNumPlayers()
    if(rng:RandomFloat()<chance) then
        local mantle = mod:getRandomMantle(rng)
        local cons = mod.MANTLE_DATA[mod:getMantleKeyFromId(mantle)].CONSUMABLE_SUBTYPE
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, cons, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postHeartInit, PickupVariant.PICKUP_HEART)

--* todo: make certain special rooms always rerolll into [x] mantle type