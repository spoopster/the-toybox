local RANGE_UP = 30*2

local FART_INTERVAL = 5*30
local RANDOM_INTERVAL_INCREASE = 5*30

local FART_RADIUS = 100

---@param pl EntityPlayer
local function cacheEval(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_LOOSE_BOWELS)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_LOOSE_BOWELS)
    pl.TearRange = pl.TearRange+mult*RANGE_UP
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheEval, CacheFlag.CACHE_RANGE)

---@param pl EntityPlayer
local function postPeffectUpdate(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_LOOSE_BOWELS)) then return end
    local data = ToyboxMod:getEntityDataTable(pl)
    if((pl.FrameCount-(data.LAST_INTERVAL or 0))%(data.NEXT_INTERVAL or FART_INTERVAL)~=0) then return end

    Game():ButterBeanFart(pl.Position, FART_RADIUS, pl,false,false)
    Game():Fart(pl.Position, FART_RADIUS, pl)

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_LOOSE_BOWELS)
    data.NEXT_INTERVAL = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_LOOSE_BOWELS):RandomInt(0, RANDOM_INTERVAL_INCREASE)+FART_INTERVAL
    data.NEXT_INTERVAL = data.NEXT_INTERVAL//mult

    data.LAST_INTERVAL = pl.FrameCount
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)