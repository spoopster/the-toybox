local NUKE_ROCKET_SUBTYPE = 124

local NUKE_ROCKET_DMG = 50
local NUKE_SHOCKWAVE_DMG = 100

local POISON_DURATION = 30*5
local POISON_DMG = 3

---@param rng RNG
---@param pl EntityPlayer
local function bigRedButtonUse(_, _, rng, pl, flags, slot, vdata)
    local vel = (pl.Velocity:LengthSquared()<1 and Vector.Zero or pl.Velocity)

    local nuke = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_ROCKET_GIGA, NUKE_ROCKET_SUBTYPE, pl.Position, pl.Velocity, pl):ToBomb()
    nuke:GetSprite():ReplaceSpritesheet(0, "gfx_tb/bombs/nuke.png", true)
    nuke.ExplosionDamage = NUKE_ROCKET_DMG
    pl:TryHoldEntity(nuke)

    nuke:Update()

    pl:DischargeActiveItem(slot)
    
    return {
        Discharge = false,
        ShowAnim = false,
        Remove = false,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, bigRedButtonUse, ToyboxMod.COLLECTIBLE_BIG_RED_BUTTON)

---@param bomb EntityBomb
local function nukeUpdate(_, bomb)
    if(bomb.SubType~=NUKE_ROCKET_SUBTYPE) then return end

    if(bomb:GetExplosionCountdown()<=0) then
        local room = Game():GetRoom()

       -- room:MamaMegaExplosion(bomb.Position, (bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()))
        local expl = Isaac.Spawn(1000, EffectVariant.MAMA_MEGA_EXPLOSION, 0, bomb.Position, Vector.Zero, (bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer())):ToEffect()
        expl.CollisionDamage = NUKE_SHOCKWAVE_DMG
        expl.TargetPosition = bomb.Position

        
        room:GetFXLayers():AddPoopFx(Color(1,1,1,1,0,0.6,0,1,2,1,1))

        for _, ent in ipairs(Isaac.GetRoomEntities()) do
            if(ent and ToyboxMod:isValidEnemy(ent)) then
                ent:AddPoison(EntityRef(expl.SpawnerEntity), POISON_DURATION, POISON_DMG)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, nukeUpdate, BombVariant.BOMB_ROCKET_GIGA)