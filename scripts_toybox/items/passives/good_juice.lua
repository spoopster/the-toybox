local sfx = SFXManager()
local font = Font()
font:Load("font/teammeatfont10.fnt")

local HP_FOR_JUICE = 1
local FINAL_JUICE_EXPO = 1

local JUICE_REQ_BASE = 50
local JUICE_REQ_PER_FLOOR = 25
local JUICE_DRAIN_FRAMES = 30

local JUICE_OUTCOME_PICKER = WeightedOutcomePicker()
JUICE_OUTCOME_PICKER:AddOutcomeWeight(1, 5) -- random pickup
JUICE_OUTCOME_PICKER:AddOutcomeWeight(2, 1) -- random stat

local STAT_UPS = {
    SPEED = 0.1,
    TEARS = 0.35,
    DAMAGE = 0.5,
    RANGE = 0.5,
    SHOTSPEED = 0.1,
    LUCK = 1,
}

local JUICE_PARTICLE_SPEED = 35
local JUICE_PARTICLE_INITSPEED = 25
local JUICE_PARTICLE_INITARC = 25

local juiceSprite = Sprite("gfx_tb/effects/effect_juice.anm2")
juiceSprite:Play("Idle", true)
juiceSprite:GetLayer("main"):SetCustomShader("spriteshaders/rainbowshader")

local juiceFrameThresholds = {
    [0] = 7,
    [1] = 6,
    [5] = 5,
    [10] = 4,
    [25] = 3,
    [50] = 2,
    [100] = 1,
    [200] = 0,
}

---@param num number
local function addJuice(num)
    local data = ToyboxMod:getExtraDataTable()
    data.GOOD_JUICE_NUM = math.max((data.GOOD_JUICE_NUM or 0)+num, 0)
end

---@param num number
function ToyboxMod:addJuice(num)
    addJuice(num)
end

---@param pos Vector
---@param sub number
---@param coll Entity
local function evaluateJuiceCollision(pos, sub, coll)
    if(coll:ToPlayer()) then
        addJuice(sub)
    elseif(coll:ToSlot() and coll.Variant==ToyboxMod.SLOT_VARIANT.JUICE_FOUNTAIN) then
        local rng = coll:GetDropRNG()
        local outcome = JUICE_OUTCOME_PICKER:PickOutcome(rng)
        if(outcome==1) then --pickup
            local vel = (coll.Position-pos):Resized(8)
            local pickup = Isaac.Spawn(5,0,NullPickupSubType.NO_COLLECTIBLE,coll.Position+vel,vel,nil)

            if(pickup.Variant==PickupVariant.PICKUP_BOMB) then
                if(pickup.SubType==BombSubType.BOMB_TROLL or pickup.SubType==BombSubType.BOMB_SUPERTROLL or pickup.SubType==BombSubType.BOMB_GOLDENTROLL) then
                    pickup.Position = pickup.Position+vel*5
                end
            end

            pickup:AddKnockback(EntityRef(nil), vel, 15, false)
        elseif(outcome==2) then
            local stat = ({"SPEED","TEARS","DAMAGE","RANGE","SHOTSPEED","LUCK"})[rng:RandomInt(1,6)]
            for i=0, Game():GetNumPlayers()-1 do
                local pl = Isaac.GetPlayer(i)
                if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOOD_JUICE)) then
                    local data = ToyboxMod:getEntityDataTable(pl)
                    data.GOOD_JUICE_STATS = data.GOOD_JUICE_STATS or {}
                    data.GOOD_JUICE_STATS[stat] = (data.GOOD_JUICE_STATS[stat] or 0)+STAT_UPS[stat]
                    pl:AddCacheFlags(CacheFlag.CACHE_ALL, true)
                    pl:AnimateHappy()
                end
            end

            sfx:Play(SoundEffect.SOUND_THUMBSUP)
        end
    end

    sfx:Play(SoundEffect.SOUND_MEAT_JUMPS)
end

---@param pos Vector
---@param num number
---@param sp Entity
local function spawnJuiceParticle(pos, num, sp)
    num = math.ceil(num or 1)

    if(ToyboxMod.CONFIG.GOOD_JUICE_LESSLAG==2) then
        evaluateJuiceCollision(pos, num, sp)
    else
        local rng
        if(sp:ToPlayer()) then
            rng = sp:ToPlayer():GetCollectibleRNG(ToyboxMod.COLLECTIBLE_GOOD_JUICE)
        else
            rng = sp:GetDropRNG()
        end

        local juice = Isaac.Spawn(EntityType.ENTITY_EFFECT,ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL,num,pos,Vector.Zero,sp):ToEffect()
        juice.Velocity = (pos-sp.Position):Resized(JUICE_PARTICLE_INITSPEED):Rotated(ToyboxMod:randomRange(rng, -1, 1)*JUICE_PARTICLE_INITARC)
        juice:GetSprite():Stop()

        if(sp:ToSlot()) then
            juice.Velocity = -juice.Velocity
        end
    end
