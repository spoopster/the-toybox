
local sfx = SFXManager()

local EFFECT_DURATION = 30*30

local HURT_DURATION = 1*30
local HURT_DURATION_HORSE = 0.5*30

local BURN_COLOR1 = Color(1,1,0.6,1,0.35,0,0)
local BURN_COLOR2 = Color(1,1,1,1,0.2,0.2,0)
local BURN_COLOR_CYCLE_FRAMES = 2

local BURN_HURT_COLOR = Color.ProjectileFireWave

local BURN_SPRITE = Sprite("gfx_tb/statuseffects.anm2", true)
BURN_SPRITE:Play("Burning", true)

local UPDATE_BURN_FRAME = 0

---@param player EntityPlayer
local function usePill(_, effect, player, flags, color)
    local isHorse = (color & PillColor.PILL_GIANT_FLAG ~= 0)

    ToyboxMod:setEntityData(player, "HEARTBURN_DURATION", EFFECT_DURATION)
    ToyboxMod:setEntityData(player, "HEARTBURN_HURT_DURATION", (isHorse and HURT_DURATION_HORSE or HURT_DURATION))
    ToyboxMod:setEntityData(player, "HEARTBURN_HURT_FRAMES", 0)

    --[[
    ToyboxMod:setEntityData(player, "HEARTBURN_MODE", (isHorse and 2 or 1))
    --]]

    sfx:Play((isHorse and SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED or SoundEffect.SOUND_THUMBS_DOWN))
    player:AnimateSad()
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_PILL, usePill, ToyboxMod.PILL_EFFECT.HEARTBURN)

---@param player EntityPlayer
local function playerHeartburnEffectUpdate(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(not (data.HEARTBURN_DURATION and data.HEARTBURN_DURATION>0)) then return end

    data.HEARTBURN_HURT_FRAMES = (data.HEARTBURN_HURT_FRAMES or 0)
    data.HEARTBURN_HURT_DURATION = (data.HEARTBURN_HURT_DURATION or HURT_DURATION)

    if(player:IsExtraAnimationFinished() and player:GetMovementVector():LengthSquared()<0.1) then
        data.HEARTBURN_HURT_FRAMES = data.HEARTBURN_HURT_FRAMES+1

        if(data.HEARTBURN_HURT_FRAMES>=data.HEARTBURN_HURT_DURATION) then
            data.HEARTBURN_HURT_FRAMES = 0

            player:ResetDamageCooldown()
            player:TakeDamage(1, DamageFlag.DAMAGE_POISON_BURN | DamageFlag.DAMAGE_INVINCIBLE, EntityRef(nil), 0)
            sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS)
        end
    elseif(data.HEARTBURN_HURT_FRAMES>0) then
        data.HEARTBURN_HURT_FRAMES = math.max(0, data.HEARTBURN_HURT_FRAMES-2)
    end

    local modFrame = data.HEARTBURN_DURATION%(BURN_COLOR_CYCLE_FRAMES*3)
    local baseColor = Color.Default
    if(modFrame<BURN_COLOR_CYCLE_FRAMES) then
        baseColor = Color.Lerp(Color.Default, BURN_COLOR1, (modFrame)/BURN_COLOR_CYCLE_FRAMES)
    elseif(modFrame<BURN_COLOR_CYCLE_FRAMES*2) then
        baseColor = Color.Lerp(BURN_COLOR1, BURN_COLOR2, (modFrame-BURN_COLOR_CYCLE_FRAMES)/BURN_COLOR_CYCLE_FRAMES)
    else
        baseColor = Color.Lerp(BURN_COLOR2, Color.Default, (modFrame-BURN_COLOR_CYCLE_FRAMES*2)/BURN_COLOR_CYCLE_FRAMES)
    end

    player:SetColor(Color.Lerp(baseColor, BURN_HURT_COLOR, (data.HEARTBURN_HURT_FRAMES/data.HEARTBURN_HURT_DURATION)), 1, 1, false, false)

    data.HEARTBURN_DURATION = (data.HEARTBURN_DURATION or 1)-1
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, playerHeartburnEffectUpdate)

---@param player EntityPlayer
local function renderFireEffect(_, player, offset)
    local data = ToyboxMod:getEntityDataTable(player)
    if(player:IsDead()) then return end
    if(not (data.HEARTBURN_DURATION and data.HEARTBURN_DURATION>0)) then return end

    local renderPos = Isaac.WorldToRenderPosition(player.Position)-Vector(0,25)+offset
    BURN_SPRITE:Render(renderPos)

    if(not Game():IsPaused()) then
        UPDATE_BURN_FRAME = (UPDATE_BURN_FRAME+1)%3
        if(UPDATE_BURN_FRAME==0) then
            BURN_SPRITE:Update()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderFireEffect)

--[[] ]

---@param player EntityPlayer
local function sillySillyGoofyGoofy(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(not (data.HEARTBURN_DURATION and data.HEARTBURN_DURATION>0)) then return end

    for _, tear in ipairs(Isaac.FindInRadius(player.Position,player.Size,EntityPartition.TEAR)) do
        if(GetPtrHash(tear.SpawnerEntity)~=GetPtrHash(player)) then
            sfx:Play(SoundEffect.SOUND_STEAM_HALFSEC)
            data.HEARTBURN_DURATION = 0

            tear:Remove()

            break
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, sillySillyGoofyGoofy)

--]]