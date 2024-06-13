local mod = MilcomMOD
local sfx = SFXManager()

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_SALT] = true
end

local function useMantle(_, _, player, _)
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.SALT.ID)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_SALT)

local ENUM_TPS_BONUS = 1/3

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not mod:isAtlasA(player)) then return end

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.SALT.ID)

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(player, ENUM_TPS_BONUS*numMantles)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function toggleAutofire(_, player)
    if(not mod:isAtlasA(player)) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.SALT.ID)) then return end
    local data = mod:getAtlasATable(player)

    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
        if(data.SALT_AUTOTARGET_ENABLED==true) then data.SALT_AUTOTARGET_ENABLED=false
        else data.SALT_AUTOTARGET_ENABLED=true end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, toggleAutofire)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_AUTOTARGET_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.Velocity = e.Velocity:Rotated(a-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_AUTOTARGET_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.Velocity = e.Velocity:Rotated(a-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_AUTOTARGET_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.AngleDegrees = a
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_AUTOTARGET_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.Velocity = e.Velocity:Rotated(a-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_AUTOTARGET_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.AngleDegrees = a
end
)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(not mod:isAtlasA(player)) then return end

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, playMantleSFX, mod.MANTLE_DATA.DEFAULT.ID)