end

---@param npc EntityNPC
local function giveJuiceOnKill(_, npc)
    local pl = PlayerManager.FirstCollectibleOwner(ToyboxMod.COLLECTIBLE_GOOD_JUICE)
    if(not pl) then return end

    local numParticles = (npc.MaxHitPoints/HP_FOR_JUICE)^FINAL_JUICE_EXPO
    spawnJuiceParticle(npc.Position, numParticles, pl)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, giveJuiceOnKill)

local function drainJuice(_)
    if(Game():GetFrameCount()%JUICE_DRAIN_FRAMES~=0) then return end

    addJuice(-1)
end
--ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, drainJuice)

---@param effect EntityEffect
local function juiceParticleInit(_, effect)
    effect.DepthOffset = 10000

    local sp = effect:GetSprite()

    local selFrame = 0
    for i, val in pairs(juiceFrameThresholds) do
        if(effect.SubType>i) then
            selFrame = val
        end
    end

    sp:Play("IdleOutline", true)
    sp:SetFrame(selFrame)

    if(effect.SpawnerEntity) then
        sp:Stop()
    else
        if(ToyboxMod.CONFIG.GOOD_JUICE_LESSLAG==1) then
            sp.PlaybackSpeed = ToyboxMod:randomRange(effect:GetDropRNG(), 0.5, 0.9)
        else
            sp.PlaybackSpeed = ToyboxMod:randomRange(effect:GetDropRNG(), 0.25, 0.8)
        end
        
    end

    sp.Color = Color(1,1,1,0)
    sp.Offset = Vector(0,-15)
    effect:SetShadowSize(2*(8-selFrame)/100)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, juiceParticleInit, ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL)

---@param effect EntityEffect
local function juiceParticleUpdate(_, effect)
    if(effect.SpawnerEntity) then
        local lerpVal = 0.05
        lerpVal = lerpVal+math.max(0, (effect.FrameCount-60)*0.025/60)

        effect.Velocity = ToyboxMod:lerp(effect.Velocity, (effect.SpawnerEntity.Position-effect.Position):Resized(JUICE_PARTICLE_SPEED), lerpVal)
        effect.SpriteRotation = effect.SpriteRotation+(effect.Velocity:LengthSquared()/20)

        if(effect.FrameCount%(ToyboxMod.CONFIG.GOOD_JUICE_LESSLAG==1 and 3 or 2)==0) then
            local rng = effect:GetDropRNG()
            for _=1, (ToyboxMod.CONFIG.GOOD_JUICE_LESSLAG==1 and 1 or 2) do
                local newSub = math.ceil(ToyboxMod:randomRange(rng, 0.2, 0.7)*effect.SubType)
                local vel = (-effect.Velocity):Resized(4):Rotated(rng:RandomInt(360))

                local newParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT,ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL,newSub,effect.Position,vel,nil):ToEffect()
                newParticle.SpriteRotation = effect.SpriteRotation
            end
        end

        if(effect.FrameCount>10 and effect.Position:DistanceSquared(effect.SpawnerEntity.Position)<(effect.SpawnerEntity.Size+8)^2) then
            local rng = effect:GetDropRNG()
            for _=1, (ToyboxMod.CONFIG.GOOD_JUICE_LESSLAG==1 and 2 or 4) do
                local newSub = math.ceil(ToyboxMod:randomRange(rng, 0.3, 0.8)*effect.SubType)
                local vel = (effect.Velocity):Resized(15):Rotated(rng:RandomInt(-25, 25))

                local newParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT,ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL,newSub,effect.Position,vel,nil):ToEffect()
                newParticle.SpriteRotation = effect.SpriteRotation
            end

            evaluateJuiceCollision(effect.Position-effect.Velocity*3, effect.SubType, effect.SpawnerEntity)

            sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0, false, 1)
            effect:Remove()
        end
    else
        effect.Velocity = effect.Velocity*0.9
        effect.SpriteRotation = effect.SpriteRotation+2
        effect:SetShadowSize(2*(8-effect:GetSprite():GetFrame())/100)

        if(effect:GetSprite():IsFinished()) then
            effect:Remove()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, juiceParticleUpdate, ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL)

