local mod = MilcomMOD

mod.PILL_PHDTYPE = {
    NEUTRAL=1<<1,
    GOOD=1<<2,
    BAD=1<<3,
    NONE=1<<1|1<<2|1<<3,
}

function mod:getAllPillEffects(phdEffect)
    local itemConf = Isaac.GetItemConfig()

    phdEffect = phdEffect or mod.PILL_PHDTYPE.NONE

    local pillEffects = {}
    local currentpill = itemConf:GetPillEffect(0)
    while(currentpill) do
        if((phdEffect & mod.PILL_PHDTYPE.NEUTRAL~=0 and currentpill.EffectSubClass==mod.PILL_SUBCLASS.NEUTRAL)
        or (phdEffect & mod.PILL_PHDTYPE.GOOD~=0 and currentpill.EffectSubClass==mod.PILL_SUBCLASS.GOOD)
        or (phdEffect & mod.PILL_PHDTYPE.BAD~=0 and currentpill.EffectSubClass==mod.PILL_SUBCLASS.BAD)) then
            table.insert(pillEffects,
                {
                    ID = currentpill.ID,
                    CLASS = currentpill.EffectClass,
                    SUBCLASS = currentpill.EffectSubClass,
                    NAME = currentpill.Name,
                }
            )
        end
        currentpill = itemConf:GetPillEffect(currentpill.ID+1)
    end

    return pillEffects
end
function mod:getPillColorsInRun()
    local itemConf = Isaac.GetItemConfig()
    local itemPool = Game():GetItemPool()

    local pillColorsInPool = {}
    local currentpill = itemConf:GetPillEffect(0)
    while(currentpill) do
        local assocCol = itemPool:GetPillColor(currentpill.ID)
        if(assocCol~=-1 and assocCol~=PillColor.PILL_GOLD) then
            table.insert(pillColorsInPool,
                {
                    COLOR = assocCol,
                    BASEEFFECT = currentpill.Name,
                }
            )
        end
        currentpill = itemConf:GetPillEffect(currentpill.ID+1)
    end

    return pillColorsInPool
end
function mod:getPlayerPhdMask(player)
    local mask = 0

    if(player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:GetPlayerType()==mod.PLAYER_JONAS_A) then return mod.PILL_PHDTYPE.GOOD end

    if(player:HasCollectible(CollectibleType.COLLECTIBLE_PHD)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_VIRGO)
    or player:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT)) then
        mask = mask | (mod.PILL_PHDTYPE.GOOD|mod.PILL_PHDTYPE.NEUTRAL)
    end
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_FALSE_PHD)) then
        mask = mask | (mod.PILL_PHDTYPE.BAD|mod.PILL_PHDTYPE.NEUTRAL)
    end
    if(mask==0) then mask = mod.PILL_PHDTYPE.NONE end

    return mask
end
function mod:getTotalPhdMask()
    local mask = mod.PILL_PHDTYPE.NONE
    for i, player in ipairs(Isaac.FindByType(1,0)) do
        mask = mask & mod:getPlayerPhdMask(player:ToPlayer())
        if(mask==0) then mask=mod.PILL_PHDTYPE.NONE end
    end
    return mask
end

