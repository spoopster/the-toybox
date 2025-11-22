

local BASE_BEAM_COOLDOWN = 7*30
local BEAMS_NUM = 2
local BEAM_DAMAGE = 10

local function postUpdate(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_BLESSED_RING)) then return end
    if(ToyboxMod:isRoomClear()) then return end

    local cool = math.floor(BASE_BEAM_COOLDOWN/(PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_BLESSED_RING)))
    if(cool<1) then cool=1 end

    if((Game():GetRoom():GetFrameCount()-1)%cool~=0) then return end
    local r = Game():GetRoom()
    local p = PlayerManager.FirstCollectibleOwner(ToyboxMod.COLLECTIBLE_BLESSED_RING)
    local rng = p:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_BLESSED_RING)

    local enemyBlacklists = {}
    local pickedEnemies = {}
    local enemies = ToyboxMod:getAllValidEnemies()

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
        ToyboxMod:setEntityData(beam, "IS_BLESSED_RING_BEAM", true)
        ToyboxMod:setEntityData(beam, "HOLYBEAM_FOLLOW_NEARBY_ENEMY", npc:ToNPC())
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, postUpdate)

local function trackEnemyWithBeam(_, effect)
    local enemy = ToyboxMod:getEntityData(effect, "HOLYBEAM_FOLLOW_NEARBY_ENEMY")

    if(enemy and enemy:Exists() and not enemy:IsDead()) then
        local newVl = (enemy.Position-effect.Position)

        effect.Velocity = newVl:Resized(newVl:Length()/7)
    else
        effect.Velocity = effect.Velocity*0.8
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, trackEnemyWithBeam, EffectVariant.CRACK_THE_SKY)

---@param source EntityRef
local function entTakeDamage(_, ent, amount, flags, source, cnt)
    if(not (source.Type==1000 and source.Variant==19 and source.Entity)) then return end
    local s = source.Entity:ToEffect()

    if(ToyboxMod:getEntityData(s, "IS_BLESSED_RING_BEAM")) then
        return {
            Damage=BEAM_DAMAGE/6,
            DamageFlags=flags,
            DamageCountdown=cnt,
        }
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entTakeDamage)

