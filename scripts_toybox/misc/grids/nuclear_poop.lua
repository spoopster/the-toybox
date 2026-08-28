local POISON_RADIUS = 40*2
local POISON_DMG = 2
local POISON_DURATION = 30*3

local MIN_DMG = 0.6
local MAX_DMG = 3
local DMG_FREQ = 8

local NUCLEAR_COLOR = Color(255/100,255/59,255/49,1,0,0,0,196/255*0.5,218/255*0.5,112/255*0.5,1)

local GAS_COLOR = Color(0.8,1,0.5,0.28,0.1,0.35,0.05)
local GAS_COLOR_EMPTY = Color.Lerp(GAS_COLOR, GAS_COLOR, 1)
GAS_COLOR_EMPTY.A = 0

local EXTRA_POOP_DATA = {}

local function resetStuff(_)
    EXTRA_POOP_DATA = {}
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT-1, resetStuff)

---@param effect EntityEffect
local function replaceHelper(_, effect)
    if(effect.SubType==ToyboxMod.GRID_NUCLEAR_POOP) then
        effect.Visible = false
        local room = ToyboxMod.GAME:GetRoom()
        local idx = room:GetGridIndex(effect.Position)

        room:RemoveGridEntityImmediate(idx, 0, false)
        local worked = room:SpawnGridEntity(idx, GridEntityType.GRID_POOP, GridPoopVariant.NORMAL, effect.InitSeed)
        if(worked) then
            local poop = room:GetGridEntity(idx)
            if(poop) then
                local data = ToyboxMod:getGridEntityDataTable(poop)
                data.ELEPHANT_FOOT = true

                poop:Init(poop.Desc.SpawnSeed)

                local sp = poop:GetSprite()
                if(ToyboxMod.GAME:GetRoom():GetFrameCount()<=0) then
                    sp:SetFrame(sp:GetCurrentAnimationData():GetLength()-1)
                end
            end
        end
        effect:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, replaceHelper, ToyboxMod.EFFECT_GRID_HELPER)

---@param poop GridEntityPoop
local function initSprite(_, poop, _, firstinit)
    if(not ToyboxMod:getGridEntityData(poop, "ELEPHANT_FOOT")) then return end

    poop:GetSprite():ReplaceSpritesheet(0, "gfx_tb/grid/grid_nuclear_poop_"..ToyboxMod:generateRng(poop.Desc.SpawnSeed):RandomInt(1,3)..".png", true)

    local data = {}
    if(poop.State<1000) then
        local light = EntityEffect.CreateLight(poop.Position, (1-(poop.State//250)*250/1000)*2, -1, 6, Color(1,1,1,1,1,1,0))
        data.LightEnt = light

        data.GasSprite1 = Sprite("gfx_tb/effects/effect_pipe_smoke.anm2", true)
        data.GasSprite1:Play("Idle", true)
        data.GasSprite1.PlaybackSpeed = 0.4

        data.GasSprite2 = Sprite("gfx_tb/effects/effect_pipe_smoke.anm2", true)
        data.GasSprite2:Play("Idle", true)
        data.GasSprite2.PlaybackSpeed = 0.2
        data.GasSprite2.Rotation = 45

        data.InitFrame = ToyboxMod.GAME:GetRoom():GetFrameCount()
    end

    EXTRA_POOP_DATA[tostring(poop.Desc.SpawnSeed)] = data
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_POOP_INIT, initSprite, GridPoopVariant.NORMAL)

---@param effect EntityEffect
local function gibSpawn(_, effect)
    local ent = ToyboxMod.GAME:GetRoom():GetGridEntityFromPos(effect.Position)
    if(ent and ent:ToPoop()) then
        local isNuclear = ToyboxMod:getGridEntityData(ent:ToPoop(), "ELEPHANT_FOOT")
        if(isNuclear) then
            effect.Color = NUCLEAR_COLOR
            ToyboxMod:setEntityData(effect, "ELEPHANT_FOOT_GIBS", true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, gibSpawn, EffectVariant.POOP_PARTICLE)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, gibSpawn, EffectVariant.POOP_EXPLOSION)

---@param effect EntityEffect
local function gibUpdate(_, effect)
    if(not ToyboxMod:getEntityData(effect, "ELEPHANT_FOOT_GIBS")) then return end

    effect.Color = NUCLEAR_COLOR
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, gibUpdate, EffectVariant.POOP_PARTICLE)


