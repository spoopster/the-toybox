
local sfx = SFXManager()

--! make a fucking graphic for this loser
--? never mind i reworked item
local DAMAGE_COOLDOWN_MULT = 0.1
local DAMAGE_BLOCK_FRAMES = 60*2.5

local DAMAGE_BLOCK_CHANCE = 0.15
local DAMAGE_BLOCK_CHANCEMAX = 0.5
local DAMAGE_BLOCK_CHANCELUCK = 30
local DAMAGE_BLOCK_STACKCHANCE = 0.1

---@param pl Entity
local function iwanttoNamethisOne(_, pl, dmg, flags, source, countdown)
    pl = pl:ToPlayer()
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_PAINKILLERS)) then return end

    local chance = ToyboxMod:getLuckAffectedChance(pl.Luck, DAMAGE_BLOCK_CHANCE, DAMAGE_BLOCK_CHANCEMAX, DAMAGE_BLOCK_CHANCELUCK)
    chance = math.min(0.5, chance+DAMAGE_BLOCK_STACKCHANCE*(pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_PAINKILLERS)-1))
    if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_PAINKILLERS):RandomFloat()<chance) then
        ToyboxMod:setEntityData(pl, "PAINKILLERS_DAMAGE_PROC", true)

        return
        {
            Damage = 0,
            DamageFlags = flags,
            DamageCountdown = countdown,
        }
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, iwanttoNamethisOne, EntityType.ENTITY_PLAYER)

---@param pl Entity
local function idontwanttonamThisone(_, pl)
    pl = pl:ToPlayer()
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_PAINKILLERS)) then return end
    if(ToyboxMod:getEntityData(pl, "PAINKILLERS_DAMAGE_PROC")) then
        pl:SetMinDamageCooldown(DAMAGE_BLOCK_FRAMES*(pl:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE)+1))
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
        local bloodSplat = Isaac.Spawn(1000,16,3,pl.Position,Vector.Zero,nil):ToEffect()
        bloodSplat.DepthOffset = 5

        local bloodCloud = Isaac.Spawn(1000,16,4,pl.Position,Vector.Zero,nil):ToEffect()
        bloodCloud.DepthOffset = -5
    else
        local frames = pl:GetDamageCooldown()
        pl:ResetDamageCooldown()
        if(pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_PAINKILLERS)==1) then
            pl:SetMinDamageCooldown(math.floor(frames*DAMAGE_COOLDOWN_MULT))
        end
    end
    ToyboxMod:setEntityData(pl, "PAINKILLERS_DAMAGE_PROC", nil)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, CallbackPriority.LATE, idontwanttonamThisone, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
local function painkillersTimerUpdate(_, player)
    ToyboxMod:setEntityData(player, "PAINKILLERS_DAMAGE_PROC", nil)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, painkillersTimerUpdate)

--[[
local DAMAGE_COUNTER_ROOT_POWER = 3.5
local DAMAGE_TIMER = 60*1
local DMG_MULT = 1.25

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

local uiSprite = Sprite("gfx_tb/ui/ui_painkillers.anm2", true)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_PAINKILLERS)) then return end

    if(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*DMG_MULT
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

--!!! DAMAGE SECTION
local function calcPainkillerDamage(player)
    local dmg = ToyboxMod:getEntityData(player, "PAINKILLERS_DAMAGE_COUNTER") or 0

    return math.floor(dmg^(1/DAMAGE_COUNTER_ROOT_POWER))
end
local function calcPainkillerTimer(player)
    return math.floor( DAMAGE_TIMER*(1+(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_PAINKILLERS)-1)*0.5) )
end

---@param player EntityPlayer
local function painkillersTimerUpdate(_, player)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_PAINKILLERS)) then return end

    local data = ToyboxMod:getEntityDataTable(player)
    data.PAINKILLERS_DAMAGE_TIMER = data.PAINKILLERS_DAMAGE_TIMER or 0

    if(data.PAINKILLERS_CANCELLING_DAMAGE==false) then
        data.PAINKILLERS_DAMAGE_COUNTER = 0
        data.PAINKILLERS_DAMAGE_TIMER = 0
        data.PAINKILLERS_CANCELLING_DAMAGE=nil
    end

    if(data.PAINKILLERS_DAMAGE_TIMER>0) then
        data.PAINKILLERS_DAMAGE_TIMER = data.PAINKILLERS_DAMAGE_TIMER-1

        if(data.PAINKILLERS_DAMAGE_TIMER==0) then
            data.PAINKILLERS_CANCELLING_DAMAGE = false
            local b = player:TakeDamage(1,0,EntityRef(player),0)
            if(b~=false) then
                local bloodSplat = Isaac.Spawn(1000,16,3,player.Position,Vector.Zero,nil):ToEffect()
                bloodSplat.DepthOffset = 5

                local bloodCloud = Isaac.Spawn(1000,16,4,player.Position,Vector.Zero,nil):ToEffect()
                bloodCloud.DepthOffset = -5

                sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 1)
                sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1.3)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, painkillersTimerUpdate)

