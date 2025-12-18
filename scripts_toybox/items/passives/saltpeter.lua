local RANGE_UP = 1.5

local AOE_DMG_MULT = 0.5
--local AOE_RADIUS = 40*2
local AOE_RANGE_MULT = 0.25
local AOE_DMG_COLOR = Color(1.25,1.25,1.2,1,0.12,0.12,0.09)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_SALTPETER)) then return end
    local mult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SALTPETER)

    player.TearRange = player.TearRange+RANGE_UP*40*mult
end
--ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_RANGE)

---@param ent Entity
---@param dmg number
---@param flags DamageFlag
---@param source EntityRef
---@param cooldown integer
local function dealAOEdmg(_, ent, dmg, flags, source, cooldown)
    if(flags & DamageFlag.DAMAGE_CLONES ~= 0) then return end

    local pl = ToyboxMod:getPlayerFromEnt(source.Entity)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_SALTPETER))) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SALTPETER)
    local damage = dmg*AOE_DMG_MULT*mult
    local radius = AOE_RANGE_MULT*pl.TearRange*mult
    for _, near in ipairs(Isaac.FindInRadius(ent.Position, radius, EntityPartition.ENEMY)) do
        if(GetPtrHash(near)~=GetPtrHash(ent)) then
            near:TakeDamage(damage, flags | DamageFlag.DAMAGE_CLONES, source, cooldown)
            near:SetColor(AOE_DMG_COLOR, 10, 5, true, false)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, dealAOEdmg)