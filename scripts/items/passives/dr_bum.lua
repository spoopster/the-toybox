local mod = MilcomMOD

local NUM_REQ = 1
local SEARCH_RADIUS = 4.5*40
local FOLLOW_RADIUS = 2*40

local FOLLOW_SPEED = 3
local TAKE_SPEED = 4

local ADVANTAGE_ROLLS = 1
local EXTRA_ADVANTAGE_BFFS = 1

---@param fam EntityFamiliar
local function getDrBumPill(fam)
    local pool = Game():GetItemPool()
    local conf = Isaac.GetItemConfig()

    local rng = fam.Player:GetCollectibleRNG(mod.COLLECTIBLE_DR_BUM)
    local mult = fam:GetMultiplier()

    local pill = pool:GetPillEffect(pool:GetPill(math.max(1, rng:RandomInt(1<<32-1))))
    local currentSub = conf:GetPillEffect(pill).EffectSubClass
    for i=1, ADVANTAGE_ROLLS+math.max(0, (mult-1)*EXTRA_ADVANTAGE_BFFS) do
        local newPill = pool:GetPillEffect(pool:GetPill(math.max(1, rng:RandomInt(1<<32-1))))
        local newSub = conf:GetPillEffect(newPill).EffectSubClass

        if(newSub==mod.PILL_SUBCLASS.GOOD and (currentSub==mod.PILL_SUBCLASS.BAD or currentSub==mod.PILL_SUBCLASS.NEUTRAL)) then
            pill = newPill
            currentSub = newSub
        elseif(newSub==mod.PILL_SUBCLASS.NEUTRAL and currentSub==mod.PILL_SUBCLASS.BAD) then
            pill = newPill
            currentSub = newSub
        end
    end

    return pool:GetPillColor(pill)
end

---@param pl EntityPlayer
local function evalCache(_, pl)
    pl:CheckFamiliar(
        mod.FAMILIAR_DR_BUM,
        pl:GetCollectibleNum(mod.COLLECTIBLE_DR_BUM),
        pl:GetCollectibleRNG(mod.COLLECTIBLE_DR_BUM),
        Isaac.GetItemConfig():GetCollectible(mod.COLLECTIBLE_DR_BUM)
    )
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_FAMILIARS)

---@param fam EntityFamiliar
local function drBumInit(_, fam)
    fam:GetSprite():Play("FloatDown", true)
    fam.State = 0
    fam.Coins = 0
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, drBumInit, mod.FAMILIAR_DR_BUM)

---@param fam EntityFamiliar
local function drBumUpdate(_, fam)
    local sp = fam:GetSprite()

    if(fam.State==0 and fam.FrameCount%10==0) then
        fam.State = 1
    end

    if(fam.State==1) then
        local nearestPickup
        for _, pickup in ipairs(Isaac.FindInRadius(fam.Position,SEARCH_RADIUS, EntityPartition.PICKUP)) do
            pickup = pickup:ToPickup()
            if(pickup.Variant==300 and pickup.Touched~=true and pickup.Wait<=0) then
                nearestPickup = pickup
                
                break
            end
        end

        if(nearestPickup) then
            fam.State = 2
            fam.Target = nearestPickup:ToPickup()
        else
            fam.State = 0
        end
    end

        
    if(fam.State==0) then
        local dir = fam.Player.Position-fam.Position
        if(dir:Length()<=FOLLOW_RADIUS) then
            fam.Velocity = fam.Velocity*0.8

            if(fam.Coins>=NUM_REQ) then
                fam.State = 3
                sp:Play("PreSpawn", true)
            end
        else
            fam.Velocity = mod:lerp(fam.Velocity, dir:Resized(FOLLOW_SPEED), 0.3)
        end
    elseif(fam.State==2) then
        if(not fam.Target) then
            fam.State = 0
        end

        local dir = fam.Target.Position-fam.Position
        fam.Velocity = mod:lerp(fam.Velocity, dir:Resized(TAKE_SPEED), 0.2)
        if(dir:Length()<3) then
            fam.Target.Velocity = Vector.Zero
            fam.Target:ToPickup().Touched = true
            fam.Target:ToPickup():PlayPickupSound()
            if(fam.Target:GetSprite():GetAnimationData("Collect")) then
                fam.Target:GetSprite():Play("Collect", true)
                fam.Target:Die()
            else
                fam.Target:Remove()
            end

            fam.Target = nil
            fam.Coins = fam.Coins + 1
            fam.State = 1
        end
    elseif(fam.State==3) then
        fam.Velocity = fam.Velocity*0.7

        if(sp:IsFinished("PreSpawn")) then
            local pill = Isaac.Spawn(5,70,getDrBumPill(fam),Game():GetRoom():FindFreePickupSpawnPosition(fam.Position,40),Vector.Zero,fam):ToPickup()
            fam.Coins = fam.Coins - NUM_REQ

            sp:Play("Spawn", true)
        end
        if(sp:IsFinished("Spawn")) then
            fam.State = 0
            sp:Play("FloatDown", true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, drBumUpdate, mod.FAMILIAR_DR_BUM)