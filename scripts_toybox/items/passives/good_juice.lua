local sfx = SFXManager()
local font = Font()
font:Load("font/teammeatfont10.fnt")

local HP_FOR_JUICE = 1
local FINAL_JUICE_EXPO = 1

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

local toRender = {}

---@param pos Vector
---@param num number
---@param pl EntityPlayer
local function spawnJuiceParticle(pos, num, pl)
    num = math.ceil(num or 1)

    local extraData = ToyboxMod:getExtraDataTable()

    local rng = pl:GetDropRNG()

    local juice = Isaac.Spawn(EntityType.ENTITY_EFFECT,ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL,num,pos,Vector.Zero,pl):ToEffect()
    juice.Velocity = (pos-pl.Position):Resized(JUICE_PARTICLE_INITSPEED):Rotated(ToyboxMod:randomRange(rng, -1, 1)*JUICE_PARTICLE_INITARC)
    juice:GetSprite():Stop()
end

---@param npc EntityNPC
local function spawnDeathPuddle(_, npc)
    local pl = Isaac.GetPlayer()
    if(not pl) then return end

    local numParticles = (npc.MaxHitPoints/HP_FOR_JUICE)^FINAL_JUICE_EXPO
    spawnJuiceParticle(npc.Position, numParticles, pl)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, spawnDeathPuddle)

---@param effect EntityEffect
local function juiceParticleInit(_, effect)
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
        sp.PlaybackSpeed = ToyboxMod:randomRange(effect:GetDropRNG(), 0.25, 0.8)
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

        if(effect.FrameCount%2==0) then
            local rng = effect:GetDropRNG()
            for _=1, 2 do
                local newSub = math.ceil(ToyboxMod:randomRange(rng, 0.2, 0.7)*effect.SubType)
                local vel = (-effect.Velocity):Resized(4):Rotated(rng:RandomInt(360))

                local newParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT,ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL,newSub,effect.Position,vel,nil):ToEffect()
                newParticle.SpriteRotation = effect.SpriteRotation
            end
        end

        if(effect.Position:DistanceSquared(effect.SpawnerEntity.Position)<(effect.SpawnerEntity.Size+10)^2) then
            local rng = effect:GetDropRNG()
            for _=1, 3 do
                local newSub = math.ceil(ToyboxMod:randomRange(rng, 0.3, 0.8)*effect.SubType)
                local vel = (effect.Velocity):Resized(15):Rotated(rng:RandomInt(-25, 25))

                local newParticle = Isaac.Spawn(EntityType.ENTITY_EFFECT,ToyboxMod.EFFECT_VARIANT.JUICE_TRAIL,newSub,effect.Position,vel,nil):ToEffect()
                newParticle.SpriteRotation = effect.SpriteRotation
            end

            local data = ToyboxMod:getExtraDataTable()
            data.GOOD_JUICE_NUM = (data.GOOD_JUICE_NUM or 0)+effect.SubType

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
            data.GOOD_JUICE_NUM = (data.GOOD_JUICE_NUM or 0)+ent.SubType
        end
    end

    if(newLevel) then
        data.GOOD_JUICE_LERP_COUNTER = data.GOOD_JUICE_NUM
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, turnToJuiceOnRoomChange)

local cancelRenders = false

---@param effect EntityEffect
local function renderJuiceParticles(_, effect)
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

---@param pl EntityPlayer
---@param offset Vector
local function renderCombo(_, pl, offset)

end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderCombo, PlayerVariant.PLAYER)


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
    local pl = Isaac.GetPlayer()

    --figure ts out later
    if(not Game():IsPaused()) then
        if(Input.IsActionPressed(ButtonAction.ACTION_MAP, pl.ControllerIndex)) then
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

    local data = ToyboxMod:getExtraDataTable()
    local trueVal = (data.GOOD_JUICE_NUM or 0)
    local fakeVal = data.GOOD_JUICE_LERP_COUNTER or trueVal
    local toAdd = 0
    

    local dif = trueVal-fakeVal
    if(dif>0) then
        if(dif>3000) then toAdd = 25
        elseif(dif>250) then toAdd = 7
        else
            toAdd = dif*0.03
        end
    end

    data.GOOD_JUICE_LERP_COUNTER = fakeVal+toAdd

    local renderPos = Vector(Isaac.GetScreenWidth()/2, 6)+Vector(0,24)*Options.HUDOffset+Vector(0,32)

    font:DrawString("Juice:", renderPos.X-40, renderPos.Y, color)
    font:DrawString(tostring(math.ceil(data.GOOD_JUICE_LERP_COUNTER)), renderPos.X, renderPos.Y, color, 40, false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_HUD_RENDER, hudRender)