---@param player EntityPlayer
local function painkillersCancelDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_PAINKILLERS)) then return end
    local data = ToyboxMod:getEntityDataTable(player)

    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    if(data.PAINKILLERS_CANCELLING_DAMAGE==nil) then data.PAINKILLERS_CANCELLING_DAMAGE=true end

    if(data.PAINKILLERS_CANCELLING_DAMAGE==true) then
        data.PAINKILLERS_DAMAGE_TIMER = calcPainkillerTimer(player)+5

        local oldDmg = calcPainkillerDamage(player)
        data.PAINKILLERS_DAMAGE_COUNTER = (data.PAINKILLERS_DAMAGE_COUNTER or 0)+dmg*2

        if(oldDmg~=calcPainkillerDamage(player)) then
            local bloodSplat = Isaac.Spawn(1000,2,0,player.Position,Vector.Zero,nil):ToEffect()
            bloodSplat.DepthOffset = 5

            sfx:Play(SoundEffect.SOUND_DEATH_BURST_SMALL, 0.8*(math.min(1,oldDmg/4)*0.4+0.6))
        end

        return false
    end
    if(data.PAINKILLERS_CANCELLING_DAMAGE==false) then
        local dmgToTake = calcPainkillerDamage(player)
        data.PAINKILLERS_DAMAGE_COUNTER=0
        data.PAINKILLERS_CANCELLING_DAMAGE=nil

        return {
            Damage=dmgToTake,
            DamageFlags=flags,
            DamageCountdown=60*dmgToTake,
        }
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -math.huge, painkillersCancelDamage, EntityType.ENTITY_PLAYER)

---@param p EntityPlayer
local function renderDamageUi(_, p, offset)
    if(not p:HasCollectible(ToyboxMod.COLLECTIBLE_PAINKILLERS)) then return end
    local dmg = ToyboxMod:getEntityData(p, "PAINKILLERS_DAMAGE_COUNTER") or 0
    if(dmg<1) then return end

    local hpType = p:GetHealthType()

    local counter = calcPainkillerDamage(p)*0.5
    if(hpType==HealthType.COIN) then counter = counter*2 end
    if(hpType==HealthType.NO_HEALTH) then counter = 1 end

    local timeLeft = ToyboxMod:getEntityData(p, "PAINKILLERS_DAMAGE_TIMER")/calcPainkillerTimer(p)
    --print(ToyboxMod:getEntityData(p, "PAINKILLERS_DAMAGE_TIMER"), calcPainkillerTimer(p))

    local heartSize = Vector(11,0)
    local heartsNum = math.ceil(counter)
    local renderPos = Isaac.WorldToScreen(p.Position)+Vector(0,10)-heartSize*(heartsNum-1)*0.5

    uiSprite:SetFrame("Bar", math.min(10, math.ceil(timeLeft*10)))
    uiSprite:Render(renderPos-Vector(10,0.5))

    local frameOffset = 0
    if(hpType==HealthType.SOUL) then
        frameOffset = 2
        if(p:GetPlayerType()==PlayerType.PLAYER_BLACKJUDAS or p:GetPlayerType()==PlayerType.PLAYER_JUDAS_B) then frameOffset = 4 end
    elseif(hpType==HealthType.COIN) then frameOffset = 6
    elseif(hpType==HealthType.NO_HEALTH) then frameOffset = 7 end

    for i=1, heartsNum do
        if(i>counter) then frameOffset = frameOffset+1 end
        uiSprite:SetFrame("Hearts", frameOffset)
        uiSprite:Render(renderPos)

        renderPos = renderPos+heartSize
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderDamageUi)
--]]