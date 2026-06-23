local STATS_PICKER = {"SPEED","TEARS","DAMAGE","RANGE"}

local STATS_DATA = {
    DAMAGE =    {PerUnit = 0.04, Color = KColor(1,0,0,1), Flag = CacheFlag.CACHE_DAMAGE},
    TEARS =     {PerUnit = 0.04, Color = KColor(0.45,0.55,1,1), Flag = CacheFlag.CACHE_FIREDELAY},
    RANGE =     {PerUnit = 0.1, Color = KColor(1,0.5,0,1), Flag = CacheFlag.CACHE_RANGE},
    SPEED =     {PerUnit = 0.03, Color =KColor(0.9,1,0,1), Flag = CacheFlag.CACHE_SPEED},
}
local PICKUPS_DATA = {
    COIN =  {UnitMult = 1, Func = "GetNumCoins", MaxFunc = "GetMaxCoins", Frame=0, Pos=0},
    BOMB =  {UnitMult = 3, Func = "GetNumBombs", MaxFunc = "GetMaxBombs", Frame=2, Pos=1},
    KEY =   {UnitMult = 3, Func = "GetNumKeys", MaxFunc = "GetMaxKeys", Frame=1, Pos=2,},
}

---@param pl EntityPlayer
---@param stat string
---@return number
local function getTotalValueForStat(pl, stat)
    local val = 0

    local statTable = ToyboxMod:getEntityData(pl, "BEN_STATS") or {}
    for pickup, pstat in pairs(statTable) do
        if(pstat==stat) then
            val = val+STATS_DATA[stat].PerUnit*PICKUPS_DATA[pickup].UnitMult*pl[PICKUPS_DATA[pickup].Func](pl)
        end
    end

    return val
end

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(flag & (CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE) == 0) then return end
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_BEN_REED)) then return end

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+getTotalValueForStat(player, "SPEED")
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+getTotalValueForStat(player, "RANGE")*40
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, stat, val)
    if(not (stat==EvaluateStatStage.TEARS_UP or stat==EvaluateStatStage.DAMAGE_UP)) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_BEN_REED)) then return end

    if(stat==EvaluateStatStage.TEARS_UP) then
        return val+getTotalValueForStat(pl, "TEARS")
    elseif(stat==EvaluateStatStage.DAMAGE_UP) then
        return val+getTotalValueForStat(pl, "DAMAGE")
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat)

---@param pl EntityPlayer
local function checkLoweredCounters(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_BEN_REED)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    local currentCounters = {
        COIN = pl:GetNumCoins(),
        BOMB = pl:GetNumBombs(),
        KEY = pl:GetNumKeys(),
    }
    data.BEN_COUNTERS = data.BEN_COUNTERS or {}
    data.BEN_STATS = data.BEN_STATS or {}

    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_BEN_REED)

    local finalFlags = 0
    for pickup, pval in pairs(currentCounters) do
        data.BEN_COUNTERS[pickup] = data.BEN_COUNTERS[pickup] or 0
        if(data.BEN_COUNTERS[pickup]~=pval) then
            if(STATS_DATA[data.BEN_STATS[pickup]]) then
                finalFlags = finalFlags | STATS_DATA[data.BEN_STATS[pickup]].Flag
            end

            if(data.BEN_COUNTERS[pickup]>pval) then
                local stat = data.BEN_STATS[pickup]
                while(stat==data.BEN_STATS[pickup]) do
                    stat = STATS_PICKER[rng:RandomInt(1,#STATS_PICKER)]
                end

                data.BEN_STATS[pickup] = stat
                finalFlags = finalFlags | STATS_DATA[stat].Flag
            end
        end
    end

    if(finalFlags~=0) then
        pl:AddCacheFlags(finalFlags, true)
    end

    data.BEN_COUNTERS = {
        COIN = pl:GetNumCoins(),
        BOMB = pl:GetNumBombs(),
        KEY = pl:GetNumKeys(),
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, checkLoweredCounters)

---@param id CollectibleType
---@param firstTime boolean
---@param pl EntityPlayer
local function addBenReed(_, id, _, firstTime, _, _, pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    if(firstTime and pl:GetCollectibleNum(id)==1) then
        local rng = pl:GetCollectibleRNG(id)
        data.BEN_STATS = {
            COIN = STATS_PICKER[rng:RandomInt(1,#STATS_PICKER)],
            BOMB = STATS_PICKER[rng:RandomInt(1,#STATS_PICKER)],
            KEY = STATS_PICKER[rng:RandomInt(1,#STATS_PICKER)],
        }
    end

    for _, stat in pairs(data.BEN_STATS or {}) do
        if(STATS_DATA[stat]) then
            pl:AddCacheFlags(STATS_DATA[stat].Flag, false)
        end
    end
    pl:EvaluateItems()
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addBenReed, ToyboxMod.COLLECTIBLE_BEN_REED)

local PICKUPS_FONT = Font()
PICKUPS_FONT:Load("font/pftempestasevencondensed.fnt")

local GRAY_COLOR = KColor(0.5,0.5,0.5,1)

local function hudRender(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_BEN_REED)) then return end
    if(not ToyboxMod.GAME:GetHUD():IsVisible()) then return end

    local pl = PlayerManager.FirstCollectibleOwner(ToyboxMod.COLLECTIBLE_BEN_REED)
    local data = ToyboxMod:getEntityDataTable(pl)

    local renderPos = Vector(20,12)*Options.HUDOffset + Vector(16,33) + Vector(2,2)
    if(REPENTANCE_PLUS) then
        renderPos = renderPos+Vector(0,2)
    end

    local sp = ToyboxMod.GAME:GetHUD():GetPickupsHUDSprite()

    for pickup, stat in pairs(data.BEN_STATS or {}) do
        local pickupText = tostring(pl[PICKUPS_DATA[pickup].Func](pl))
        local pickupMaxLength = math.ceil(math.log(pl[PICKUPS_DATA[pickup].MaxFunc](pl)+1, 10))
        local pickupTextLength = string.len(pickupText)

        for _=pickupTextLength+1, pickupMaxLength do
            pickupText = "0"..pickupText
        end

        local color = STATS_DATA[stat] and STATS_DATA[stat].Color or Color.Default

        sp:SetFrame("Idle", PICKUPS_DATA[pickup].Frame)
        sp.Color = Color(1,1,1,178/255,color.Red,color.Green,color.Blue)
        sp:Render(renderPos+Vector(-17,PICKUPS_DATA[pickup].Pos*12-3))
        sp.Color = Color.Default

        PICKUPS_FONT:DrawString(pickupText, renderPos.X+ToyboxMod.GAME.ScreenShakeOffset.X, renderPos.Y+ToyboxMod.GAME.ScreenShakeOffset.Y+PICKUPS_DATA[pickup].Pos*12, color)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_HUD_RENDER, hudRender)