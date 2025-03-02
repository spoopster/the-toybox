local mod = MilcomMOD

local ENUM_MARKS_MAX = 20

local ENUM_MARKS_INCREASE = 1
local ENUM_MARKS_INCREASE_CATCHUP = 3

local ENUM_DMG_INCREASE = 0.15
local ENUM_DMG_DECREASE = 0.15

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE.LION_SKULL)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE.LION_SKULL)
    local bonus = mod:getEntityData(player, "LION_SKULL_MARKS") or 0

    if(flag==CacheFlag.CACHE_DAMAGE) then
        local dmgIncrease = 0
        
        if(bonus<0) then dmgIncrease = bonus*ENUM_DMG_DECREASE
        else dmgIncrease = bonus*ENUM_DMG_INCREASE end

        mod:addBasicDamageUp(player, dmgIncrease)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function increaseLionMark(_)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasCollectible(mod.COLLECTIBLE.LION_SKULL)) then
            local mult = pl:GetCollectibleNum(mod.COLLECTIBLE.LION_SKULL)
            local bonus = mod:getEntityData(pl, "LION_SKULL_MARKS") or 0

            if(bonus<0) then bonus = math.min(0, bonus+ENUM_MARKS_INCREASE_CATCHUP)
            else bonus = bonus+ENUM_MARKS_INCREASE*mult end
            bonus = math.min(bonus, ENUM_MARKS_MAX*mult)
            mod:setEntityData(pl, "LION_SKULL_MARKS", bonus)

            pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ROOM_CLEAR, increaseLionMark)

---@param player Entity
local function applyMarkPenalties(_, player, _, flags, source)
    player = player:ToPlayer()
    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    local bonus = mod:getEntityData(player, "LION_SKULL_MARKS") or 0
    if(bonus>0) then bonus = -bonus end
    mod:setEntityData(player, "LION_SKULL_MARKS", bonus)

    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, applyMarkPenalties, EntityType.ENTITY_PLAYER)