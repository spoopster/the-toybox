---@param pl EntityPlayer
---@param params TearParams
local function evalParams(_, pl, params, weap, dmg, tearDisp, source)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_AIDS)) then return end

    local c = ToyboxMod:getLuckAffectedChance(pl.Luck, BREATH_CHANCE, BREATH_MAXLUCK, BREATH_MAXCHANCE)
    if(math.random()<c) then
        local totalFlag = 0
        for _, flag in ipairs(FLAGS_TO_ADD) do
            totalFlag = totalFlag | flag
        end
        params.TearFlags = params.TearFlags | totalFlag
        params.TearDamage = params.TearDamage*DMG_MULT
        params.TearColor = Color.Default
        params.TearScale = params.TearScale*1.1
        params.TearVariant = ToyboxMod.TEAR_AIDS
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, evalParams)