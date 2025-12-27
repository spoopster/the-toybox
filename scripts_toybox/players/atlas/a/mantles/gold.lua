
local sfx = SFXManager()

--! add the funny sparkles (both transf and mantle)

local LUCK_UP = 1
local MIDASFREEZE_DURATION = 150
local MANTLEFREEZE_DISTANCE = 100

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not ToyboxMod:isAtlasA(player)) then return end

    local numMantles = ToyboxMod:getNumMantlesByType(player, ToyboxMod.MANTLE_DATA.GOLD.ID)

    if(flag==CacheFlag.CACHE_LUCK) then
        player.Luck = player.Luck+LUCK_UP*numMantles
    end
    if(ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.GOLD.ID)) then
        if(flag==CacheFlag.CACHE_TEARFLAG) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_GREED_COIN
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function mantleDestroyed(_, player, mantle)
    if(not ToyboxMod:isAtlasA(player)) then return end
    if(not (ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.GOLD.ID) or mantle==ToyboxMod.MANTLE_DATA.GOLD.ID)) then return end

    for _, ent in ipairs(Isaac.FindInRadius(player.Position, MANTLEFREEZE_DISTANCE, EntityPartition.ENEMY)) do
        if(ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
            ent:AddMidasFreeze(EntityRef(player), MIDASFREEZE_DURATION)
        end
    end

    local shatter = Isaac.Spawn(1000, ToyboxMod.EFFECT_GOLDMANTLE_BREAK, 0, player.Position, Vector.Zero, player):ToEffect()
    shatter.DepthOffset = 100
    shatter:GetSprite().PlaybackSpeed = 1.4
    shatter.SpriteOffset = Vector(0,-10)

    local crater = Isaac.Spawn(1000,EffectVariant.BOMB_CRATER,0,player.Position,Vector.Zero,player):ToEffect()
    crater.Color = Color(1,1,1,1,0.87,0.87)

    for i=1, 20 do
        local gibs = Isaac.Spawn(1000, 95, 0, player.Position, Vector.Zero, player):ToEffect()
        gibs.Velocity = Vector(gibs:GetDropRNG():RandomFloat()*12, 0):Rotated(gibs:GetDropRNG():RandomFloat()*360)
    end

    sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK)
    sfx:Play(ToyboxMod.SFX_ATLASA_METALBREAK, 1.4)
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, mantleDestroyed)

---@param effect EntityEffect
local function updateGoldMantleShatter(_, effect)
    if(effect.FrameCount==0) then effect:GetSprite():Play("Idle", true) end
    if(effect:GetSprite():IsFinished("Idle")) then effect:Remove() end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, updateGoldMantleShatter, ToyboxMod.EFFECT_GOLDMANTLE_BREAK)