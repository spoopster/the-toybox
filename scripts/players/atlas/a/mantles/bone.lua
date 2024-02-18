local mod = MilcomMOD
local sfx = SFXManager()

--* needs some polish

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_BONE] = true
end

local function useMantle(_, _, player, _)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        mod:giveMantle(player, mod.MANTLES.BONE)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_BONE)

local ENUM_BONES_SHOT = 8
local ENUM_BONES_SPEED = 12
local ENUM_BONES_DMG = 5
local ENUM_BOTD_FAM_SPAWNCHANCE = 0.15
local ENUM_VALID_HEARTSUBTYPES = {
    [HeartSubType.HEART_FULL] = Color(0.5,0,0,1,0.3,0,0),
    [HeartSubType.HEART_HALF] = Color(0.5,0,0,1,0.3,0,0),
    [HeartSubType.HEART_DOUBLEPACK] = Color(0.5,0,0,1,0.3,0,0),
    [HeartSubType.HEART_SCARED] = Color(0.5,0,0,1,0.3,0,0),
    [HeartSubType.HEART_BLENDED] = Color(0.5,0,0,1,0.3,0,0.2),
    [HeartSubType.HEART_ROTTEN] = Color(0.4,0,0,1,0.2,0,0),
}

local function mantleDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLES.BONE)) then return end

    local rng = player:GetCardRNG(mod.CONSUMABLE_MANTLE_BONE)
    local bones = ENUM_BONES_SHOT*dmg
    for i=1, bones do
        local v = Vector(ENUM_BONES_SPEED,0):Rotated(360*i/bones+(rng:RandomFloat()-1/2)*25)
        local boneTear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BONE, 0, player.Position,v,player):ToTear()
        boneTear.CollisionDamage = ENUM_BONES_DMG
    end
end
if(CustomHealthAPI) then mod:addChapiDamageCallback(mantleDamage, -1e6)
else mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12-1, mantleDamage, EntityType.ENTITY_PLAYER) end

local function mantleKill(_, entity)
    if(entity.MaxHitPoints<1) then return end
    if(not entity:IsEnemy()) then return end
    if(not PlayerManager.AnyoneIsPlayerType(mod.PLAYER_ATLAS_A)) then return end

    local rng = entity:GetDropRNG()
    local numTransformations = 0
    local allAtlas = mod:getAllAtlasA()

    local randAtlas = allAtlas[rng:RandomInt(#allAtlas)+1]:ToPlayer()
    for _, p in ipairs(allAtlas) do
        numTransformations = numTransformations+mod:getNumMantlesByType(p:ToPlayer(), mod.MANTLES.BONE)/mod:getAtlasAData(p:ToPlayer(), "HP_CAP")
    end

    if(rng:RandomFloat()<ENUM_BOTD_FAM_SPAWNCHANCE*numTransformations/Game():GetNumPlayers()) then
        randAtlas:AddBoneOrbital(entity.Position)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mantleKill)

local function healWithHearts(_, pickup, player)
    if(not (player and player:ToPlayer() and player:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    player = player:ToPlayer()
    if(not mod:atlasHasTransformation(player, mod.MANTLES.BONE)) then return end

    if(not mod:hasMaxMantleHp(player)) then
        mod:addMantleHp(player, 1)

        local poof = Isaac.Spawn(1000,16,1,pickup.Position,Vector.Zero,nil):ToEffect()
        poof.SpriteScale = Vector(0.5,0.5)
        poof.Color = Color(0.3,0.3,0.3,1,0.2,0,0)

        local gulpEffect = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, nil):ToEffect()
        gulpEffect.SpriteOffset = Vector(0, -35)
        gulpEffect.DepthOffset = 1000
        gulpEffect:FollowParent(player)

        sfx:Play(SoundEffect.SOUND_VAMP_GULP)

        pickup:Remove()

        sfx:Play(SoundEffect.SOUND_BLACK_POOF)

        return false
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, 1e12, healWithHearts, PickupVariant.PICKUP_HEART)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, playMantleSFX, mod.MANTLES.BONE)