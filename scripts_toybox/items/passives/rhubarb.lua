local sfx = SFXManager()

local DMG_MULT = 0.75

local HP_PERCENT_DMG = 0.15
local BOSS_PERCENT_DMG = 0.015


---@param pl EntityPlayer
---@param val number
local function evalStat(_, pl, _, val)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_RHUBARB)) then return end

    local mult = DMG_MULT^(pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_RHUBARB))
    return val*mult
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evalStat, EvaluateStatStage.FLAT_DAMAGE)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
local function entityTakeDmg(_, ent, amount, flags, source, countdown)
    local sourceEnt = source.Entity
    if(not sourceEnt) then return end

    local pl = sourceEnt:ToPlayer()
    if(not pl) then
        pl = sourceEnt.Parent and sourceEnt.Parent:ToPlayer()
    end
    if(not pl) then
        pl = sourceEnt.SpawnerEntity and sourceEnt.SpawnerEntity:ToPlayer()
    end

    if(pl and pl:HasCollectible(ToyboxMod.COLLECTIBLE_RHUBARB)) then
        local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_RHUBARB)
        local newDmg = amount + mult * ent.MaxHitPoints * (ent:IsBoss() and BOSS_PERCENT_DMG or HP_PERCENT_DMG)
        ToyboxMod:setEntityData(ent, "SHOULD_FLASH_PURPLE", true)
        return {
            Damage = newDmg,
            DamageFlags = flags,
            DamageCountdown = countdown,
        }
    else
        ToyboxMod:setEntityData(ent, "SHOULD_FLASH_PURPLE", nil)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDmg)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
local function postEntityTakeDmg(_, ent, amount, flags, source, countdown)
    if(ToyboxMod:getEntityData(ent, "SHOULD_FLASH_PURPLE")) then
        local ogColor = Color.Lerp(ent.Color, ent.Color, 0)
        local ogSplatColor = Color.Lerp(ent.SplatColor, ent.SplatColor, 0)

        ent.Color = Color(0.7,0.35,1,1)
        ent.SplatColor = Color(0.86,0.7,1,0.2,0.1,0,0.3)

        local isAlive = not (ent:HasMortalDamage() or ent:IsDead())

        local hadGibsFlag = true
        if(isAlive) then
            hadGibsFlag = ent:HasEntityFlags(EntityFlag.FLAG_REDUCE_GIBS)
            ent:AddEntityFlags(EntityFlag.FLAG_REDUCE_GIBS)
        end

        --[[] ]
        local stopSmall = not sfx:IsPlaying(SoundEffect.SOUND_DEATH_BURST_SMALL)
        local stopLarge = not sfx:IsPlaying(SoundEffect.SOUND_DEATH_BURST_LARGE)
        local stopBone = not sfx:IsPlaying(SoundEffect.SOUND_DEATH_BURST_BONE)
        --]]

        ent:BloodExplode()
        if(isAlive) then
            if(true or stopSmall) then sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL) end
            if(true or stopLarge) then sfx:Stop(SoundEffect.SOUND_DEATH_BURST_LARGE) end
            if(true or stopBone) then sfx:Stop(SoundEffect.SOUND_DEATH_BURST_BONE) end
        end

        sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, nil, nil, nil, 0.95+math.random()*0.1)
        sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 0.4, nil, nil, 0.95+math.random()*0.1)

        local scale = 0.2*(ent.Size^(0.9-ToyboxMod:clamp(0, (ent.Size-50)/50, 0.25)))/10
        local poof = Isaac.Spawn(1000,16,5,ent.Position,Vector.Zero,nil):ToEffect()
        poof.SpriteScale = Vector(1,1)*scale
        poof.SpriteOffset = Vector(0,-5*scale*10)+Vector(ent.Size*0.5, ent.Size*0.5)*RandomVector()*math.random()
        poof.Rotation = math.random(1,360)
        poof.Color = Color(0,0,0,0.4,200/255,70/255,230/255,1/scale)
        poof:GetSprite().PlaybackSpeed = 1.65+math.random()*0.2
        poof:GetSprite():SetCustomShader("shaders_tb/pixelate")

        if(not hadGibsFlag) then
            ent:ClearEntityFlags(EntityFlag.FLAG_REDUCE_GIBS)
        end
        ent.Color = ogColor
        if(isAlive) then
            ent.SplatColor = ogSplatColor
        end

        ToyboxMod:setEntityData(ent, "SHOULD_FLASH_PURPLE", nil)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, postEntityTakeDmg)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_RHUBARB)) then return end

    player.TearColor = player.TearColor*Color(1.12, 1, 1.3, 1, 0, 0, 0, 0.95, 0.34, 1.2, 0.5)
    player.LaserColor = player.LaserColor*Color(1.12, 0.93, 1.33, 1, 0.05, 0, 0.05, 1.02, 0.34, 1.19, 0.34)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_TEARCOLOR)

-- for the cosutme
---@param pl EntityPlayer
local function evalColorCache(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_RHUBARB)) then return end

    pl.Color = pl.Color*Color(2, 1.15, 1.35, 1)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalColorCache, CacheFlag.CACHE_COLOR)