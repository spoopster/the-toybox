local mod = ToyboxMod
local sfx = SFXManager()

local DURATION = 10*60
local TEARS_MULT = 3
local DMG_UP = 1.5

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)
    
    local data = mod:getEntityDataTable(player)
    data.ARTHRITIS_DURATION = DURATION
    data.ARTHRITIS_HORSE = isHorse
    data.ARTHRITIS_CHOSEN_ANGLE = -1
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)

    player:AnimateHappy()
    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSUP_AMPLIFIED or SoundEffect.SOUND_THUMBSUP))
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, mod.PILL_EFFECT.ARTHRITIS)

local function cacheEval(_, player, flag)
    local data = mod:getEntityDataTable(player)
    if((data.ARTHRITIS_DURATION or 0)<=0) then return end

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = mod:toFireDelay(mod:toTps(player.MaxFireDelay)*TEARS_MULT)
    elseif(flag==CacheFlag.CACHE_DAMAGE and data.ARTHRITIS_HORSE) then
        mod:addBasicDamageUp(player, DMG_UP)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheEval)

local function getPlayerFromEnt(ent)
	local player = nil
    local sp = ent.SpawnerEntity

    if(sp==nil) then return end
    if(sp:ToPlayer()) then player = sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(fam.Variant==FamiliarVariant.FATES_REWARD or mod.COPYING_FAMILIARS[fam.Variant]) then player = fam.Player
        else return end
    else return end

    return player
end
---@param player EntityPlayer
local function getArthritisAngle(player)
    local data = mod:getEntityDataTable(player)

    return data.ARTHRITIS_CHOSEN_ANGLE
end
local function spawnerHasArthritis(player)
    if(not player) then return false end
    local data = mod:getEntityDataTable(player)
    data.ARTHRITIS_DURATION = data.ARTHRITIS_DURATION or 0
    if(data.ARTHRITIS_DURATION>0 and data.ARTHRITIS_CHOSEN_ANGLE~=-1) then return true end
    return false
end

---@param player EntityPlayer
local function reduceDuration(_, player)
    local data = mod:getEntityDataTable(player)
    data.ARTHRITIS_DURATION = data.ARTHRITIS_DURATION or 0
    if(data.ARTHRITIS_DURATION>0) then
        if(data.ARTHRITIS_CHOSEN_ANGLE~=-1) then
            data.ARTHRITIS_DURATION = data.ARTHRITIS_DURATION-1
            if(data.ARTHRITIS_DURATION==0) then player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true) end
        elseif(player:GetAimDirection():Length()>0.01) then
            data.ARTHRITIS_CHOSEN_ANGLE = player:GetAimDirection():GetAngleDegrees()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, reduceDuration, 0)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,
function(_, e)
    local p = getPlayerFromEnt(e)
    if(not spawnerHasArthritis(p)) then return end
    e.Position = e.Position-e.Velocity
    e.Velocity = e.Velocity:Rotated(getArthritisAngle(p)-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB,
function(_, e)
    local p = getPlayerFromEnt(e)
    if(not spawnerHasArthritis(p)) then return end
    e.Velocity = e.Velocity:Rotated(getArthritisAngle(p)-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER,
function(_, e)
    local p = getPlayerFromEnt(e)
    if(not spawnerHasArthritis(p)) then return end
    e.AngleDegrees = getArthritisAngle(p)
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER,
function(_, e)
    local p = getPlayerFromEnt(e)
    if(not spawnerHasArthritis(p)) then return end
    e.Position = e.Position-e.Velocity
    e.Velocity = e.Velocity:Rotated(getArthritisAngle(p)-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE,
function(_, e)
    local p = getPlayerFromEnt(e)
    if(not spawnerHasArthritis(p)) then return end
    e.AngleDegrees = getArthritisAngle(p)
end
)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE,
function(_, e)
    local p = getPlayerFromEnt(e)
    if(not spawnerHasArthritis(p)) then return end
    e.Rotation = getArthritisAngle(p)
end
)

mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER,
function(_, e)
    local p = getPlayerFromEnt(e)
    if(not spawnerHasArthritis(p)) then return end
    e.Velocity = Vector.FromAngle(getArthritisAngle(p))*40
    return true
end,
EffectVariant.TARGET)