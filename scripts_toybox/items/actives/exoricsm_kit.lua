local mod = ToyboxMod
local sfx = SFXManager()

local ENEMY_DAMAGE = 40
local HOLY_COLORMOD = ColorModifier(1, 1, 1, 0.5, 0.5, 1.5)

---@param rng RNG
---@param pl EntityPlayer
local function exorcismUse(_, _, rng, pl, flags, slot, vdata)
    local nearestEnemy = mod:closestEnemy(pl.Position) ---@type EntityNPC?
    if(not nearestEnemy) then
        return {
            Discharge = false,
            ShowAnim = true,
            Remove = false,
        }
    end

    for _, enemy in ipairs(Isaac.FindByType(nearestEnemy.Type, nearestEnemy.Variant)) do
        local light = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CRACK_THE_SKY,0, enemy.Position, Vector.Zero, pl):ToEffect()
        for _=1, 5 do light:Update() end

        enemy:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
        enemy:BloodExplode()
        if(not enemy:IsBoss()) then
            enemy:Die()
        else
            enemy:TakeDamage(ENEMY_DAMAGE, 0, EntityRef(pl), 0)
        end
        --enemy:ClearEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
    end

    sfx:Play(SoundEffect.SOUND_SUPERHOLY)
    Game():ShakeScreen(20)

    return {
        Discharge = true,
        ShowAnim = true,
        Remove = false,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, exorcismUse, mod.COLLECTIBLE.EXORCISM_KIT)