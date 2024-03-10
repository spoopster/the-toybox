local mod = MilcomMOD
local sfx = SFXManager()

--! add the funny sparkles (both transf and mantle)

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_GOLD] = true
end

local function useMantle(_, _, player, _)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        mod:giveMantle(player, mod.MANTLES.GOLD)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_GOLD)

local ENUM_LUCK_BONUS = 0.5
local ENUM_FREEZE_DURATION = 150
local ENUM_LOSTMANTLE_FREEZE_DIST = 100

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLES.GOLD)

    if(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+ENUM_LUCK_BONUS*numMantles
    end
    if(mod:atlasHasTransformation(player, mod.MANTLES.GOLD)) then
        if(flag==CacheFlag.CACHE_TEARFLAG) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_GREED_COIN
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function mantleDestroyed(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    if(not (mod:atlasHasTransformation(player, mod.MANTLES.GOLD) or mantle==mod.MANTLES.GOLD)) then return end

    for _, ent in ipairs(Isaac.FindInRadius(player.Position, ENUM_LOSTMANTLE_FREEZE_DIST, EntityPartition.ENEMY)) do
        if(ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            ent:AddMidasFreeze(EntityRef(player), ENUM_FREEZE_DURATION)
        end
    end

    local shatter = Isaac.Spawn(1000, mod.EFFECT_GOLDMANTLE_BREAK, 0, player.Position, Vector.Zero, player):ToEffect()
    shatter.DepthOffset = 100
    shatter:GetSprite().PlaybackSpeed = 1.4
    shatter.SpriteOffset = Vector(0,-10)

    local crater = Isaac.Spawn(1000,EffectVariant.BOMB_CRATER,0,player.Position,Vector.Zero,player):ToEffect()
    crater.Color = Color(1,1,1,1,0.87,0.87)

    for i=1, 20 do
        local gibs = Isaac.Spawn(1000, 95, 0, player.Position, Vector.Zero, player):ToEffect()
        gibs.Velocity = Vector(gibs:GetDropRNG():RandomFloat()*12, 0):Rotated(gibs:GetDropRNG():RandomFloat()*360)
    end

    sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK)
    sfx:Play(mod.SFX_ATLASA_METALBREAK, 1.4)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, mantleDestroyed)

---@param player EntityPlayer
---@param collider Entity
local function freezeOnCollision(_, player, collider)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLES.GOLD)) then return end
    if(not (collider:IsVulnerableEnemy() and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then return end

    if(not collider:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE)) then
        collider:AddMidasFreeze(EntityRef(player), ENUM_FREEZE_DURATION)
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, freezeOnCollision)

---@param effect EntityEffect
local function updateGoldMantleShatter(_, effect)
    if(effect.FrameCount==0) then effect:GetSprite():Play("Idle", true) end
    if(effect:GetSprite():IsFinished("Idle")) then effect:Remove() end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, updateGoldMantleShatter, mod.EFFECT_GOLDMANTLE_BREAK)