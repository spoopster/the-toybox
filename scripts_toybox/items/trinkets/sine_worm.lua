

local FRAME_MULT = 20
local SPEED_MULT = 2

local TEARS_UP = 0.4
local RANGE_UP = 1.5

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasTrinket(ToyboxMod.TRINKET_SINE_WORM)) then return end
    local mult = player:GetTrinketMultiplier(ToyboxMod.TRINKET_SINE_WORM)

    if(flag==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(player, TEARS_UP*mult)
    elseif(flag==CacheFlag.CACHE_RANGE) then
        player.TearRange = player.TearRange+RANGE_UP*40*mult
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function getTearVel(tear, mult)
    mult = (mult or 1)^0.5
    return 1-(((1-math.sin(math.rad(tear.FrameCount*FRAME_MULT+180))*0.5-0.5)^(mult*2)*1+0.1)*SPEED_MULT*((mult-1)*0.5+1))
end
local function fireVelChange(_, tear)
    if(Game():IsPaused()) then return end
    if(not ToyboxMod:getEntityData(tear, "IS_SINE_WORM_TEAR")) then return end
    local mult = getTearVel(tear, ToyboxMod:getEntityData(tear, "IS_SINE_WORM_TEAR"))
    tear.Position = tear.Position-tear.Velocity*(mult)*0.5
end

local function tearVelChange(_, tear)
    if(Game():IsPaused()) then return end
    if(not ToyboxMod:getEntityData(tear, "IS_SINE_WORM_TEAR")) then return end
    local mult = getTearVel(tear, ToyboxMod:getEntityData(tear, "IS_SINE_WORM_TEAR"))
    tear.Position = tear.Position-tear.Velocity*(mult)*0.5

    tear.Height = tear.Height-(tear.FallingSpeed)*mult*0.2
    tear.FallingSpeed = tear.FallingSpeed-(tear.FallingAcceleration-0.2)*mult*0.2
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_TEAR_UPDATE, tearVelChange)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, tearVelChange)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_BOMB_UPDATE, fireVelChange)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_BOMB_RENDER, fireVelChange)
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_LASER_UPDATE, fireVelChange)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, fireVelChange)

---@param tear EntityTear
local function postTearInit(_, tear)
    local player = (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())
    if(not player) then return end

    local mult = player:GetTrinketMultiplier(ToyboxMod.TRINKET_SINE_WORM)
    if(mult<=0) then return end

    ToyboxMod:setEntityData(tear, "IS_SINE_WORM_TEAR", mult)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, postTearInit)
---@param tear EntityTear
---@param player EntityPlayer
local function fireSineTear(_, tear, player, isLudo)
    local mult = player:GetTrinketMultiplier(ToyboxMod.TRINKET_SINE_WORM)
    if(mult<=0) then return end

    ToyboxMod:setEntityData(tear, "IS_SINE_WORM_TEAR", mult)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, fireSineTear)
local function resetLudoData(_, tear)
    ToyboxMod:setEntityData(tear, "IS_SINE_WORM_TEAR", nil)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.RESET_LUDOVICO_DATA, resetLudoData)

---@param bomb EntityBomb
---@param player EntityPlayer
local function fireSineBomb(_, bomb, player)
    local mult = player:GetTrinketMultiplier(ToyboxMod.TRINKET_SINE_WORM)
    if(mult<=0) then return end

    ToyboxMod:setEntityData(bomb, "IS_SINE_WORM_TEAR", mult)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_BOMB, fireSineBomb)
---@param bomb EntityBomb
---@param ogbomb EntityBomb
local function copySineScatterData(_, bomb, ogbomb)
    ToyboxMod:setEntityData(bomb, "IS_SINE_WORM_TEAR", ToyboxMod:getEntityData(ogbomb, "IS_SINE_WORM_TEAR"))
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.COPY_SCATTER_BOMB_DATA, copySineScatterData)

---@param laser EntityLaser
local function fireSineX(_, laser)
    local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
    if(not player) then return end

    local mult = player:GetTrinketMultiplier(ToyboxMod.TRINKET_SINE_WORM)
    if(mult<=0) then return end

    ToyboxMod:setEntityData(laser, "IS_SINE_WORM_TEAR", mult)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, fireSineX)