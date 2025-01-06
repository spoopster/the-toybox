local mod = MilcomMOD
local sfx = SFXManager()

local PICKUP_TABLE = {
    COIN =      {ID=1, StatMult=1, Name="Money", NumFunc="GetNumCoins"},
    BOMB =      {ID=2, StatMult=2.5, Name="Chaos", NumFunc="GetNumBombs"},
    KEY =       {ID=3, StatMult=3, Name="Answers", NumFunc="GetNumKeys"},
}
local STAT_TABLE = {
    SPEED =     {ID=1, StatVal=0.025, Name="Haste", Cache="CACHE_SPEED"},
    TEARS =     {ID=2, StatVal=0.05, Name="Sorrow", Cache="CACHE_FIREDELAY"},
    DAMAGE =    {ID=3, StatVal=0.05, Name="Power", Cache="CACHE_DAMAGE"},
    RANGE =     {ID=4, StatVal=0.05, Name="Distance", Cache="CACHE_RANGE"},
    SHOTSPEED = {ID=5, StatVal=0.025, Name="Velocity", Cache="CACHE_SHOTSPEED"},
    LUCK =      {ID=6, StatVal=0.05, Name="Fortune", Cache="CACHE_LUCK"},
}
local PICKUP_TO_KEY = {"COIN","BOMB","KEY"}
local PICKUP_PICKER = WeightedOutcomePicker()
PICKUP_PICKER:AddOutcomeWeight(1, 1)
PICKUP_PICKER:AddOutcomeWeight(2, 1)
PICKUP_PICKER:AddOutcomeWeight(3, 1)

local STAT_TO_KEY = {"SPEED","TEARS","DAMAGE","RANGE","SHOTSPEED","LUCK"}
local STAT_PICKER = WeightedOutcomePicker()
STAT_PICKER:AddOutcomeWeight(1, 1)
STAT_PICKER:AddOutcomeWeight(2, 1)
STAT_PICKER:AddOutcomeWeight(3, 1)
STAT_PICKER:AddOutcomeWeight(4, 1)
STAT_PICKER:AddOutcomeWeight(5, 1)
STAT_PICKER:AddOutcomeWeight(6, 1)

local function pickPickupStat(rng)
    local extraData = mod:getExtraDataTable()

    local prevPickup = extraData.EQUALIZER_PICKUP
    local prevStat = extraData.EQUALIZER_STAT

    while(extraData.EQUALIZER_PICKUP==prevPickup) do
        extraData.EQUALIZER_PICKUP = PICKUP_TO_KEY[PICKUP_PICKER:PickOutcome(rng)]
    end
    while(extraData.EQUALIZER_STAT==prevStat) do
        extraData.EQUALIZER_STAT = STAT_TO_KEY[STAT_PICKER:PickOutcome(rng)]
    end

    local toDisplay = PICKUP_TABLE[extraData.EQUALIZER_PICKUP].Name.." = "..STAT_TABLE[extraData.EQUALIZER_STAT].Name
    local item = Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_EQUALIZER)
    item.Description = toDisplay
end


local function postGameStarted(_, isCont)
    if(not isCont) then
        pickPickupStat(mod:generateRng())
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)

---@param player EntityPlayer
local function useEqualizer(_, _, rng, player, flags)
    pickPickupStat(rng)
    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)

    local item = Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_EQUALIZER)
    Game():GetHUD():ShowItemText(player, item)

    sfx:Play(SoundEffect.SOUND_POWERUP1)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useEqualizer, mod.COLLECTIBLE_EQUALIZER)

---@param player EntityPlayer
local function evalCache(_, player, flags)
    if(not player:HasCollectible(mod.COLLECTIBLE_EQUALIZER)) then return end

    if(not PICKUP_TABLE[mod:getExtraData("EQUALIZER_PICKUP")]) then
        pickPickupStat(player:GetCollectibleRNG(mod.COLLECTIBLE_EQUALIZER))
    end

    local pickupData = mod:getExtraData("EQUALIZER_PICKUP")
    local statData = mod:getExtraData("EQUALIZER_STAT")
    if(flags~=CacheFlag[STAT_TABLE[statData].Cache]) then return end

    local statMult = STAT_TABLE[statData].StatVal*PICKUP_TABLE[pickupData].StatMult*player[PICKUP_TABLE[pickupData].NumFunc](player)
    
    if(statData=="SPEED") then
        player.MoveSpeed = player.MoveSpeed+statMult
    elseif(statData=="TEARS") then
        mod:addBasicTearsUp(player, statMult)
    elseif(statData=="DAMAGE") then
        mod:addBasicDamageUp(player, statMult)
    elseif(statData=="RANGE") then
        player.TearRange = player.TearRange+40*statMult
    elseif(statData=="SHOTSPEED") then
        player.ShotSpeed = player.ShotSpeed+statMult
    elseif(statData=="LUCK") then
        player.Luck = player.Luck+statMult
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function updatePickups(_)
    local extraData = mod:getExtraDataTable()
    local pl = Isaac.GetPlayer()

    local numCoins = pl:GetNumCoins()
    local numBombs = pl:GetNumBombs()
    local numKeys = pl:GetNumKeys()

    if(PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE_EQUALIZER)) then
        if(numCoins~=extraData.EQUALIZER_COINS or numBombs~=extraData.EQUALIZER_BOMBS or numKeys~=extraData.EQUALIZER_KEYS) then
           for i=0, Game():GetNumPlayers()-1 do
                local player = Isaac.GetPlayer(i)
                if(player:HasCollectible(mod.COLLECTIBLE_EQUALIZER)) then
                    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
                end
           end
        end
    end

    extraData.EQUALIZER_COINS = numCoins
    extraData.EQUALIZER_BOMBS = numBombs
    extraData.EQUALIZER_KEYS = numKeys
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, updatePickups)