---@param newLevel boolean
local function turnToJuiceOnRoomChange(_, _, newLevel)
    local data = ToyboxMod:getExtraDataTable()

    for _, ent in ipairs(Isaac.FindByType(1000, ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL)) do
        if(ent.SpawnerEntity) then
            evaluateJuiceCollision(ent.Position-ent.Velocity, ent.SubType, ent.SpawnerEntity)
        end
    end

    if(newLevel) then
        data.GOOD_JUICE_LERP_COUNTER = data.GOOD_JUICE_NUM
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, turnToJuiceOnRoomChange)

local cancelRenders = false
local function renderJuiceParticles(_)
    if(cancelRenders) then return end
    cancelRenders = true

    local effectsToRender = Isaac.FindByType(1000, ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL)

    local offset = Game():GetRoom():GetRenderScrollOffset()

    juiceSprite:Play("IdleOutline", true)
    for _, ent in ipairs(effectsToRender) do
        local sp = ent:GetSprite()
        local rpos = Isaac.WorldToRenderPosition(ent.Position)+ent.SpriteOffset+offset
        juiceSprite:SetFrame(sp:GetFrame())
        juiceSprite.Rotation = sp.Rotation+ent.SpriteRotation

        juiceSprite.Color = Color(1,1,1,1,1,1,1)
        juiceSprite:Render(rpos)
    end

    juiceSprite:Play("Idle", true)
    for _, ent in ipairs(effectsToRender) do
        local sp = ent:GetSprite()
        local rpos = Isaac.WorldToRenderPosition(ent.Position)+ent.SpriteOffset+offset
        juiceSprite:SetFrame(sp:GetFrame())
        juiceSprite.Rotation = sp.Rotation+ent.SpriteRotation

        juiceSprite.Color = Color(1,1,1,1,0,0,0,rpos.X/40+rpos.Y/40+Game():GetFrameCount()/15)
        juiceSprite:Render(rpos)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, renderJuiceParticles, ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL)

local function resetRenders(_)
    cancelRenders = false
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_RENDER, resetRenders)

local function spawnSlotInStartRoom()
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_GOOD_JUICE)) then return end

    local level = Game():GetLevel()
    if(level:GetCurrentRoomIndex()~=level:GetStartingRoomIndex()) then return end

    if(#Isaac.FindByType(EntityType.ENTITY_SLOT,ToyboxMod.SLOT_VARIANT.JUICE_FOUNTAIN)==0) then
        local pos = Vector(180,200)

        local slot = Isaac.Spawn(EntityType.ENTITY_SLOT,ToyboxMod.SLOT_VARIANT.JUICE_FOUNTAIN,0,pos,Vector.Zero,nil)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, spawnSlotInStartRoom)

---@param slot EntitySlot
local function postSlotInit(_, slot)
    slot:SetSize(slot.Size, Vector(2,1)*slot.SizeMulti, 24)

    local sp = slot:GetSprite()
    sp:GetLayer("juice"):SetCustomShader("spriteshaders/rainbowshader")
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, postSlotInit, ToyboxMod.SLOT_VARIANT.JUICE_FOUNTAIN)

---@param slot EntitySlot
local function postSlotUpdate(_, slot)
    if(slot:GetTouch()%4==1) then
        local pl = PlayerManager.FirstCollectibleOwner(ToyboxMod.COLLECTIBLE_GOOD_JUICE) or Isaac.GetPlayer()
        if(pl) then
            local neededJuice = JUICE_REQ_BASE+JUICE_REQ_PER_FLOOR*Game():GetLevel():GetAbsoluteStage()

            if((ToyboxMod:getExtraData("GOOD_JUICE_NUM") or 0)>=neededJuice) then
                addJuice(-neededJuice)
                spawnJuiceParticle(pl.Position, neededJuice*0.5, slot)
            end
        end
    end

    slot:SetState(1)
    slot:GetSprite():GetLayer("juice"):SetColor(Color(1,1,1,1,0,0,0,slot.Position.X/40+slot.Position.Y/40+Game():GetFrameCount()/90))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, postSlotUpdate, ToyboxMod.SLOT_VARIANT.JUICE_FOUNTAIN)

---@param slot EntitySlot
local function slotExplosionDrops(_, slot)
    return false
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, slotExplosionDrops, ToyboxMod.SLOT_VARIANT.JUICE_FOUNTAIN)

