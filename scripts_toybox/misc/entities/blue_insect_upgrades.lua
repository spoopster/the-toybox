

local FLY_SUB_BITSHIFT = 5
local FLY_SUB_BITMASK = (1<<0 | 1<<1 | 1<<2)
-- 1: dummy fly, for morphing into a regular fly 
-- 2: moter fly
-- 3: sucker
-- 4: pooter
-- 5: lvl2 fly

local SPIDER_SUB_BITSHIFT = 5
local SPIDER_SUB_BITMASK = (1<<0 | 1<<1 | 1<<2)
-- 1: dummy spider, for morphing into a regular spider
-- 2: big spider
-- 3: lvl2 spider
-- 4: swarm spider
-- 5: small crazy long legs


local LOCUST_SUB_BITMASK = (1<<0 | 1<<1 | 1<<2)
local LOCUST_SUB_COLORS = {
    [0] = Color.Default,
    [1] = Color(1,1,0,1,0.49),
    [2] = Color(1,1,0,1,0,0.314),
    [3] = Color(0.61,0.61,0,1,0.39,0.235),
    [4] = Color(0,0,0,1),
    [5] = Color(1,1,1,1,0.785,0.785,0.785),
}
local LOCUST_SUB_NAMES = {
    [0] = "",
    [1] = "Wrath",
    [2] = "Pestilence",
    [3] = "Famine",
    [4] = "Death",
    [5] = "Conquest",
}

---@param x integer
function ToyboxMod:getBinary(x)
    local s = ""
    for _=0, 15 do
        s = tostring(x%2)..s

        x = x//2
    end
    print(s)
end

function ToyboxMod:getTypeCol(t, c)
    return (t << FLY_SUB_BITSHIFT) + c
end


---@param ent Entity
function ToyboxMod:getBlueInsectType(ent)
    if(ent.Type==EntityType.ENTITY_FAMILIAR) then
        if(ent.Variant==FamiliarVariant.BLUE_FLY) then
            return (ent.SubType>>FLY_SUB_BITSHIFT) & FLY_SUB_BITMASK, ent.SubType & LOCUST_SUB_BITMASK
        elseif(ent.Variant==FamiliarVariant.BLUE_SPIDER) then
            return (ent.SubType>>SPIDER_SUB_BITSHIFT) & SPIDER_SUB_BITMASK, 0
        end
    end

    return 0, 0
end

---@param fam EntityFamiliar
local function turnDummyIntoRegular(fam)
    local type, loc = ToyboxMod:getBlueInsectType(fam)
    if(type~=1) then return end

    --if(loc~=0) then
        fam.SubType = loc
        fam.Color = LOCUST_SUB_COLORS[0]
        fam:GetSprite():Play(LOCUST_SUB_NAMES[loc] and ("Locust"..LOCUST_SUB_NAMES[loc]) or "Idle", true)
    --end
end

---@param familiar EntityFamiliar
local function specialInsectInit(_, familiar)
    local type, loc = ToyboxMod:getBlueInsectType(familiar)
    if(type==0) then return end

    familiar.Color = LOCUST_SUB_COLORS[loc] or LOCUST_SUB_COLORS[0]
    turnDummyIntoRegular(familiar)
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, specialInsectInit, FamiliarVariant.BLUE_FLY)
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, specialInsectInit, FamiliarVariant.BLUE_SPIDER)

--#region flies

---@param fam EntityFamiliar
local function specialFlyInit(_, fam)
    local type, loc = ToyboxMod:getBlueInsectType(fam)
    if(type<=1) then return end

    local sp = fam:GetSprite()
    if(type==2) then -- moter
        sp:Load("gfx_tb/familiars/blue bugs/moter.anm2", true)
        sp:Play("Idle", true)
    elseif(type==3) then -- sucker
        sp:Load("gfx_tb/familiars/blue bugs/sucker.anm2", true)
        sp:Play("Idle", true)
    elseif(type==4) then -- pooter
        sp:Load("gfx_tb/familiars/blue bugs/pooter.anm2", true)
        sp:Play("Idle", true)
    elseif(type==5) then -- lvl2 fly
        sp:Load("gfx_tb/familiars/blue bugs/lvl2 fly.anm2", true)
        sp:Play("Idle", true)

        fam.Hearts = 2
    end

    if(loc==4) then
        fam.CollisionDamage = fam.CollisionDamage*2
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, specialFlyInit, FamiliarVariant.BLUE_FLY)

---@param fam EntityFamiliar
---@param color integer
---@param ent Entity
---@param flags DamageFlag
---@param amt number
---@param countdown integer
local function triggerLocustEffects(fam, color, ent, flags, amt, countdown)
    local mult = fam:GetMultiplier()
    if(color==1) then
        local bombFlags = fam.Player:GetBombFlags()
        ToyboxMod.GAME:BombExplosionEffects(fam.Position, (mult>1 and 85 or 60), bombFlags, nil, fam.Player, 0.5)
    elseif(color==2) then
        ent:AddPoison(EntityRef(fam), 40, fam.Player.Damage)
    elseif(color==3) then
        ent:AddSlowing(EntityRef(fam), 300, 0.5, Color(1,1,1.3,1,0.156863,0.156863,0.156863))
    elseif(color==4) then
        ent:TakeDamage(amt, flags | DamageFlag.DAMAGE_CLONES, EntityRef(fam), countdown)
    end