-- base game is approx bad=4-5, neutral=2-3, good=6-7, 
function mod:calcPillPool(rng, numBadPills, numNeutralPills, numGoodPills, phdEffect)
    phdEffect = phdEffect or mod.PILL_PHDTYPE.NONE
    if(phdEffect == mod.PILL_PHDTYPE.BAD) then
        numBadPills = numBadPills+numNeutralPills+numGoodPills; numNeutralPills=0; numGoodPills=0
    elseif(phdEffect == mod.PILL_PHDTYPE.NEUTRAL) then
        numNeutralPills = numBadPills+numNeutralPills+numGoodPills; numBadPills=0; numGoodPills=0
    elseif(phdEffect == mod.PILL_PHDTYPE.GOOD) then
        numGoodPills = numBadPills+numNeutralPills+numGoodPills; numBadPills=0; numNeutralPills=0
    elseif(phdEffect == mod.PILL_PHDTYPE.BAD|mod.PILL_PHDTYPE.NEUTRAL) then
        numBadPills = numBadPills+math.floor(numGoodPills/2); numNeutralPills = numNeutralPills+math.ceil(numGoodPills/2); numGoodPills=0
    elseif(phdEffect == mod.PILL_PHDTYPE.BAD|mod.PILL_PHDTYPE.GOOD) then
        numBadPills = numBadPills+math.floor(numNeutralPills/2); numGoodPills = numGoodPills+math.ceil(numNeutralPills/2); numNeutralPills=0
    elseif(phdEffect == mod.PILL_PHDTYPE.NEUTRAL|mod.PILL_PHDTYPE.GOOD) then
        numNeutralPills = numNeutralPills+math.floor(numBadPills/2); numGoodPills = numGoodPills+math.ceil(numBadPills/2); numBadPills=0
    end

    rng = rng or mod:generateRng()
    local numPillsByQuality = {[0]=(numNeutralPills or 3), [1]=(numGoodPills or 4), [2]=(numBadPills or 6)}

    local pillColorsInPool = mod:getPillColorsInRun()
    local pillEffects = mod:getAllPillEffects(phdEffect)

    local finalPool = {}
    for _, val in ipairs(pillColorsInPool) do
        --print("NEUTRAL: ", numPillsByQuality[0], "; GOOD: ", numPillsByQuality[1], "; BAD: ", numPillsByQuality[2])
        local failsafe = 100000
        local chosenPill, chosenIdx
        repeat
            chosenIdx = rng:RandomInt(#pillEffects)+1
            chosenPill = pillEffects[chosenIdx]
            failsafe = failsafe-1
        until(failsafe==0 or (chosenPill and chosenPill.SUBCLASS~=-1 and numPillsByQuality[chosenPill.SUBCLASS]>0))

        --print(chosenPill.SUBCLASS, chosenPill.ID, chosenPill.NAME)

        numPillsByQuality[chosenPill.SUBCLASS] = (numPillsByQuality[chosenPill.SUBCLASS] or 0)-1
        pillEffects[chosenIdx].SUBCLASS = -1

        finalPool[val.COLOR] = chosenPill.ID
    end
    mod:setExtraData("CUSTOM_PILL_POOL", finalPool)
end

local function replacePillEffect(_, pilleffect, color)
    local pillpool = mod:getExtraData("CUSTOM_PILL_POOL")
    if(pillpool) then
        if(color==PillColor.PILL_GOLD or color==PillColor.PILL_GOLD|PillColor.PILL_GIANT_FLAG) then
            local rng = mod:generateRng()
            local totalEffects = mod:getAllPillEffects(mod:getTotalPhdMask())
            local poolEffects = {}
            for _, effect in pairs(pillpool) do poolEffects[effect]=-1 end

            local filteredEffects = {}
            for _, effect in ipairs(totalEffects) do
                if(poolEffects[effect.ID]~=-1) then table.insert(filteredEffects, effect.ID) end
            end

            local rInt = rng:RandomInt(#filteredEffects)+1
            --print(rInt, filteredEffects[rInt])
            return filteredEffects[rInt]
        end
        if(pillpool[color]) then return pillpool[color] end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_GET_PILL_EFFECT, CallbackPriority.LATE, replacePillEffect)

--[[
mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if(mod:getExtraData("CUSTOM_PILL_POOL")) then
        local y = 60
        local totaleff = mod:getAllPillEffects()
        for i, val in ipairs(mod:getExtraData("CUSTOM_PILL_POOL")) do
            local name="-"
            for _, eff in ipairs(totaleff) do if(eff.ID==val) then name=eff.NAME end end

            Isaac.RenderText(tostring(i).." : "..tostring(val).."; "..name, 70, y, 1,1,1,1)
            y = y+10
        end
        if(Isaac.GetPlayer():GetPlayerType()~=mod.PLAYER_JONAS_A) then return end
        local data = mod:getJonasATable(Isaac.GetPlayer())
        Isaac.RenderText((data.PILLS_POPPED or 0).." "..(data.PILL_BONUS_COUNT or 0).." "..(data.PILLS_FOR_NEXT_BONUS or 0).." "..(data.RESET_BOOST_ROOMS or 0), 70, y, 1,1,1,1)
    end
end)

---@param player EntityPlayer
local function postJonasInit(_, player)
    --mod:calcPillPool()
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postJonasInit)
--]]