---@param poop GridEntityPoop
---@param dmg integer
---@param source EntityRef
local function reduceDamage(_, poop, dmg, source)
    if(ToyboxMod:getGridEntityData(poop, "ELEPHANT_FOOT")) then
        if(source and source.Entity and ToyboxMod:getPlayerFromEnt(source.Entity)) then
            if(poop:GetRNG():RandomFloat()<0.5) then
                return 0
            else
                poop.State = poop.State-250
            end
        else
            return false
        end
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_GRID_HURT, CallbackPriority.LATE+1, reduceDamage, GridEntityType.GRID_POOP)

---@param poop GridEntityPoop
---@param dmg integer
---@param source EntityRef
local function reduceLight(_, poop, dmg, source)
    if(ToyboxMod:getGridEntityData(poop, "ELEPHANT_FOOT")) then
        local seed = tostring(poop.Desc.SpawnSeed)

        local light = (EXTRA_POOP_DATA[seed] and EXTRA_POOP_DATA[seed].LightEnt) ---@type EntityEffect?
        if(light and light:Exists() and light:ToEffect()) then
            light:ToEffect().Scale = (1-(poop.State//250)*250/1000)*2
            light.SpriteScale = Vector(1,1)*light:ToEffect().Scale
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_HURT, reduceLight, GridEntityType.GRID_POOP)

local function updateNuclearPoop(_, poop)
    if(ToyboxMod:getGridEntityData(poop, "ELEPHANT_FOOT")) then
        local data = EXTRA_POOP_DATA[tostring(poop.Desc.SpawnSeed)]
        if(not data) then return end

        if(poop.State>=1000 and not data.DeathFrame) then
            data.DeathFrame = ToyboxMod.GAME:GetRoom():GetFrameCount()
        end
        if(poop.State>=1000 and data.LightEnt and data.LightEnt:Exists()) then
            data.LightEnt:Remove()
            data.LightEnt = nil
        end

        if(poop.State<1000 and (ToyboxMod.GAME:GetRoom():GetFrameCount()-(data.InitFrame or 0))%DMG_FREQ==0) then
            for _, ent in ipairs(Isaac.FindInRadius(poop.Position, POISON_DURATION, EntityPartition.ENEMY)) do
                if(ToyboxMod:isValidEnemy(ent)) then
                    local plRef = EntityRef(PlayerManager.GetRandomCollectibleOwner(ToyboxMod.COLLECTIBLE_ELEPHANTS_FOOT, poop.Desc.SpawnSeed))
                    ent:AddPoison(plRef, -POISON_DURATION, POISON_DMG)

                    local lerp = ToyboxMod:clamp((ent.Position:Distance(poop.Position))/POISON_RADIUS, 0, 1)
                    local dmg = ToyboxMod:lerp(MIN_DMG, MAX_DMG, 1-lerp)
                    ent:TakeDamage(dmg, DamageFlag.DAMAGE_ACID, EntityRef(nil), 15)
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_UPDATE, updateNuclearPoop, GridEntityType.GRID_POOP)

local GAS_SPRITE = Sprite("gfx_tb/effects/effect_pipe_smoke.anm2", true)
GAS_SPRITE:Play("Idle", true)

local CANCEL_RENDER = false

local function renderPoopGas(_, poop)
    if(CANCEL_RENDER) then return end
    if(ToyboxMod:getGridEntityData(poop, "ELEPHANT_FOOT")) then
        local data = EXTRA_POOP_DATA[tostring(poop.Desc.SpawnSeed)]
        if(not (data and data.InitFrame)) then return end

        local scale = Vector(1,1)*POISON_RADIUS/39*1.1

        local roomFrame = ToyboxMod.GAME:GetRoom():GetFrameCount()
        local time = 0
        if(data.DeathFrame) then
            if(data.DeathFrame>0 and roomFrame-data.DeathFrame<=15) then
                time = 1-(roomFrame-data.DeathFrame)/15
            end
        else
            if(data.InitFrame>0 and (roomFrame-data.InitFrame)<=20) then
                time = (roomFrame-data.InitFrame)/20
            else
                time = 0.9+0.1*math.cos(math.rad(roomFrame-data.InitFrame)*4)
            end
        end
        if(time<=0) then return end
        local color =  Color.Lerp(GAS_COLOR_EMPTY, GAS_COLOR, time)

        local scrollOffs = ToyboxMod.GAME:GetRoom():GetRenderScrollOffset()
        local rpos = Isaac.WorldToRenderPosition(poop.Position)+scrollOffs

        for i=1, 2 do
            local spr = data["GasSprite"..tostring(i)]

            spr.Scale = scale
            spr.Color = color

            spr:Render(rpos)
            spr:Update()
        end

        if(not data.DeathFrame) then
            CANCEL_RENDER = true
            poop:Render(scrollOffs)
            CANCEL_RENDER = false
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_RENDER, renderPoopGas, GridEntityType.GRID_POOP)