end

local flyFunctions = {
    [2] = { -- Moter
        ---@param fam EntityFamiliar
        ---@param locustColor integer
        OnHit = function(fam, locustColor)
            for i=1, 2 do
                local vel = fam.Velocity:Rotated(90*(2*i-3)):Resized(8)
                local newFam = Isaac.Spawn(3,FamiliarVariant.BLUE_FLY,ToyboxMod:getTypeCol(1,locustColor),fam.Position,vel,fam.Player):ToFamiliar()
                newFam.Player = fam.Player
                newFam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

                ToyboxMod:setEntityData(newFam, "CANCEL_FAMILIAR_LOGIC", 9)
            end
        end,
    },
    [3] = { -- Sucker
        ---@param fam EntityFamiliar
        ---@param locustColor integer
        Update = function(fam, locustColor)
            fam.FlipX = ((fam.OrbitLayer==-1) and fam.Velocity.X<0)
        end,
        ---@param fam EntityFamiliar
        ---@param locustColor integer
        OnHit = function(fam, locustColor)
            for i=1, 4 do
                local vel = Vector.FromAngle(i*90)

                if(locustColor==1) then
                    local bomb = Isaac.Spawn(4,BombVariant.BOMB_SMALL,0,fam.Position-fam.Velocity:Resized(15)+vel*15,vel,fam):ToBomb()
                    bomb.RadiusMultiplier = bomb.RadiusMultiplier*0.5
                    bomb.ExplosionDamage = fam.Player.Damage+10
                    bomb:SetLoadCostumes(true)
                    bomb:SetExplosionCountdown(12)
                    bomb.Velocity = vel*10
                else
                    local tear = fam:FireProjectile(vel)
                    tear.CollisionDamage = fam.Player.Damage

                    if(locustColor==2) then
                        tear:AddTearFlags(TearFlags.TEAR_POISON)
                        tear.Color = Color(0.4,0.97,0.5,1,0,0,0)
                    elseif(locustColor==3) then
                        tear:AddTearFlags(TearFlags.TEAR_SLOW)
                        tear.Color = Color(2,2,2,1,0.196,0.196,0.196)
                    elseif(locustColor==4) then
                        tear.CollisionDamage = tear.CollisionDamage*2
                        tear:ChangeVariant(TearVariant.DARK_MATTER)
                        tear.Scale = tear.Scale*1.5
                    end
                end
            end
        end,
    },
    [4] = { -- Pooter
        ---@param fam EntityFamiliar
        ---@param locustColor integer
        Update = function(fam, locustColor)
            fam.FireCooldown = fam.FireCooldown - (fam.Player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) and 2 or 1)

            local shootDist = 30*4.5

            local startSlowDist = 30*6
            local endSlowDist = 30*2.5
            local maxSlow = 0.25

            local sp = fam:GetSprite()
            if(sp:IsFinished("Attack")) then
                sp:Play("Idle", true)
            end

            local data = ToyboxMod:getEntityDataTable(fam)

            local slowing = 1
            if(fam.Target) then
                local dist = fam.Position:Distance(fam.Target.Position)
                if(dist<=startSlowDist) then
                    local clampedDist = ToyboxMod:clamp(dist, endSlowDist, startSlowDist)
                    clampedDist = (clampedDist-endSlowDist)/(startSlowDist-endSlowDist)

                    slowing = ToyboxMod:lerp(maxSlow, 1, clampedDist)
                end

                if(dist<=shootDist and fam.FireCooldown<=0) then
                    sp:Play("Attack", true)

                    fam.FireCooldown = 40
                end

                if(sp:IsEventTriggered("Shoot")) then
                    local vel = (fam.Target.Position+fam.Target.Velocity*4-fam.Position):Resized(1)

                    if(locustColor==1) then
                        local bomb = Isaac.Spawn(4,BombVariant.BOMB_SMALL,0,fam.Position,vel,fam):ToBomb()
                        bomb.RadiusMultiplier = bomb.RadiusMultiplier*0.5
                        bomb.ExplosionDamage = fam.Player.Damage+10
                        bomb:SetLoadCostumes(true)
                        bomb:SetExplosionCountdown(12)
                        bomb.Velocity = vel*8.5
                    else
                        local tear = fam:FireProjectile(vel)
                        tear.CollisionDamage = fam.Player.Damage

                        if(locustColor==2) then
                            tear:AddTearFlags(TearFlags.TEAR_POISON)
                            tear.Color = Color(0.4,0.97,0.5,1,0,0,0)
                        elseif(locustColor==3) then
                            tear:AddTearFlags(TearFlags.TEAR_SLOW)
                            tear.Color = Color(2,2,2,1,0.196,0.196,0.196)
                        elseif(locustColor==4) then
                            tear.CollisionDamage = tear.CollisionDamage*2
                            tear:ChangeVariant(TearVariant.DARK_MATTER)
                            tear.Scale = tear.Scale*1.5
                        end
                    end
                end
            end

            fam.FlipX = ((fam.OrbitLayer==-1) and fam.Velocity.X<0)

            data.POOTER_SLOW = ToyboxMod:lerp((data.POOTER_SLOW or 1), slowing, 0.3)
            fam.Velocity = fam.Velocity*data.POOTER_SLOW
        end,
    },
    [5] = { -- Lvl.2 Fly
        ---@param fam EntityFamiliar
        ---@param locustColor integer
        OnHit = function(fam, locustColor)
            if(fam.Hearts>0) then
                local newFam = Isaac.Spawn(3,fam.Variant,fam.SubType,fam.Position,fam.Velocity,fam.Player):ToFamiliar()
                newFam.Player = fam.Player
                newFam.Hearts = fam.Hearts-1
                newFam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

                local color = newFam.Color
                newFam:SetColor(Color(color.R+0.1,color.G,color.B,1,color.RO+0.1,color.GO,color.BO),2,0,false,false)

                ToyboxMod:setEntityData(newFam, "CANCEL_FAMILIAR_LOGIC", 15)
            end
        end,
    },
}

