local mod = MilcomMOD

local ENUM_MARKS_MAX = 25

local ENUM_MARKS_INCREASE = 1
local ENUM_MARKS_INCREASE_CATCHUP = 3

local ENUM_DMG_INCREASE = 0.04
local ENUM_DMG_DECREASE = 0.03

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(mod.COLLECTIBLE_LION_SKULL)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_LION_SKULL)
    local bonus = mod:getEntityData(player, "LION_SKULL_MARKS") or 0

    if(flag==CacheFlag.CACHE_DAMAGE) then
        local dmgIncrease = 0
        
        if(bonus<0) then dmgIncrease = bonus*ENUM_DMG_DECREASE
        else dmgIncrease = bonus*ENUM_DMG_INCREASE end

        player.Damage = player.Damage*(1+dmgIncrease)*mult
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function increaseLionMark(_, player)
    if(not player:HasCollectible(mod.COLLECTIBLE_LION_SKULL)) then return end

    local mult = player:GetCollectibleNum(mod.COLLECTIBLE_LION_SKULL)
    local bonus = mod:getEntityData(player, "LION_SKULL_MARKS") or 0

    if(bonus<0) then bonus = bonus+ENUM_MARKS_INCREASE_CATCHUP*mult
    else bonus = bonus+ENUM_MARKS_INCREASE*mult end

    bonus = math.min(bonus, ENUM_MARKS_MAX*mult)

    mod:setEntityData(player, "LION_SKULL_MARKS", bonus)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, increaseLionMark)

---@param player Entity
local function applyMarkPenalties(_, player, _, flags)
    player = player:ToPlayer()
    if(flags & (DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_FAKE ) ~= 0) then return end

    local bonus = mod:getEntityData(player, "LION_SKULL_MARKS") or 0

    if(bonus>0) then bonus = -bonus end

    mod:setEntityData(player, "LION_SKULL_MARKS", bonus)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, applyMarkPenalties, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_POST_RENDER,
function(_)
    --Isaac.RenderText(tostring(mod:getEntityData(Isaac.GetPlayer(),"LION_SKULL_MARKS")), 100, 30,1,1,1,1)
end
)