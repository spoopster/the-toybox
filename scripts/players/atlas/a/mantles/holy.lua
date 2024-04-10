local mod = MilcomMOD
local sfx = SFXManager()

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_HOLY] = true
end

local function useMantle(_, _, player, _)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        mod:giveMantle(player, mod.MANTLE_DATA.HOLY.ID)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_HOLY)

local ENUM_SACRED_CHANCE = 1/30
local ENUM_RANGE_BONUS = 0.5

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.HOLY.ID)

    if(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+ENUM_RANGE_BONUS*numMantles*40
    end
    if(mod:atlasHasTransformation(player, mod.MANTLE_DATA.HOLY.ID)) then
        if(flag==CacheFlag.CACHE_TEARFLAG) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
        end
        if(flag==CacheFlag.CACHE_FLYING) then
            player.CanFly = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

--ADDING THE HOMING TEARFLAG + DMG BONUS ON DIFFERENT WEAPONS
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and e.SpawnerEntity:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    local p = e.SpawnerEntity:ToPlayer()
    local chance = ENUM_SACRED_CHANCE*mod:getNumMantlesByType(p, mod.MANTLE_DATA.HOLY.ID)
    if(e:GetDropRNG():RandomFloat()<chance) then
        e:AddTearFlags(TearFlags.TEAR_HOMING)
        e.CollisionDamage = e.CollisionDamage*2
    end
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and e.SpawnerEntity:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    local p = e.SpawnerEntity:ToPlayer()
    local chance = ENUM_SACRED_CHANCE*mod:getNumMantlesByType(p, mod.MANTLE_DATA.HOLY.ID)
    if(e:GetDropRNG():RandomFloat()<chance) then
        e:AddTearFlags(TearFlags.TEAR_HOMING)
        e.ExplosionDamage = e.ExplosionDamage*2
    end
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and e.SpawnerEntity:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    local p = e.SpawnerEntity:ToPlayer()
    local chance = ENUM_SACRED_CHANCE*mod:getNumMantlesByType(p, mod.MANTLE_DATA.HOLY.ID)
    if(e:GetDropRNG():RandomFloat()<chance) then
        e:AddTearFlags(TearFlags.TEAR_HOMING)
        e.CollisionDamage = e.CollisionDamage*2
    end
end
)

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and e.SpawnerEntity:ToPlayer():GetPlayerType()==mod.PLAYER_ATLAS_A)) then return end
    local p = e.SpawnerEntity:ToPlayer()
    local chance = ENUM_SACRED_CHANCE*mod:getNumMantlesByType(p, mod.MANTLE_DATA.HOLY.ID)
    if(e:GetDropRNG():RandomFloat()<chance) then
        e:AddTearFlags(TearFlags.TEAR_HOMING)
        e.CollisionDamage = e.CollisionDamage*2
    end
end
)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, playMantleSFX, mod.MANTLE_DATA.HOLY.ID)