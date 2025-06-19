
local sfx = SFXManager()

local HALO_SIZE = 50
local RETALIATE_DMG = 1.5

---@param pl EntityPlayer
local function updateBarbedHalo(_, pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    local barbHalo = data.BARBED_HALO

    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_BARBED_WIRE)) then
        if(barbHalo and barbHalo:Exists()) then
            barbHalo:Remove()
            data.BARBED_HALO = nil
        end

        return
    end

    if(not (barbHalo and barbHalo:Exists())) then
        barbHalo = Isaac.Spawn(EntityType.ENTITY_EFFECT, ToyboxMod.EFFECT_VARIANT.BARBED_WIRE_HALO, 0, pl.Position, Vector.Zero, pl):ToEffect()
        barbHalo:FollowParent(pl)

        data.BARBED_HALO = barbHalo
    end

    barbHalo.SpriteRotation = (pl.FrameCount/2)%360
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateBarbedHalo)

---@param pl EntityPlayer
local function checkForBarbedProjectiles(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_BARBED_WIRE)) then return end

    for _, proj in ipairs(Isaac.FindInRadius(pl.Position, HALO_SIZE, EntityPartition.BULLET)) do
        local data = ToyboxMod:getEntityDataTable(proj)
        data.BARBED_BLACKLIST = data.BARBED_BLACKLIST or {}

        if(not data.BARBED_BLACKLIST[pl.InitSeed]) then
            data.BARBED_BLACKLIST[pl.InitSeed] = true

            local target = (proj.SpawnerEntity)
            if(target) then
                target:TakeDamage(RETALIATE_DMG*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_BARBED_WIRE), 0, EntityRef(pl), 0)

                local spawnPos = proj.Position+proj.Velocity+Vector(0, proj:ToProjectile().Height)
                local impact = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, spawnPos, Vector.Zero, nil)
                sfx:Play(SoundEffect.SOUND_TOOTH_AND_NAIL_TICK, 0.8, 1, false, 1.5-0.5*(target.HitPoints/target.MaxHitPoints))
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, checkForBarbedProjectiles)