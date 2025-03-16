local mod = ToyboxMod

local CLOUD_DURATION = 30*10
local CREEP_DURATION = 30*8
local EXPL_CHANCE = 0.5

---@param pl EntityPlayer
local function cancelExplosionDmg(_, pl, damage, flags, source, count)
    if(not pl:HasCollectible(mod.COLLECTIBLE.BOBS_HEART)) then return end
    if(flags & DamageFlag.DAMAGE_EXPLOSION ~= 0 ) then return false end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, cancelExplosionDmg, 0)

---@param player Entity
local function applyMarkPenalties(_, player, _, flags, source)
    player = player:ToPlayer()
    if(not player:HasCollectible(mod.COLLECTIBLE.BOBS_HEART)) then return end
    
    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, player.Position, Vector.Zero, player):ToEffect()
    cloud.SpriteScale = Vector(1,1)*1.5
    cloud.Timeout = CLOUD_DURATION
    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero, player):ToEffect()
    creep.SpriteScale = Vector(1,1)*1.5
    creep:Update()
    creep:SetTimeout(CREEP_DURATION)

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, player.Position, Vector.Zero, player):ToEffect()
    poof.Color = Color(0.3,0.3,0.3,1,0,0.4,0,0,0.5,0,1)
    poof.DepthOffset = -1000

    if(player:GetCollectibleRNG(mod.COLLECTIBLE.BOBS_HEART):RandomFloat()<EXPL_CHANCE) then
        local bomb = player:FireBomb(player.Position,Vector.Zero,player):ToBomb()
        bomb.Color = Color(0.5,1,0.5,1,0,0.3,0)
        bomb:SetExplosionCountdown(0)
        bomb:Update()
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, applyMarkPenalties, EntityType.ENTITY_PLAYER)