

local TEAR_CAP = 5*2
local TEARS_UP = 1

local function firedelayToTears(fd)
    local tearsStat
    if(fd<=10) then
        tearsStat = (((16-fd)^2)/36-1)/1.3
    elseif(fd<=16+6/1.3) then
        local a = 1
        local b = -(16-fd)/3-1.3
        local c = ((16-fd)/6)^2-1
        tearsStat = (-b-math.sqrt(b*b-4*a*c))/(2*a)
    else
        tearsStat = (16-fd)/6
    end

    return tearsStat
end
local function tearsToFiredelay(tears)
    local fdStat
    if(tears>=0) then
        fdStat = 16-6*math.sqrt(tears*1.3+1)
    elseif(tears>-1/1.3) then
        fdStat = 16-6*math.sqrt(tears*1.3+1)-6*tears
    else
        fdStat = 16-6*tears
    end

    return fdStat
end

local ignoreTearCalc = false

---@param pl EntityPlayer
local function evalCache(_, pl)
    if(ignoreTearCalc) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_CATHARSIS)) then return end
    ignoreTearCalc = true

    local tearsMult = ToyboxMod:getVanillaTearMultiplier(pl)
    local ogFiredelay = pl.MaxFireDelay
    local numAdded = 0
    while(pl.MaxFireDelay==ogFiredelay) do
        numAdded = numAdded+1
        pl:AddCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART, 0, false)
    end

    local newTears = firedelayToTears(ToyboxMod:toFireDelay(ToyboxMod:toTps(pl.MaxFireDelay)/tearsMult))
    local finalTearsStat = newTears+0.4*numAdded

    for _=1, numAdded do pl:RemoveCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART, true, 0, false) end

    local finalTps = ToyboxMod:toTps(tearsToFiredelay(finalTearsStat))*tearsMult
    pl.MaxFireDelay = ToyboxMod:toFireDelay(math.min(finalTps, TEAR_CAP*tearsMult))

    ToyboxMod:addBasicTearsUp(pl, TEARS_UP*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_CATHARSIS))

    ignoreTearCalc = false
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, -math.huge, evalCache, CacheFlag.CACHE_FIREDELAY)