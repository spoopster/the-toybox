
local sfx = SFXManager()

--#region --! METEOR TEARS
---@param tear EntityTear
local function meteorTearUpdate(_, tear)
    tear:ResetSpriteScale(false)

    local s = tear:GetSprite()
    --if(s:GetAnimation()~=anim) then s:Play(anim, true) end

    tear.Rotation = tear.Velocity:GetAngleDegrees()%360
    s.Rotation = tear.Rotation
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, meteorTearUpdate, ToyboxMod.TEAR_METEOR)

local function meteorTearSplat(_, tear)
    if(Game():IsPaused()) then return end

    if(tear.Variant==ToyboxMod.TEAR_METEOR) then
        tear = tear:ToTear()

        sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, 1)
        for _=1, 2 do
            local particle = Isaac.Spawn(1000, EffectVariant.ROCK_PARTICLE, 0, tear.Position, Vector.FromAngle(math.random(360)), nil)
            particle:Update()

            particle.Color = Color(0.8,0.7,0.7)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, meteorTearSplat, EntityType.ENTITY_TEAR)
--#endregion

--#region --! BULLETS TEARS
---@param tear EntityTear
local function bulletTearUpdate(_, tear)
    local scale = tear.Scale
    local anim = "RegularTear13"
	if scale <= 0.3 then anim = "RegularTear1"
	elseif scale <= 0.55 then anim = "RegularTear2"
	elseif scale <= 0.675 then anim = "RegularTear3"
	elseif scale <= 0.8 then anim = "RegularTear4"
	elseif scale <= 0.925 then anim = "RegularTear5"
	elseif scale <= 1.05 then anim = "RegularTear6"
	elseif scale <= 1.175 then anim = "RegularTear7"
	elseif scale <= 1.425 then anim = "RegularTear8"
	elseif scale <= 1.675 then anim = "RegularTear9"
	elseif scale <= 1.925 then anim = "RegularTear10"
	elseif scale <= 2.175 then anim = "RegularTear11"
	elseif scale <= 2.55 then anim = "RegularTear12" end

    local s = tear:GetSprite()
    if(s:GetAnimation()~=anim) then s:Play(anim, true) end

    tear.Rotation = tear.Velocity:GetAngleDegrees()%360
    s.Rotation = tear.Rotation
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, bulletTearUpdate, ToyboxMod.TEAR_BULLET)

local function bulletTearSplat(_, tear)
    if(Game():IsPaused()) then return end

    if(tear.Variant==ToyboxMod.TEAR_BULLET) then
        tear = tear:ToTear()

        sfx:Play(SoundEffect.SOUND_PLOP, 0.1, 0, false, 1)
        sfx:Play(ToyboxMod.SFX_BULLET_HIT, 0.5, 0, false, 1)
        for _=1, math.floor(2*tear.Scale) do
            local particle = Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 1, tear.Position, Vector.FromAngle(math.random(360)), nil)
            particle:Update()

            local c = Color(0.5,0.5,0.5,1)
            c:SetColorize(0.25,0.6,0.2,1)
            particle.Color = c
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, bulletTearSplat, EntityType.ENTITY_TEAR)
--#endregion

--#region --! SOUNDWAVE TEAR
local SOUNDWAVE_TEAR_LIFESPAN = 330
local SOUNDWAVE_TEAR_FADEOUT = 30

---@param tear EntityTear
local function soundwaveTearUpdate(_, tear)
    local s = tear:GetSprite()

--tear:ResetSpriteScale(true)
    --if(s:GetAnimation()~="RegularTear6") then s:Play("RegularTear6", true) end

    tear.Rotation = ToyboxMod:getEntityData(tear, "EVIL_WAVE_ROTATION") or tear.Velocity:GetAngleDegrees()%360
    s.Rotation = tear.Rotation

    if(tear.FrameCount>=SOUNDWAVE_TEAR_LIFESPAN-SOUNDWAVE_TEAR_FADEOUT) then
        local a = (SOUNDWAVE_TEAR_LIFESPAN-tear.FrameCount)/SOUNDWAVE_TEAR_FADEOUT
        tear.Color = Color(tear.Color.R, tear.Color.G, tear.Color.B, a, tear.Color.RO, tear.Color.GO, tear.Color.BO)

        if(tear.FrameCount==SOUNDWAVE_TEAR_LIFESPAN) then tear:Remove() end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, soundwaveTearUpdate, ToyboxMod.TEAR_SOUNDWAVE)

---@param tear EntityTear
local function soundwaveTearRender(_, tear, offset)
    local s = tear:GetSprite()
    local rng = tear:GetDropRNG()

    for i=1,1 do
        s:Render(Isaac.WorldToScreen(tear.Position+Vector(rng:RandomFloat()-0.5,rng:RandomFloat()-0.5)*13+offset+Vector(0,tear.Height)-Game():GetRoom():GetRenderScrollOffset()))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, soundwaveTearRender, ToyboxMod.TEAR_SOUNDWAVE)
--#endregion

--#region --! CASH 1 BILLION PAPER
---@param tear EntityTear
local function paperTearUpdate(_, tear)
    local scale = tear.Scale
    local anim = "RegularTear13"
	if scale <= 0.3 then anim = "RegularTear1"
	elseif scale <= 0.55 then anim = "RegularTear2"
	elseif scale <= 0.675 then anim = "RegularTear3"
	elseif scale <= 0.8 then anim = "RegularTear4"
	elseif scale <= 0.925 then anim = "RegularTear5"
	elseif scale <= 1.05 then anim = "RegularTear6"
	elseif scale <= 1.175 then anim = "RegularTear7"
	elseif scale <= 1.425 then anim = "RegularTear8"
	elseif scale <= 1.675 then anim = "RegularTear9"
	elseif scale <= 1.925 then anim = "RegularTear10"
	elseif scale <= 2.175 then anim = "RegularTear11"
	elseif scale <= 2.55 then anim = "RegularTear12" end

    if(tear:GetSprite():GetAnimation()~=anim) then tear:GetSprite():Play(anim, true) end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, paperTearUpdate, ToyboxMod.TEAR_PAPER)

local function paperTearSplat(_, tear)
    if(Game():IsPaused()) then return end

    if(tear.Variant==ToyboxMod.TEAR_PAPER) then
        tear = tear:ToTear()

        for _=1, math.floor(2*tear.Scale) do
            local particle = Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 1, tear.Position, Vector.FromAngle(math.random(360)), nil)
            particle:Update()

            --local c = Color(0.5,0.5,0.5,1)
            --c:SetColorize(0.25,0.6,0.2,1)
            --particle.Color = c
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, paperTearSplat, EntityType.ENTITY_TEAR)
--#endregion