---@param pl EntityPlayer
---@param flags CacheFlag
local function evalJuiceStats(_, pl, flags)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_GOOD_JUICE)) then return end

    local data = ToyboxMod:getEntityData(pl, "GOOD_JUICE_STATS") or {}
    if(flags==CacheFlag.CACHE_SPEED) then
        pl.MoveSpeed = pl.MoveSpeed+(data.SPEED or 0)
    elseif(flags==CacheFlag.CACHE_FIREDELAY) then
        ToyboxMod:addBasicTearsUp(pl, (data.TEARS or 0))
    elseif(flags==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(pl, (data.DAMAGE or 0))
    elseif(flags==CacheFlag.CACHE_RANGE) then
        pl.TearRange = pl.TearRange+(data.RANGE or 0)*40
    elseif(flags==CacheFlag.CACHE_SHOTSPEED) then
        pl.ShotSpeed = pl.ShotSpeed+(data.SHOTSPEED or 0)
    elseif(flags==CacheFlag.CACHE_LUCK) then
        pl.Luck = pl.Luck+(data.LUCK or 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalJuiceStats)


local MAP_HELD = 0
local MAP_MAX = 15
local CURRENT_TRANSPARENCY = 0

local SQRT3 = math.sqrt(3)

---@param hue number
---@return KColor
local function kcolorFromHue(hue)
    local hcos = math.cos(math.rad(hue))
    local hsin = math.sin(math.rad(hue))

    return KColor(hcos*2/3+1/3, 1/3+hsin*SQRT3-hcos*1/3, 1/3-hsin*SQRT3-hcos*1/3, 1)
end
---@param a KColor
---@param b KColor
---@param f number
local function lerpKcolor(a, b, f)
    return KColor(ToyboxMod:lerp(a.Red,b.Red,f),ToyboxMod:lerp(a.Blue,b.Blue,f),ToyboxMod:lerp(a.Green,b.Green,f),ToyboxMod:lerp(a.Alpha,b.Alpha,f))
end

local function hudRender(_)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_GOOD_JUICE)) then return end

    local data = ToyboxMod:getExtraDataTable()
    if(not Game():IsPaused()) then
        local trueVal = (data.GOOD_JUICE_NUM or 0)

        data.GOOD_JUICE_LERP_COUNTER = data.GOOD_JUICE_LERP_COUNTER or trueVal
        local fakeVal = data.GOOD_JUICE_LERP_COUNTER or trueVal

        local dif = trueVal-fakeVal
        local adif = math.abs(dif)
        if(not Game():IsPaused() and adif>0) then
            local toAdd = 0
            if(adif>25000) then toAdd = 271
            elseif(adif>3000) then toAdd = 27
            elseif(adif>250) then toAdd = 7
            else
                toAdd = adif*0.03
                if(adif<0.2) then
                    toAdd = adif
                end
            end

            data.GOOD_JUICE_LERP_COUNTER = fakeVal+toAdd*dif/adif
        end
    end

    --figure ts out later
    if(not Game():IsPaused()) then
        if(Input.IsActionPressed(ButtonAction.ACTION_MAP, Isaac.GetPlayer().ControllerIndex)) then
            if(MAP_HELD<MAP_MAX) then
                MAP_HELD = MAP_HELD+1
            end
        elseif(MAP_HELD>0) then
            MAP_HELD = math.max(0, math.floor(MAP_HELD*0.85))
        end

        CURRENT_TRANSPARENCY = ToyboxMod:lerp(CURRENT_TRANSPARENCY, MAP_HELD/MAP_MAX, 0.25)
    end

    local trueTransparency = CURRENT_TRANSPARENCY
    if(Options.ExtraHUDStyle == 1) then
        trueTransparency = math.max(trueTransparency, 0.5)
    end

    if(trueTransparency<0.01) then return end
    local color = lerpKcolor(KColor(1,1,1,1), kcolorFromHue((Game():GetFrameCount()*5)%360), 0.33)
    color.Alpha = trueTransparency

    local renderPos = Vector(Isaac.GetScreenWidth()/2, 6)+Vector(0,24)*Options.HUDOffset+Vector(0,32)

    font:DrawString("Juice:", renderPos.X-40, renderPos.Y, color)
    font:DrawString(tostring(math.floor(data.GOOD_JUICE_LERP_COUNTER or 0)), renderPos.X, renderPos.Y, color, 40, false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_HUD_RENDER, hudRender)