local RANGE_DOWN = 1
local RANGE_MULT = 0.9

local POISON_AMOUNT = 30*3
local POISON_DMG_MULT = 1

local AURA_SIZE_MULT = 3

local LASER_AURA_RENDERS = 12
local LASER_AURA_ALPHA = 0.12

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC)) then return end

    if(flag==CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = Color.TearScorpio
        player.LaserColor = Color.LaserPoison
    elseif(flag==CacheFlag.CACHE_TEARFLAG) then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_POISON
    elseif(flag==CacheFlag.CACHE_RANGE) then
        local mult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_GARLIC)

        player.TearRange = player.TearRange-RANGE_DOWN*mult*40
        player.TearRange = player.TearRange*RANGE_MULT
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param pl EntityPlayer
local function cancelVampireEffect(_, pl)
    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC)) then
        pl:SetCharmOfTheVampireKills(0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, cancelVampireEffect)

---@param tear EntityTear
local function tearPoisonAura(_, tear)
    local pl = ToyboxMod:getPlayerFromEnt(tear)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    local auraSize = 7*tear.Scale*AURA_SIZE_MULT

    local plRef = EntityRef(player)

    for _, ent in ipairs(Isaac.FindInRadius(tear.Position, auraSize, EntityPartition.ENEMY)) do
        if(ToyboxMod:isValidEnemy(ent)) then
            local countdown = ent:GetPoisonCountdown()
            if(countdown<POISON_AMOUNT) then
                ent:AddPoison(plRef, POISON_AMOUNT-countdown, POISON_DMG_MULT*pl.Damage)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, tearPoisonAura)

---@param tear EntityTear
---@param offset Vector
local function renderTearAura(_, tear, offset)
    local pl = ToyboxMod:getPlayerFromEnt(tear)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    local sp = ToyboxMod:getEntityData(tear, "GARLIC_AURA")
    if(not sp) then
        sp = Sprite("gfx_tb/effects/effect_tear_aura.anm2", true)
        sp:Play("Idle", true)
        sp.Color = Color(0.2,1,0.2,1,0,0.1,0)

        ToyboxMod:setEntityData(tear, "GARLIC_AURA", sp)
    end

    sp.Scale = tear.Scale*7*AURA_SIZE_MULT/60*Vector(1,1)
    sp:Render(Isaac.WorldToRenderPosition(tear.Position+tear.PositionOffset)+offset)

    if(not Game():IsPaused()) then
        sp:Update()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_TEAR_RENDER, renderTearAura)

---@param pl EntityPlayer
---@param bomb EntityBomb
local function invalidateUsedBomb(_, pl, bomb)
    if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC)) then
        ToyboxMod:setEntityData(bomb, "GARLIC_BLACKLIST", true)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_USE_BOMB, invalidateUsedBomb)

---@param bomb EntityBomb
---@param ogbomb EntityBomb
local function copyInvalidBombData(_, bomb, ogbomb)
    ToyboxMod:setEntityData(bomb, "GARLIC_BLACKLIST", ToyboxMod:getEntityData(ogbomb, "GARLIC_BLACKLIST"))
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.COPY_SCATTER_BOMB_DATA, copyInvalidBombData)

---@param bomb EntityBomb
local function bombPoisonAura(_, bomb)
    if(ToyboxMod:getEntityData(bomb, "GARLIC_BLACKLIST")) then return end

    local pl = ToyboxMod:getPlayerFromEnt(bomb)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    local auraSize = 10*bomb:GetScale()*AURA_SIZE_MULT

    local plRef = EntityRef(player)

    for _, ent in ipairs(Isaac.FindInRadius(bomb.Position, auraSize, EntityPartition.ENEMY)) do
        if(ToyboxMod:isValidEnemy(ent)) then
            local countdown = ent:GetPoisonCountdown()
            if(countdown<POISON_AMOUNT) then
                ent:AddPoison(plRef, POISON_AMOUNT-countdown, POISON_DMG_MULT*pl.Damage)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, bombPoisonAura)

---@param bomb EntityBomb
---@param offset Vector
local function renderBombAura(_, bomb, offset)
    if(ToyboxMod:getEntityData(bomb, "GARLIC_BLACKLIST")) then return end

    local pl = ToyboxMod:getPlayerFromEnt(bomb)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    local sp = ToyboxMod:getEntityData(bomb, "GARLIC_AURA")
    if(not sp) then
        sp = Sprite("gfx_tb/effects/effect_tear_aura.anm2", true)
        sp:Play("Idle", true)
        sp.Color = Color(0.2,1,0.2,1,0,0.1,0)

        ToyboxMod:setEntityData(bomb, "GARLIC_AURA", sp)
    end

    sp.Scale = bomb:GetScale()*10*AURA_SIZE_MULT/60*Vector(1,1)
    sp:Render(Isaac.WorldToRenderPosition(bomb.Position+bomb.PositionOffset)+offset)

    if(not Game():IsPaused()) then
        sp:Update()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_BOMB_RENDER, renderBombAura)

---@param knife EntityKnife
local function knifePoisonAura(_, knife)
    local pl = ToyboxMod:getPlayerFromEnt(knife)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    if(knife:IsFlying() or knife:HasTearFlags(TearFlags.TEAR_LUDOVICO) or knife.SubType==KnifeSubType.PROJECTILE) then
        local auraSize = 10*knife.Scale*AURA_SIZE_MULT

        local plRef = EntityRef(player)

        for _, ent in ipairs(Isaac.FindInRadius(knife.Position, auraSize, EntityPartition.ENEMY)) do
            if(ToyboxMod:isValidEnemy(ent)) then
                local countdown = ent:GetPoisonCountdown()
                if(countdown<POISON_AMOUNT) then
                    ent:AddPoison(plRef, POISON_AMOUNT-countdown, POISON_DMG_MULT*pl.Damage)
                end
            end
        end
    else
        local sp = ToyboxMod:getEntityData(knife, "GARLIC_AURA")
        if(sp) then
            sp.Scale = Vector.Zero
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, knifePoisonAura)

