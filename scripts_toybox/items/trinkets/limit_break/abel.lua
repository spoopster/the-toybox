
--* Fires Cricket's Body rock tears that deal 6 damage
local EXTRA_DMG = 2.5

---@param tear EntityTear
local function abelFireTear(_, tear)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToFamiliar())) then return end
    local fam = tear.SpawnerEntity:ToFamiliar()
    if(not (fam and fam.Player and ToyboxMod:playerHasLimitBreak(fam.Player))) then return end

    tear:ChangeVariant(TearVariant.ROCK)
    tear:AddTearFlags(TearFlags.TEAR_QUADSPLIT | TearFlags.TEAR_SPECTRAL)
    tear.CollisionDamage = tear.CollisionDamage+EXTRA_DMG
    tear.Scale = 1.1
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE, abelFireTear, FamiliarVariant.ABEL)