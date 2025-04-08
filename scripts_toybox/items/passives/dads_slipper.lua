local mod = ToyboxMod
local sfx = SFXManager()

local SHOTSPEED_UP = 0.16
--local BOSS_DMG = 80

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(flag~=CacheFlag.CACHE_SHOTSPEED) then return end
    if(not pl:HasCollectible(mod.COLLECTIBLE.DADS_SLIPPER)) then return end

    pl.ShotSpeed = pl.ShotSpeed+SHOTSPEED_UP*pl:GetCollectibleNum(mod.COLLECTIBLE.DADS_SLIPPER)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl Entity
---@param source EntityRef
local function postTakeDmg(_, pl, dmg, flags, source, countdown)
    if(not source.Entity) then return end

    pl = pl:ToPlayer() ---@cast pl EntityPlayer
    if(not pl:HasCollectible(mod.COLLECTIBLE.DADS_SLIPPER)) then return end

    local ent = source.Entity
    if(not ent:ToNPC() and ent.SpawnerEntity) then
        ent = ent.SpawnerEntity
    end
    ent = ent:ToNPC() ---@cast ent EntityNPC

    if(ent and mod:isValidEnemy(ent) and not ent:IsBoss()) then
        ent:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
        ent:BloodExplode()
        ent:Die()

        sfx:Play(mod.SOUND_EFFECT.SLIPPER_WHIP, 1.2)
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TAKE_DMG, postTakeDmg, EntityType.ENTITY_PLAYER)