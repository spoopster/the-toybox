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

local TEARS_UP = 0.3
local ACTIVE_TEARS_MULT = 2
local DEACTIVATE_FREEZE_DURATION = 0
local DEACTIVATE_FLASH_FREQ = 10

local function getTriggeredInputValue(input, cidx)
    if(Input.IsActionTriggered(input, cidx)) then
        return Input.GetActionValue(input, cidx)
    end
    return 0
end

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not mod:isAtlasA(player)) then return end

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.SALT.ID)
    if(flag==CacheFlag.CACHE_FIREDELAY) then
        mod:addBasicTearsUp(player, TEARS_UP*numMantles)

        if((mod:getAtlasAData(player, "SALT_CHARIOT_ENABLED") or 0)~=0) then
            player.MaxFireDelay = mod:toFireDelay(ACTIVE_TEARS_MULT*mod:toTps(player.MaxFireDelay))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function toggleAutofire(_, player)
    if(not mod:isAtlasA(player)) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.SALT.ID)) then return end
    local data = mod:getAtlasATable(player)
    local rng = player:GetCardRNG(mod.CONSUMABLE_MANTLE_SALT)

    data.SALT_CHARIOT_ENABLED = data.SALT_CHARIOT_ENABLED or 0
    if(data.SALT_CHARIOT_ENABLED>0) then
        data.SALT_CHARIOT_ENABLED = data.SALT_CHARIOT_ENABLED-1
    end

    --- make visuals better
    if(Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
        local NUM_DUST = 5
        local NUM_GIBS = 0
        local DO_EFFECT = true

        if(data.SALT_CHARIOT_ENABLED==-1) then
            data.SALT_CHARIOT_ENABLED = DEACTIVATE_FREEZE_DURATION
            player:TryRemoveNullCostume(mod.MANTLE_DATA.SALT.CHARIOT_COSTUME)

            sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE,1,1,false,1)
            NUM_GIBS = 3
            NUM_DUST = 2
        elseif(data.SALT_CHARIOT_ENABLED>=0) then
            data.SALT_CHARIOT_ENABLED = -1
            player:AddNullCostume(mod.MANTLE_DATA.SALT.CHARIOT_COSTUME)

            
            player:SetColor(Color(1,1,1,1,0.3,0.3,0.3),10,1,true,false)
            sfx:Play(SoundEffect.SOUND_STONE_IMPACT,1,1,false,0.8)
        else
            DO_EFFECT = false
        end

        if(DO_EFFECT) then
            Game():ShakeScreen(5)
            for i=1, NUM_DUST do
                local vel = Vector.FromAngle(360*i/NUM_DUST+rng:RandomInt(180/NUM_DUST))*(3+rng:RandomFloat()*2)

                local dust = Isaac.Spawn(1000,EffectVariant.DUST_CLOUD,0,player.Position,vel,player):ToEffect()
                dust.Color=Color(1,1,1,0.3,0,0,0)
                dust:SetTimeout(15+rng:RandomInt(10))
                dust.SpriteScale = Vector(0.1,0.1)
            end

            
            for i=1, NUM_GIBS do
                local vel = Vector.FromAngle(360*i/NUM_GIBS+rng:RandomInt(180/NUM_GIBS))*(1+rng:RandomFloat()*3)

                local gib = Isaac.Spawn(1000,EffectVariant.ROCK_PARTICLE,0,player.Position,vel,player):ToEffect()
            end

            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY, true)
        end
    end

    if(data.SALT_CHARIOT_ENABLED~=0) then
        local cIdx = player.ControllerIndex
        local moveInput = Vector(0,0)
        moveInput.X = getTriggeredInputValue(ButtonAction.ACTION_RIGHT, cIdx)-getTriggeredInputValue(ButtonAction.ACTION_LEFT, cIdx)
        moveInput.Y = getTriggeredInputValue(ButtonAction.ACTION_DOWN, cIdx)-getTriggeredInputValue(ButtonAction.ACTION_UP, cIdx)

        player.Position = player.Position+moveInput*5
        player.Velocity = mod:lerp(player.Velocity, -moveInput*3, 0.75)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, toggleAutofire)


local MOVE_ACTIONS = {
    [ButtonAction.ACTION_UP] = 0,
    [ButtonAction.ACTION_DOWN] = 0,
    [ButtonAction.ACTION_LEFT] = 0,
    [ButtonAction.ACTION_RIGHT] = 0,
}

---@param ent Entity
---@param hook InputHook
---@param action ButtonAction
local function cancelMovementInput(_, ent, hook, action)
    if(not (ent and ent:ToPlayer())) then return end
    local pl = ent:ToPlayer()
    if(not (mod:isAtlasA(pl) and mod:atlasHasTransformation(pl, mod.MANTLE_DATA.SALT.ID))) then return end

    if((mod:getAtlasAData(pl, "SALT_CHARIOT_ENABLED") or 0)~=0) then
        if(MOVE_ACTIONS[action]) then
            if(hook==InputHook.IS_ACTION_PRESSED or hook==InputHook.IS_ACTION_TRIGGERED) then
                return false
            elseif(hook==InputHook.GET_ACTION_VALUE) then
                return 0
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, cancelMovementInput)

--[[
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_CHARIOT_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.Position = e.Position-e.Velocity
    e.Velocity = e.Velocity:Rotated(a-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_CHARIOT_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.Position = e.Position-e.Velocity
    e.Velocity = e.Velocity:Rotated(a-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_CHARIOT_ENABLED")~=true) then return end
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
    if(mod:getAtlasAData(p, "SALT_CHARIOT_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.Position = e.Position-e.Velocity
    e.Velocity = e.Velocity:Rotated(a-e.Velocity:GetAngleDegrees())
end
)

mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_CHARIOT_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()

    e.AngleDegrees = a
end
)

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE,
function(_, e)
    if(not (e.SpawnerEntity and e.SpawnerEntity:ToPlayer() and mod:isAtlasA(e.SpawnerEntity:ToPlayer()))) then return end
    local p = e.SpawnerEntity:ToPlayer()
    if(mod:getAtlasAData(p, "SALT_CHARIOT_ENABLED")~=true) then return end
    local n = mod:closestEnemy(p.Position)
    if(not n) then return end
    local a = (n.Position-p.Position):GetAngleDegrees()
    
    e.Rotation = a
end
)
--]]