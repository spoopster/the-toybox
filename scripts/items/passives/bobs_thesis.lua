local mod = ToyboxMod
local sfx = SFXManager()

local PLACEHOLDER_GIVING_ITEM = false
local PLACEHOLDER_GIVE_ITEM_FREQ = 15
local PLACEHOLDER_FAST_THRESHOLD = 3*30

local PLACEHOLDER_SPEED = 0.15
local PLACEHOLDER_TEARS = 0.5
local PLACEHOLDER_DMG = 0.5
local PLACEHOLDER_RANGE = 1
local PLACEHOLDER_SHOTSPEED = 0.1
local PLACEHOLDER_LUCK = 1

---@param poolType ItemPoolType
---@param dec boolean
---@param seed integer
local function getCollectibleSpawn(_, poolType, dec, seed)
    if(PLACEHOLDER_GIVING_ITEM) then return end

    if(PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.BOBS_THESIS)) then
        return mod.COLLECTIBLE.PLACEHOLDER
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_GET_COLLECTIBLE, CallbackPriority.IMPORTANT, getCollectibleSpawn)

---@param pl EntityPlayer
---@param flag CacheFlag
local function givePlaceholderStats(_, pl, flag)
    if(not pl:HasCollectible(mod.COLLECTIBLE.PLACEHOLDER)) then return end

    local mult = pl:GetCollectibleNum(mod.COLLECTIBLE.PLACEHOLDER)*math.max(1, pl:GetCollectibleNum(mod.COLLECTIBLE.BOBS_THESIS))

    if(flag==CacheFlag.CACHE_SPEED) then
        pl.MoveSpeed = pl.MoveSpeed+mult*PLACEHOLDER_SPEED
    elseif(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(pl, mult*PLACEHOLDER_TEARS)
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(pl, mult*PLACEHOLDER_DMG)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        pl.TearRange = pl.TearRange+mult*40*PLACEHOLDER_RANGE
    elseif(flag==CacheFlag.CACHE_SHOTSPEED) then
        pl.ShotSpeed = pl.ShotSpeed+mult*PLACEHOLDER_SHOTSPEED
    elseif(flag==CacheFlag.CACHE_LUCK) then
        pl.Luck = pl.Luck+mult*PLACEHOLDER_LUCK
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, givePlaceholderStats)

---@param pl EntityPlayer
local function stopHoldingThePlaces(_, pl)
    if(pl.FrameCount==0) then return end
    if(not pl:HasCollectible(mod.COLLECTIBLE.PLACEHOLDER)) then return end
    local data = mod:getEntityDataTable(pl)
    data.PLACEHOLDER_POOLS = data.PLACEHOLDER_POOLS or {}

    local history = pl:GetHistory():GetCollectiblesHistory()
    for i=1, #history do
        local item = history[i]
        if(item:GetItemID()==mod.COLLECTIBLE.PLACEHOLDER) then
            table.insert(data.PLACEHOLDER_POOLS, item:GetItemPoolType())
            pl:RemoveCollectible(mod.COLLECTIBLE.PLACEHOLDER)
        end
    end

    data.PLACEHOLDER_FREQ = PLACEHOLDER_GIVE_ITEM_FREQ
    if((#data.PLACEHOLDER_POOLS)*PLACEHOLDER_GIVE_ITEM_FREQ>PLACEHOLDER_FAST_THRESHOLD) then
        data.PLACEHOLDER_FREQ = PLACEHOLDER_FAST_THRESHOLD/(#data.PLACEHOLDER_POOLS)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, stopHoldingThePlaces)

---@param pl EntityPlayer
local function giveThePlaces(_, pl)
    local data = mod:getEntityDataTable(pl)
    data.PLACEHOLDER_POOLS = data.PLACEHOLDER_POOLS or {}
    if(not data.PLACEHOLDER_POOLS[1]) then return end
    if(pl.FrameCount%(data.PLACEHOLDER_FREQ or PLACEHOLDER_GIVE_ITEM_FREQ)~=0) then return end

    local poolType = data.PLACEHOLDER_POOLS[1]
    table.remove(data.PLACEHOLDER_POOLS, 1)

    PLACEHOLDER_GIVING_ITEM = true
    local itemToGive = Game():GetItemPool():GetCollectible(poolType, true)
    PLACEHOLDER_GIVING_ITEM = false

    local conf = Isaac.GetItemConfig():GetCollectible(itemToGive)
    if(conf.Type==ItemType.ITEM_ACTIVE and pl:GetActiveItem(ActiveSlot.SLOT_PRIMARY)~=0) then
        pl:DropCollectible(pl:GetActiveItem(ActiveSlot.SLOT_PRIMARY))
    end
    pl:AddCollectible(itemToGive)

    pl:AnimateCollectible(itemToGive)
    sfx:Play(SoundEffect.SOUND_POWERUP1)
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, giveThePlaces)