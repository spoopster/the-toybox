local sfx = SFXManager()
local evilRenders = {}

---@param pl EntityPlayer
---@param rng RNG
---@param duration integer?
---@param topleftclamp Vector?
---@param bottomrightclamp Vector?
local function pushRender(pl, rng, duration, topleftclamp, bottomrightclamp)
    local sp = pl:GetSprite()

    local newSp = Sprite(sp:GetFilename(), false)
    for i, state in pairs(sp:GetAllLayers()) do
        newSp:ReplaceSpritesheet(i-1, state:GetSpritesheetPath())
    end
    newSp:LoadGraphics()

    newSp:SetRenderFlags(AnimRenderFlags.GLITCH)
    newSp:SetFrame(sp:GetAnimation(), sp:GetFrame())
    newSp:SetOverlayFrame(sp:GetOverlayAnimation(), sp:GetOverlayFrame())
    newSp:Stop(true)

    local xscale = rng:RandomFloat()*0.75+0.75
    newSp.Scale = Vector(xscale, 1)

    duration = duration or rng:RandomInt(8,17)
    topleftclamp = topleftclamp or Vector(rng:RandomInt(12), rng:RandomInt(12))
    bottomrightclamp = bottomrightclamp or Vector(rng:RandomInt(12), rng:RandomInt(12))

    table.insert(evilRenders,{
        Sprite = newSp,
        Position = pl.Position,
        Duration = duration,
        TopClamp = topleftclamp, BottomClamp = bottomrightclamp,
    })
end

---@param dir Vector
---@param amount number
---@param owner Entity
---@param weapon Weapon
local function postTriggerWeaponFired(_, dir, amount, owner, weapon)
    local weapType = weapon:GetWeaponType()
    if(weapType==WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then return end


    local pl = ToyboxMod:getPlayerFromEnt(owner)
    if(not pl) then return end

    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_4_4)

    if(#evilRenders==0) then
        pushRender(pl, rng)
        sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 0.3, 1, false, rng:RandomFloat()*0.3+0.85)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, postTriggerWeaponFired)

---@param tear EntityTear
local function tearFire(_, tear)
    local pl = ToyboxMod:getPlayerFromEnt(tear)
    if(not pl) then return end

    local spawner = tear.SpawnerEntity
    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_4_4)

    if(#evilRenders==0) then
        pushRender(spawner, rng)
        sfx:Play(SoundEffect.SOUND_EDEN_GLITCH, 0.3, 1, false, rng:RandomFloat()*0.3+0.85)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, tearFire)

---@param tear EntityTear
local function brimFire(_, tear)
    local pl = ToyboxMod:getPlayerFromEnt(tear)
    if(not pl) then return end

    local spawner = tear.SpawnerEntity
    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_4_4)

    if(#evilRenders==0) then
        pushRender(spawner, rng)
        sfx:Play(ToyboxMod.SOUND_EFFECT.FOUR_FOUR_SCREAM, 0.3, 1, false, rng:RandomFloat()*0.1+0.95)
    end
end
--ToyboxMod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, brimFire)

---@param pl EntityPlayer
local function postrender(_, pl)
    local sp = pl:GetSprite()

    local renderOffset = Game():GetRoom():GetRenderScrollOffset()

    local idx=1
    while(evilRenders[idx]) do
        local rPos = Isaac.WorldToRenderPosition(evilRenders[idx].Position)+renderOffset
        evilRenders[idx].Sprite:Render(rPos, evilRenders[idx].TopClamp, evilRenders[idx].BottomClamp)

        evilRenders[idx].Duration = evilRenders[idx].Duration-1
        if(evilRenders[idx].Duration<=0) then
            table.remove(evilRenders, idx)
        else
            idx = idx+1
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postrender)

local function postNewRoom(_)
    evilRenders = {}
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

--[[
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
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_4_4)) then return end

    local data = ToyboxMod:getEntityDataTable(player)
    if(data.FOURFOUR_COOLDOWN<=0) then
        data.FOURFOUR_COOLDOWN = SONIC_WAVE_COOLDOWN*(STACK_COOL_MULT^(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_4_4)-1))
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
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_4_4)) then
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
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_4_4)) then return end

    local luckMult = 0
    for i=0, Game():GetNumPlayers()-1 do
        local p = Isaac.GetPlayer(i)
        luckMult = luckMult+p:GetCollectibleNum(ToyboxMod.COLLECTIBLE_4_4)*p.Luck
    end

    local chance = 0
    if(not ent:IsBoss()) then
        chance = ToyboxMod:getLuckAffectedChance(luckMult, OVERFLOW_BASECHANCE, OVERFLOW_MAXLUCK, OVERFLOW_MAXCHANCE)
    end

    if(chance and Isaac.GetPlayer():GetCollectibleRNG(ToyboxMod.COLLECTIBLE_4_4):RandomFloat()<chance) then
        ToyboxMod:addOverflowing(ent, Isaac.GetPlayer(), math.max(0,OVERFLOW_DURATION-ToyboxMod:getOverloadingDuration(ent)))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, tryInflictOverflow)
--]]