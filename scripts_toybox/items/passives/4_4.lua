
local sfx = SFXManager()

local SONIC_WAVE_COOLDOWN = 600
local STACK_COOL_MULT = 0.8

local SONIC_WAVES = 2
local SONIC_WAVE_BASENUM = 7
local SONIC_WAVE_FREQ = 6
local SONIC_WAVE_SPEED = 20
local SONIC_WAVE_SPREAD = 6


local OVERFLOW_BASECHANCE = 0.01
local OVERFLOW_MAXCHANCE = 0.1
local OVERFLOW_MAXLUCK = 44

local OVERFLOW_DURATION = 150

local function fireSonicWaves(_, player)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_FOUR_FOUR)) then return end

    local data = ToyboxMod:getEntityDataTable(player)
    if(data.FOURFOUR_COOLDOWN<=0) then
        data.FOURFOUR_COOLDOWN = SONIC_WAVE_COOLDOWN*(STACK_COOL_MULT^(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_FOUR_FOUR)-1))
        data.FOURFOUR_FIRE_DATA = {
            DURATION = SONIC_WAVE_FREQ*SONIC_WAVES*2,
            DIRECTION = player:GetAimDirection():GetAngleDegrees(),
        }

        sfx:Play(ToyboxMod.SOUND_EFFECT.FOUR_FOUR_SCREAM, 0.22)
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_PLAYER_DOUBLE_TAP, fireSonicWaves)

---@param player EntityPlayer
local function playerUpdate(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_FOUR_FOUR)) then
        data.FOURFOUR_COOLDOWN = data.FOURFOUR_COOLDOWN or 0

        if(data.FOURFOUR_COOLDOWN==1) then
            sfx:Play(SoundEffect.SOUND_EDEN_GLITCH)
            player:SetColor(Color(1,1,1,1,1,1,1),5,1,true,false)
        end

        data.FOURFOUR_COOLDOWN = math.max(0, data.FOURFOUR_COOLDOWN-1)
    end

    if(data.FOURFOUR_FIRE_DATA) then
        data.FOURFOUR_FIRE_DATA.DURATION = data.FOURFOUR_FIRE_DATA.DURATION or 0
        data.FOURFOUR_FIRE_DATA.DIRECTION = data.FOURFOUR_FIRE_DATA.DIRECTION or 0

        if(data.FOURFOUR_FIRE_DATA.DURATION%(SONIC_WAVE_FREQ*2)==0) then
            local tearsNum = data.FOURFOUR_FIRE_DATA.DURATION/(SONIC_WAVE_FREQ*2)+SONIC_WAVE_BASENUM-1

            for i=1, tearsNum do
                local angle = data.FOURFOUR_FIRE_DATA.DIRECTION + (i-tearsNum/2)*SONIC_WAVE_SPREAD

                local tear = Isaac.Spawn(2,ToyboxMod.TEAR_VARIANT.SOUNDWAVE,0,player.Position,Vector.FromAngle(angle)*SONIC_WAVE_SPEED, player):ToTear()
                tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_CONFUSION)
                tear.CollisionDamage = 0
                tear.FallingAcceleration = -0.1
                tear.FallingSpeed = 0
                tear.Mass = 1
                tear.Scale = 1.2
                tear.SizeMulti = Vector(1,1)*3
                tear.SpriteScale = Vector(1,1)/3

                local rng = tear:GetDropRNG()
                tear.Color = Color(0.9+rng:RandomFloat()*0.1,0.9+rng:RandomFloat()*0.1,0.9+rng:RandomFloat()*0.1,1,rng:RandomFloat()*0.2, rng:RandomFloat()*0.5, rng:RandomFloat()*0.4)
                ToyboxMod:setEntityData(tear, "EVIL_WAVE_ROTATION", (angle-data.FOURFOUR_FIRE_DATA.DIRECTION)*3.5+data.FOURFOUR_FIRE_DATA.DIRECTION)
            end
        end

        data.FOURFOUR_FIRE_DATA.DURATION = data.FOURFOUR_FIRE_DATA.DURATION-1
        if(data.FOURFOUR_FIRE_DATA.DURATION<=0) then data.FOURFOUR_FIRE_DATA=nil end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, playerUpdate)

---@param source EntityRef
local function tryInflictOverflow(_, ent, amount, flags, source, frames)
    if(not ToyboxMod:isValidEnemy(ent)) then return end
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_FOUR_FOUR)) then return end

    local luckMult = 0
    for i=0, Game():GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(i)
        luckMult = luckMult+p:GetCollectibleNum(ToyboxMod.COLLECTIBLE_FOUR_FOUR)*p.Luck
    end

    local chance = 0
    if(not ent:IsBoss()) then
        chance = ToyboxMod:getLuckAffectedChance(luckMult, OVERFLOW_BASECHANCE, OVERFLOW_MAXLUCK, OVERFLOW_MAXCHANCE)
    end

    if(chance and Isaac.GetPlayer():GetCollectibleRNG(ToyboxMod.COLLECTIBLE_FOUR_FOUR):RandomFloat()<chance) then
        ToyboxMod:addOverflowing(ent, Isaac.GetPlayer(), math.max(0,OVERFLOW_DURATION-ToyboxMod:getOverloadingDuration(ent)))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, tryInflictOverflow)