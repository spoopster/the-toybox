

local HEART_REPLACEMENT_CHANCES = {
    [0]=0.8,
    [1]=0.75,
    [2]=0.7,
    [3]=0.65,
}

---@param pickup EntityPickup
local function upgradeHalfHearts(_, pickup, var, sub, rvar, rsub, rng)
    --if(var~=10 or not (rvar==0 or rsub==0)) then return end

    local allAtlasA = ToyboxMod:getAllAtlasA()
    if(#allAtlasA==0) then return end

    local chance = 0
    for _, player in ipairs(allAtlasA) do
        player = player:ToPlayer()
        chance = chance+HEART_REPLACEMENT_CHANCES[ToyboxMod:getRightmostMantleIdx(player)]
    end
    if(rng:RandomFloat()<chance) then
        return {ToyboxMod.PICKUP_RANDOM_SELECTOR, ToyboxMod.PICKUP_RANDOM_MANTLE, true}
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_SELECTION, upgradeHalfHearts)

--* todo: make certain special rooms always rerolll into [x] mantle type