---@param fam EntityFamiliar
local function specialFlyUpdate(_, fam)
    local type, loc = ToyboxMod:getBlueInsectType(fam)
    if(type<=1) then return end

    if(flyFunctions[type] and flyFunctions[type].Update) then
        flyFunctions[type].Update(fam, loc)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, specialFlyUpdate, FamiliarVariant.BLUE_FLY)

---@param ent Entity
---@param amt number
---@param flags DamageFlag
---@param sourceRef EntityRef
---@param cooldown integer
local function specialFlyDamage(_, ent, amt, flags, sourceRef, cooldown)
    if(flags & DamageFlag.DAMAGE_CLONES ~= 0) then return end

    local source = sourceRef.Entity and sourceRef.Entity:ToFamiliar()
    if(not (source and source.Variant==FamiliarVariant.BLUE_FLY)) then return end

    local type, loc = ToyboxMod:getBlueInsectType(source)
    if(type>1) then
        if(flyFunctions[type] and flyFunctions[type].OnHit) then
            flyFunctions[type].OnHit(source, loc, ent, flags, amt, cooldown)
        end

        return triggerLocustEffects(source, loc, ent, flags, amt, cooldown)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, specialFlyDamage)

--#endregion

--#region spiders

---@param familiar EntityFamiliar
local function mangosteen2(_, familiar)
    familiar.SubType = ToyboxMod:getTypeCol(4)
end
--ToyboxMod:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, CallbackPriority.IMPORTANT, mangosteen2, FamiliarVariant.BLUE_SPIDER)

---@param fam EntityFamiliar
local function specialSpiderInit(_, fam)
    local type, loc = ToyboxMod:getBlueInsectType(fam)
    if(type<=1) then return end

    local sp = fam:GetSprite()
    if(type==2) then -- big spider
        sp:Load("gfx_tb/familiars/blue bugs/big spider.anm2", true)
        sp:Play("Idle", true)
    elseif(type==3) then -- lvl2 spider
        sp:Load("gfx_tb/familiars/blue bugs/lvl2 spider.anm2", true)
        sp:Play("Idle", true)

        fam:SetShadowSize(fam:GetShadowSize()*1.5)
    elseif(type==4) then -- swarm spider
        sp:Load("gfx_tb/familiars/blue bugs/swarm spider.anm2", true)
        sp:Play("Idle", true)
    elseif(type==5) then -- crazy long legs
        sp:Load("gfx_tb/familiars/blue bugs/crazy long legs.anm2", true)
        sp:Play("Idle", true)

        fam:SetShadowSize(fam:GetShadowSize()*1.1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, specialSpiderInit, FamiliarVariant.BLUE_SPIDER)

--#endregion


---@param fam EntityFamiliar
local function familiarUpdate(_, fam)
    if(ToyboxMod:getEntityData(fam, "CANCEL_FAMILIAR_LOGIC")) then
        fam.Target = nil

        local data = ToyboxMod:getEntityDataTable(fam)
        data.CANCEL_FAMILIAR_LOGIC = (data.CANCEL_FAMILIAR_LOGIC or 0)-1
        if(data.CANCEL_FAMILIAR_LOGIC==0) then
            data.CANCEL_FAMILIAR_LOGIC = nil
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiarUpdate)

---@param fam EntityFamiliar
local function familiarCollision(_, fam)
    if(ToyboxMod:getEntityData(fam, "CANCEL_FAMILIAR_LOGIC")) then
        return true
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, familiarCollision)