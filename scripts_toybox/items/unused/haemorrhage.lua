
local sfx = SFXManager()

local FREQ_CHECK_DEFAULT = 90
local FREQ_CHECK_INTENSE = 10
local CHECK_CHANCE = 0.2

local HURT_INTENSITY_INCREASE_DURATION = 60
local BONEHEART_ADD = 1


local TEARS_FIRED_MIN = 12
local TEARS_FIRED_MAX = 20
local DMG_MULT = 1

---@param pl EntityPlayer
function ToyboxMod:doHemorrhageEffect(pl)
    local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_HEMORRHAGE)
    local tearsNum = rng:RandomInt(TEARS_FIRED_MIN, TEARS_FIRED_MAX)

    for _=1, tearsNum do
        local dir = pl:GetShootingInput():Rotated(rng:RandomInt(-15,15))
        dir = dir*pl.ShotSpeed*10+pl:GetTearMovementInheritance(dir)

        dir = dir*(0.5+rng:RandomFloat()*0.5)

        local tear = pl:FireTear(pl.Position, dir, true, false, false, pl, DMG_MULT)
        tear.FallingAcceleration = tear.FallingAcceleration+1+rng:RandomFloat()*0.4
        tear.FallingSpeed = tear.FallingSpeed-10-rng:RandomInt(0,5)
    end

    local eff = Isaac.Spawn(1000,16,5,pl.Position,Vector.Zero,pl):ToEffect()
    sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
end

---@param player EntityPlayer
local function addHaemorrhage(_, item, _, firstTime, _, _, player)
    if(firstTime~=true) then return end

    player:AddBoneHearts(BONEHEART_ADD)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addHaemorrhage, ToyboxMod.COLLECTIBLE_HEMORRHAGE)

---@param pl EntityPlayer
local function hemorrhageEffectCheck(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_HEMORRHAGE)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.HAEMORRHAGE_COUNTDOWN = (data.HAEMORRHAGE_COUNTDOWN or 0)

    local freq = FREQ_CHECK_DEFAULT
    if(data.HAEMORRHAGE_COUNTDOWN>0) then
        freq = FREQ_CHECK_INTENSE
        
        data.HAEMORRHAGE_COUNTDOWN = data.HAEMORRHAGE_COUNTDOWN-1
    end

    if(pl:GetFireDirection()==Direction.NO_DIRECTION and pl:GetShootingInput():Length()<0.01) then
        data.HEMORRHAGE_TEARS_HELD = 0
        return
    end

    data.HEMORRHAGE_TEARS_HELD = (data.HEMORRHAGE_TEARS_HELD or 0)+1
    if(data.HEMORRHAGE_TEARS_HELD>=freq) then
        --print("Yeah")

        data.HEMORRHAGE_TEARS_HELD = 0
        local rng = pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_HEMORRHAGE)

        if(rng:RandomFloat()<CHECK_CHANCE*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_HEMORRHAGE)) then
            ToyboxMod:doHemorrhageEffect(pl)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, hemorrhageEffectCheck)

---@param player Entity
local function increaseIntensity(_, player, _, flags, source)
    ToyboxMod:setEntityData(player:ToPlayer(), "HAEMORRHAGE_COUNTDOWN", HURT_INTENSITY_INCREASE_DURATION)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, increaseIntensity, EntityType.ENTITY_PLAYER)