---@param knife EntityKnife
---@param offset Vector
local function renderKnifeAura(_, knife, offset)
    if(not (knife:IsFlying() or knife:HasTearFlags(TearFlags.TEAR_LUDOVICO) or knife.SubType==KnifeSubType.PROJECTILE)) then return end

    local pl = ToyboxMod:getPlayerFromEnt(knife)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    
    local sp = ToyboxMod:getEntityData(knife, "GARLIC_AURA")
    if(not sp) then
        sp = Sprite("gfx_tb/effects/effect_tear_aura.anm2", true)
        sp:Play("Idle", true)
        sp.Color = Color(0.2,1,0.2,1,0,0.1,0)
        sp.Scale = Vector.Zero

        ToyboxMod:setEntityData(knife, "GARLIC_AURA", sp)
    end

    sp.Scale = ToyboxMod:lerp(sp.Scale, 10*knife.Scale*AURA_SIZE_MULT/60*Vector(1,1), 0.33)
    sp:Render(Isaac.WorldToRenderPosition(knife.Position)+offset)

    if(not Game():IsPaused()) then
        sp:Update()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_KNIFE_RENDER, renderKnifeAura)

---@param rocket EntityEffect
local function epicFetusPoisonAura(_, rocket)
    local pl = ToyboxMod:getPlayerFromEnt(rocket)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    rocket.Color = Color.TearScorpio

    local auraSize = 10*rocket.Scale*AURA_SIZE_MULT

    local plRef = EntityRef(player)

    for _, ent in ipairs(Isaac.FindInRadius(rocket.Position, auraSize, EntityPartition.ENEMY)) do
        if(ToyboxMod:isValidEnemy(ent)) then
            local countdown = ent:GetPoisonCountdown()
            if(countdown<POISON_AMOUNT) then
                ent:AddPoison(plRef, POISON_AMOUNT-countdown, POISON_DMG_MULT*pl.Damage)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, epicFetusPoisonAura)

---@param rocket EntityEffect
---@param offset Vector
local function renderEpicFetusAura(_, rocket, offset)
    local pl = ToyboxMod:getPlayerFromEnt(rocket)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    
    local sp = ToyboxMod:getEntityData(rocket, "GARLIC_AURA")
    if(not sp) then
        sp = Sprite("gfx_tb/effects/effect_tear_aura.anm2", true)
        sp:Play("Idle", true)
        sp.Color = Color(0.2,1,0.2,1,0,0.1,0)
        sp.Scale = Vector.Zero

        ToyboxMod:setEntityData(rocket, "GARLIC_AURA", sp)
    end

    sp.Scale = 10*rocket.Scale*AURA_SIZE_MULT/60*Vector(1,1)
    sp:Render(Isaac.WorldToRenderPosition(rocket.Position)+offset)

    if(not Game():IsPaused()) then
        sp:Update()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, renderEpicFetusAura, EffectVariant.TARGET)

---@param laser EntityLaser
local function laserPoisonAura(_, laser)
    local pl = ToyboxMod:getPlayerFromEnt(laser)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    local samples = laser:GetSamples()

    local auraSize = laser:GetScale()*laser.Size*AURA_SIZE_MULT

    local hitlist = {}
    local plRef = EntityRef(player)

    for i=1, #samples-1 do
        local point = samples:Get(i)
        local prevPoint = samples:Get(i-1)
        local c = Capsule(prevPoint, point, auraSize)
        for _, ent in ipairs(Isaac.FindInCapsule(c, EntityPartition.ENEMY)) do
            local hash = GetPtrHash(ent)
            if(ToyboxMod:isValidEnemy(ent) and not hitlist[hash]) then
                hitlist[hash] = true

                local countdown = ent:GetPoisonCountdown()
                if(countdown<POISON_AMOUNT) then
                    ent:AddPoison(plRef, POISON_AMOUNT-countdown, POISON_DMG_MULT*pl.Damage)
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, laserPoisonAura)

local alreadyRendering = false
---@param laser EntityLaser
---@param offset Vector
local function renderLaserAura(_, laser, offset)
    if(alreadyRendering) then return end

    local pl = ToyboxMod:getPlayerFromEnt(laser)
    if(not (pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_GARLIC))) then return end

    alreadyRendering = true

    local ogColor = laser.Color
    local ogScale = laser.SpriteScale

    local newCol = ToyboxMod:cloneColor(Color.LaserPoison)
    newCol.A = newCol.A*LASER_AURA_ALPHA
    laser.Color = newCol

    local maxscale = AURA_SIZE_MULT*1.2
    local numrenders = LASER_AURA_RENDERS
    for i=numrenders,1,-1 do
        local scl = maxscale*i/numrenders
        laser.SpriteScale = laser.SpriteScale*scl
        
        laser:Render(offset+Vector((math.random()*2-1)*1, (math.random()*2-1)*1))

        laser.SpriteScale = laser.SpriteScale/scl
    end

    laser.SpriteScale = ogScale

    ogColor.A = ogColor.A*0.5
    laser.Color = ogColor

    laser:Render(offset)

    ogColor.A = ogColor.A/0.5
    laser.Color = ogColor

    alreadyRendering = false
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, renderLaserAura)