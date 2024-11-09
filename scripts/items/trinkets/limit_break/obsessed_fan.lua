local mod = MilcomMOD
--* When hitting enemies, Obsessed Fan has a chance to apply charm to them

local OBSFAN_CHARMCHANCE = 1/2

---@param ent Entity
local function obsessedFanDealDamage(_, ent, amount, flags, source)
    if(not (source.Entity and source.Entity.Type==EntityType.ENTITY_FAMILIAR and source.Entity.Variant==FamiliarVariant.OBSESSED_FAN)) then return end
    local sh = source.Entity:ToFamiliar()
    if(not (sh.Player and mod:playerHasLimitBreak(sh.Player))) then return end
    local rng = sh.Player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_OBSESSED_FAN)

    if(amount<ent.HitPoints and rng:RandomFloat()<OBSFAN_CHARMCHANCE) then
        ent:AddCharmed(EntityRef(sh.Player), 90)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, obsessedFanDealDamage)