local mod = ToyboxMod

local BASE_BEAM_COOLDOWN = 7*30
local BEAMS_NUM = 2
local BEAM_DAMAGE = 7

local function postUpdate(_)
    if(not PlayerManager.AnyoneHasCollectible(mod.COLLECTIBLE.BLESSED_RING)) then return end
    if(mod:isRoomClear()) then return end

    local cool = math.floor(BASE_BEAM_COOLDOWN/(PlayerManager.GetNumCollectibles(mod.COLLECTIBLE.BLESSED_RING)))
    if(cool<1) then cool=1 end

    if((Game():GetRoom():GetFrameCount()-1)%cool~=0) then return end
    local r = Game():GetRoom()
    local p = PlayerManager.FirstCollectibleOwner(mod.COLLECTIBLE.BLESSED_RING)
    local rng = p:GetCollectibleRNG(mod.COLLECTIBLE.BLESSED_RING)

    local enemyBlacklists = {}
    local pickedEnemies = {}
    local enemies = mod:getAllValidEnemies()

    while(#pickedEnemies<math.min(BEAMS_NUM, #enemies)) do
        local ent = enemies[rng:RandomInt(#enemies)+1]
        if(enemyBlacklists[GetPtrHash(ent)]==nil) then
            enemyBlacklists[GetPtrHash(ent)]=true
            table.insert(pickedEnemies, ent)
        end
    end

    for _, npc in ipairs(pickedEnemies) do
        local beam = Isaac.Spawn(1000, 19, 2, npc.Position, Vector.Zero, p):ToEffect()
        beam.SpriteScale = Vector(0.65,0.65)
        beam.Scale = 0.65
        mod:setEntityData(beam, "IS_BLESSED_RING_BEAM", true)
        mod:setEntityData(beam, "HOLYBEAM_FOLLOW_NEARBY_ENEMY", npc:ToNPC())
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local function trackEnemyWithBeam(_, effect)
    local enemy = mod:getEntityData(effect, "HOLYBEAM_FOLLOW_NEARBY_ENEMY")

    if(enemy and enemy:Exists() and not enemy:IsDead()) then
        local newVl = (enemy.Position-effect.Position)

        effect.Velocity = newVl:Resized(newVl:Length()/7)
    else
        effect.Velocity = effect.Velocity*0.8
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, trackEnemyWithBeam, EffectVariant.CRACK_THE_SKY)

---@param source EntityRef
local function entTakeDamage(_, ent, amount, flags, source, cnt)
    if(not (source.Type==1000 and source.Variant==19 and source.Entity)) then return end
    local s = source.Entity:ToEffect()

    if(mod:getEntityData(s, "IS_BLESSED_RING_BEAM")) then
        return {
            Damage=BEAM_DAMAGE/6,
            DamageFlags=flags,
            DamageCountdown=cnt,
        }
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entTakeDamage)

