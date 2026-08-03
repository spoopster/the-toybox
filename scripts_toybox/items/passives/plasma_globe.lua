

---@param entity Entity
---@param player EntityPlayer
local function pollTearflags(_, entity, player, weapon)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_PLASMA_GLOBE)) then
        TearFlagsLib.AddTearFlags(entity, ToyboxMod.TEARFLAGS.PLASMA)
    end
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.POLL_TEARFLAGS, pollTearflags)
ToyboxMod:AddCallback(TearFlagsLib.Callback.POLL_CHANCELESS_TEARFLAGS, pollTearflags)

---@param entity Entity
---@param player EntityPlayer
local function cancelRemovePlasma(_, entity, player, _)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_PLASMA_GLOBE)) then return end

    if(not ToyboxMod:getEntityData(entity, "PLASMA_BLACKLIST")) then
        return true
    end
end
ToyboxMod:AddCallback(TearFlagsLib.Callback.PRE_REMOVE_TEARFLAG, cancelRemovePlasma, ToyboxMod.TEARFLAGS.PLASMA)

--[[] poopy trinket forme
local ELECTRIFIED_DURATION = 120
local ELECTRIFIED_DMG = 0.5

local TMULT_DURATION_MOD = 1.5

local ELECTRIFIED_CHANCE = 0.15 -- chance to inflict at 0 luck
local ELECTRIFIED_MAXLUCK = 20 -- max luck value for scaling
local ELECTRIFIED_MAXCHANCE = 0.5 -- chance at max luck

local function postNewRoom(_)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ToyboxMod:isValidEnemy(ent)) then
            local willElectrify = nil

            for i=0, ToyboxMod.GAME:GetNumPlayers()-1 do
                local p = Isaac.GetPlayer(i)
                local tMult = p:GetTrinketMultiplier(ToyboxMod.TRINKET_PLASMA_GLOBE)

                if(tMult>0 and p:GetTrinketRNG(ToyboxMod.TRINKET_PLASMA_GLOBE):RandomFloat()<ToyboxMod:getLuckAffectedChance(p.Luck, ELECTRIFIED_CHANCE, ELECTRIFIED_MAXLUCK, ELECTRIFIED_MAXCHANCE)) then
                    willElectrify = {p,tMult}
                    break
                end
            end

            if(willElectrify) then
                local electrifyPlayer = willElectrify[1]
                local electrifyMult = willElectrify[2]

                local duration = ELECTRIFIED_DURATION*(TMULT_DURATION_MOD^(electrifyMult-1))
                duration = math.floor(duration)*(electrifyPlayer:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND)+1)

                ToyboxMod:addElectrified(ent, electrifyPlayer, duration, electrifyPlayer.Damage)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)
--]]

--[[ TECH omega

local DMG_MULT = 2
local LASER_DURATION = 2
local LASER_FREQ = 7

---@param ent Entity
---@return EntityPlayer?
local function getPlayerForEnt(ent)
    local check = {ent.SpawnerEntity, ent.Parent}

    for _, cEnt in ipairs(check) do
        if(cEnt) then
            if(cEnt:ToPlayer()) then
                return cEnt:ToPlayer()
            elseif(cEnt:ToFamiliar()) then
                if(ToyboxMod.TEAR_COPYING_FAMILIARS[fam.Variant] or fam.Variant==FamiliarVariant.FATES_REWARD) then
                    return cEnt:ToFamiliar().Player
                end
            end
        end
    end

    return nil
end

---@param tear EntityTear
---@param player EntityPlayer
local function fireMagnetTear(_, tear, player)
    if(player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_PLASMA_GLOBE):RandomFloat()<0.025) then
        tear.Velocity = tear.Velocity*0.33
        tear.FallingAcceleration = -0.1
        tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_BOUNCE)

        ToyboxMod:setEntityData(tear, "MAGNET_SPHERE", true)

        tear.Scale = 3
        tear:ResetSpriteScale(true)

        local sp = tear:GetSprite()
        local prevAnim = sp:GetAnimation()
        sp:Load("gfx_tb/tears/tear_plasma.anm2", true)
        sp:Play(prevAnim, true)
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_FIRE_TEAR, fireMagnetTear)

---@param tear EntityTear
local function electricTearUpdate(_, tear)
    if(not (ToyboxMod:getEntityData(tear, "MAGNET_SPHERE"))) then return end

    local player = getPlayerForEnt(tear)
    if(not (player)) then return end

    local laserCountdown = (ToyboxMod:getEntityData(tear, "PLASMAGLOBE_LASER_COUNTDOWN") or 0)
    if(laserCountdown>0) then
        laserCountdown = laserCountdown-1
    else
        local closestEnemy = ToyboxMod:closestEnemy(tear.Position) ---@cast closestEnemy EntityNPC?
        if(not (closestEnemy)) then return end
        --if(closestEnemy.Position:DistanceSquared(tear.Position)>LASER_FIRE_DIST*LASER_FIRE_DIST) then return end

        local dir = (closestEnemy.Position-tear.Position)
        local distToFire = dir:Length()
        local angleToFire = dir:GetAngleDegrees()

        local arc = EntityLaser.ShootAngle(LaserVariant.ELECTRIC, tear.Position, angleToFire, LASER_DURATION, Vector(0, tear.Height), player)
        arc.DisableFollowParent = true
        arc.CollisionDamage = tear.CollisionDamage*DMG_MULT
        arc.MaxDistance = distToFire+5
        arc.OneHit = true
        arc.Mass = 0
        ToyboxMod:setEntityData(arc, "PLASMA_BLACKLIST", 0)

        arc.Color = Color(0,0,0,1,0,1,0.8)

        laserCountdown = LASER_FREQ
    end

    ToyboxMod:setEntityData(tear, "PLASMAGLOBE_LASER_COUNTDOWN", laserCountdown)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, electricTearUpdate)

]]