local REROLL_BASE_NUM = 1
local LUCK_REROLL_CHANCE = 0.15

---@param ent Entity
function ToyboxMod:getLamatRabbitRerollsNum(ent)
    local player = ent and ent:ToPlayer()
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_LAMAT_RABBIT))) then return 0 end

    local extraLuckChance = LUCK_REROLL_CHANCE*player.Luck
    local rerollsNum = REROLL_BASE_NUM*player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_LAMAT_RABBIT)+extraLuckChance//1

    local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_LAMAT_RABBIT)
    if((extraLuckChance%1)>0 and rng:RandomFloat()<(extraLuckChance%1)) then
        rerollsNum = rerollsNum+1
    end
    
    return rerollsNum
end

---@param color1 Color
---@param color2 Color
local function colorEqual(color1, color2)
    local colO1 = color1:GetOffset()
    local colO2 = color2:GetOffset()

    local colC1 = color1:GetColorize()
    local colC2 = color2:GetColorize()

    return (color1.R==color2.R and color1.G==color2.G and color1.B==color2.B and color1.A==color2.A and
            colO1.R==colO2.R and colO1.G==colO2.G and colO1.B==colO2.B and
            colC1.R==colC2.R and colC1.G==colC2.G and colC1.B==colC2.B)
end

local cancelEval = false

---@param pl EntityPlayer
---@param params TearParams
---@param weap WeaponType
---@param dmg number
---@param tearDisp integer
---@param source Entity
local function evalParams(_, pl, params, weap, dmg, tearDisp, source)
    if(cancelEval) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_LAMAT_RABBIT)) then return end

    cancelEval = true
    for _=1, ToyboxMod:getLamatRabbitRerollsNum(pl) do
        local otherParams = pl:GetTearHitParams(weap, dmg, tearDisp, source)

        if((params.TearFlags ~ otherParams.TearFlags) & otherParams.TearFlags ~= TearFlags.TEAR_NORMAL) then
            params.TearColor = otherParams.TearColor
            params.TearVariant = otherParams.TearVariant
            params.BombVariant = otherParams.BombVariant
        end

        params.TearFlags = params.TearFlags | otherParams.TearFlags
        params.TearDamage = math.max(params.TearDamage, otherParams.TearDamage)
        params.TearScale = math.max(params.TearScale, otherParams.TearScale)
    end
    cancelEval = false

    return params
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, evalParams)