local mod = MilcomMOD
local sfx = SFXManager()

--#region --! METEOR TEARS
---@param tear EntityTear
local function meteorTearUpdate(_, tear)
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
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, meteorTearUpdate, mod.TEAR_METEOR)

local function meteorTearSplat(_, tear)
    if(Game():IsPaused()) then return end

    if(tear.Variant==mod.TEAR_METEOR) then
        tear = tear:ToTear()

        sfx:Play(SoundEffect.SOUND_STONE_IMPACT, 0.4, 0, false, 1)
        for _=1, 2 do
            local particle = Isaac.Spawn(1000, EffectVariant.ROCK_PARTICLE, 0, tear.Position, Vector.FromAngle(math.random(360)), nil)
            particle:Update()

            particle.Color = Color(0.8,0.7,0.7)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, meteorTearSplat, EntityType.ENTITY_TEAR)
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
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, bulletTearUpdate, mod.TEAR_BULLET)

local function bulletTearSplat(_, tear)
    if(Game():IsPaused()) then return end

    if(tear.Variant==mod.TEAR_BULLET) then
        tear = tear:ToTear()

        sfx:Play(SoundEffect.SOUND_PLOP, 0.1, 0, false, 1)
        sfx:Play(mod.SFX_BULLET_HIT, 0.5, 0, false, 1)
        for _=1, math.floor(2*tear.Scale) do
            local particle = Isaac.Spawn(1000, EffectVariant.TOOTH_PARTICLE, 1, tear.Position, Vector.FromAngle(math.random(360)), nil)
            particle:Update()

            local c = Color(0.5,0.5,0.5,1)
            c:SetColorize(0.25,0.6,0.2,1)
            particle.Color = c
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, bulletTearSplat, EntityType.ENTITY_TEAR)
--#endregion