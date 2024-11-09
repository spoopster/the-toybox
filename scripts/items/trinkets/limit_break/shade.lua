local mod = MilcomMOD
--* When hitting enemies, Shade has a chance to apply fear to them
--* When killing enemies, Shade has a chance to spawn a shadow charger

local SHADE_FEARCHANCE = 1/6
local SHADE_CHARGERCHANCE = 1/2

---@param ent Entity
local function shadeDealDamage(_, ent, amount, flags, source)
    if(not (source.Entity and source.Entity.Type==EntityType.ENTITY_FAMILIAR and source.Entity.Variant==FamiliarVariant.SHADE)) then return end
    local sh = source.Entity:ToFamiliar()
    if(not (sh.Player and mod:playerHasLimitBreak(sh.Player))) then return end
    local rng = sh.Player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SHADE)

    if(amount>=ent.HitPoints) then
        if(rng:RandomFloat()<SHADE_CHARGERCHANCE) then
            local charger = Isaac.Spawn(23,0,1,ent.Position,Vector.Zero,nil):ToNPC()
            charger:AddCharmed(EntityRef(sh.Player), -1)
        end
    elseif(rng:RandomFloat()<SHADE_FEARCHANCE) then
        ent:AddFear(EntityRef(sh.Player), 90)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, shadeDealDamage)