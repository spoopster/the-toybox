local sfx = SFXManager()

local BREATH_CHANCE = 0.1
local BREATH_MAXCHANCE = 0.2
local BREATH_MAXLUCK = 20

local FLAGS_TO_ADD = {
    TearFlags.TEAR_RAINBOW,
    TearFlags.TEAR_BAIT,
    TearFlags.TEAR_BURN,
    TearFlags.TEAR_CHARM,
    TearFlags.TEAR_FEAR,
    TearFlags.TEAR_SLOW,
    TearFlags.TEAR_ICE,
    TearFlags.TEAR_FREEZE,
    TearFlags.TEAR_POISON,
    TearFlags.TEAR_HOMING,
    TearFlags.TEAR_SHRINK
}
local DMG_MULT = 3


---@param pl EntityPlayer
---@param params TearParams
local function evalParams(_, pl, params, weap, dmg, tearDisp, source)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_AIDS)) then return end

    local c = ToyboxMod:getLuckAffectedChance(pl.Luck, BREATH_CHANCE, BREATH_MAXLUCK, BREATH_MAXCHANCE)
    if(math.random()<c) then
        local totalFlag = 0
        for _, flag in ipairs(FLAGS_TO_ADD) do
            totalFlag = totalFlag | flag
        end
        params.TearFlags = params.TearFlags | totalFlag
        params.TearDamage = params.TearDamage*DMG_MULT
        params.TearColor = Color.Default
        params.TearScale = params.TearScale*1.1
        params.TearVariant = ToyboxMod.TEAR_AIDS
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, evalParams)

---@param tear EntityTear
local function aidsTearInit(_, tear)
    ToyboxMod:playTearScaleAnim(tear, true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, aidsTearInit, ToyboxMod.TEAR_AIDS)

---@param tear EntityTear
local function aidsTearUpdate(_, tear)
    ToyboxMod:playTearScaleAnim(tear, false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, aidsTearUpdate, ToyboxMod.TEAR_AIDS)

---@param tear EntityTear
local function aidsTearDeath(_, tear)
    sfx:Play(SoundEffect.SOUND_SPLATTER, 1, 0, false, 1.0)

	if(tear.TearFlags & TearFlags.TEAR_EXPLOSIVE == TearFlags.TEAR_EXPLOSIVE) then return end

    local poof = Isaac.Spawn(1000, ToyboxMod:getTearPoofVariantFromTear(tear), 0, tear.Position, Vector.Zero, tear):ToEffect()
    poof:GetSprite().Color = tear:GetSprite().Color
    if(tear.Scale > 0.8) then
        poof.SpriteScale = Vector(1, 1)*(tear.Scale*0.8)
    end
    poof.PositionOffset = tear.PositionOffset
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, aidsTearDeath, ToyboxMod.TEAR_AIDS)