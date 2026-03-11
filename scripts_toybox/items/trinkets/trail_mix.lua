local HEARTS_ON_PICKUP = 1

local HEARTS_ON_LEVEL = 1
local HEARTS_PER_MULT = 1

local SUB_PICKER = WeightedOutcomePicker()
for i=0, 2000 do
    local conf = EntityConfig.GetEntity(5,PickupVariant.PICKUP_HEART,i)
    if(conf and conf:GetVariant()==PickupVariant.PICKUP_HEART) then
        SUB_PICKER:AddOutcomeWeight(i, 1)
    end
end

---@param pl EntityPlayer
---@param firstTime boolean
local function giveHeartsOnPickup(_, pl, _, firstTime)
    if(not firstTime) then return end

    local room = Game():GetRoom()

    local rng = pl:GetTrinketRNG(ToyboxMod.TRINKET_TRAIL_MIX)

    for i=1, HEARTS_ON_PICKUP do
        local sub = SUB_PICKER:PickOutcome(rng)
        local heart = Isaac.Spawn(5,10,sub,room:FindFreePickupSpawnPosition(pl.Position,40),Vector.Zero,nil):ToPickup()
        heart:SetDropDelay(2*(i-1))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, giveHeartsOnPickup, ToyboxMod.TRINKET_TRAIL_MIX)

local function giveHeartsOnNewLevel(_)
    if(not Game():GetRoom():IsFirstVisit()) then return end
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_TRAIL_MIX)) then return end

    local room = Game():GetRoom()

    local pl = PlayerManager.FirstTrinketOwner(ToyboxMod.TRINKET_TRAIL_MIX)
    local rng = pl:GetTrinketRNG(ToyboxMod.TRINKET_TRAIL_MIX)

    local numHearts = HEARTS_ON_LEVEL+HEARTS_PER_MULT*(PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_TRAIL_MIX)-1)

    local maxTime = 10
    local timeBetweenHearts = 2
    if(numHearts*timeBetweenHearts>=maxTime) then
        timeBetweenHearts = maxTime/numHearts
    end

    for i=1, numHearts do
        local sub = SUB_PICKER:PickOutcome(rng)
        local heart = Isaac.Spawn(5,10,sub,room:FindFreePickupSpawnPosition(pl.Position,40),Vector.Zero,nil):ToPickup()
        heart:SetDropDelay((timeBetweenHearts*(i-1)+0.5)//1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, giveHeartsOnNewLevel)