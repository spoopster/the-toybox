local mod = MilcomMOD

local ENUM_FIREDELAY_MULT = 5/4
local ENUM_DAMAGE_MULT = 4/5

local ENUM_FIREDELAY_ROOT = 8
local ENUM_DAMAGE_ROOT = 11

local ENUM_BONUSTOADD_POWER = 2

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_CONDENSED_MILK)

    local bonus = mod:getData(player, "CONDENSED_MILK_BONUS") or 1
    if(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = player.MaxFireDelay*(ENUM_FIREDELAY_MULT^mult)/(bonus^(1/ENUM_FIREDELAY_ROOT))
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*(ENUM_DAMAGE_MULT^mult)*(bonus^(1/ENUM_DAMAGE_ROOT))
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param tear EntityTear
local function milkBonusTearsLogic(_, tear)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())) then return end

    local player = tear.SpawnerEntity:ToPlayer()
    if(not player:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_CONDENSED_MILK)

    mod:setData(player, "CONDENSED_MILK_BONUS", (mod:getData(player, "CONDENSED_MILK_BONUS") or 1)+mult^ENUM_BONUSTOADD_POWER)
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE, true)
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, milkBonusTearsLogic)

---@param player EntityPlayer
local function milkBonusUpdateLogic(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_CONDENSED_MILK)) then
        if(mod:getData(player, "CONDENSED_MILK_BONUS")~=nil) then
            mod:setData(player, "CONDENSED_MILK_BONUS", nil)
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE, true)
        end

        return
    end

    local data = mod:getDataTable(player)
    data.CONDENSED_MILK_BONUS = data.CONDENSED_MILK_BONUS or 1

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_CONDENSED_MILK)

    if(player:GetFireDirection()==Direction.NO_DIRECTION) then
        data.CONDENSED_MILK_BONUS = math.max(1,data.CONDENSED_MILK_BONUS-1/2)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE, true)
    elseif(not (player:HasWeaponType(WeaponType.WEAPON_TEARS))) then
        data.CONDENSED_MILK_BONUS = data.CONDENSED_MILK_BONUS+(mult^ENUM_BONUSTOADD_POWER)/(math.max(player.MaxFireDelay,1))
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_DAMAGE, true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, milkBonusUpdateLogic)