local sfx = SFXManager()

local SPITE_DMG = 5
local SPITE_CHANCE = 0.1

---@param pickup EntityPickup
---@param coll Entity
local function postcoincoll(_, pickup, coll)
    local sp = pickup:GetSprite()
    if(not (sp:GetAnimation()=="Collect")) then return end

    local pl = (coll and coll:ToPlayer() or nil)
    if(not (pl and pl:HasTrinket(ToyboxMod.TRINKET_SPITEFUL_PENNY))) then return end
    local plref = EntityRef(pl)

    local mult = pl:GetTrinketMultiplier(ToyboxMod.TRINKET_SPITEFUL_PENNY)
    local val = pickup:GetCoinValue()
    local chance = (1-(1-math.min(1, mult*SPITE_CHANCE))^val)

    local poofsub
    if(pl:GetTrinketRNG(ToyboxMod.TRINKET_SPITEFUL_PENNY):RandomFloat()<chance) then
        pl:TakeDamage(1, DamageFlag.DAMAGE_FAKE, plref, 0)

        poofsub = 2
        sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
    else
        poofsub = 1
        sfx:Play(SoundEffect.SOUND_MEAT_IMPACTS)
    end

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, poofsub, pickup.Position, Vector.Zero, nil):ToEffect()
    poof.DepthOffset = 1

    local dmgval = SPITE_DMG*(val+mult)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ToyboxMod:isValidEnemy(ent)) then
            ent:TakeDamage(dmgval, 0, plref, 0)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, postcoincoll, PickupVariant.PICKUP_COIN)