local mod = MilcomMOD
local sfx = SFXManager()

--* needs some polish

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_DARK] = true
end

local function useMantle(_, _, player, _)
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.DARK.ID)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_DARK)

local ENUM_DMG_BONUS = 0.1
local ENUM_LOSEMANTLE_DMG = 60

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not mod:isAtlasA(player)) then return end

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.DARK.ID)

    if(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*(1+ENUM_DMG_BONUS*numMantles)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player EntityPlayer
local function mantleDestroyed(_, player, mantle)
    if(not mod:isAtlasA(player)) then return end
    if(not mod:atlasHasTransformation(player, mod.MANTLE_DATA.DARK.ID)) then return end

    for _, enemy in ipairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 800, EntityPartition.ENEMY)) do
        enemy:TakeDamage(ENUM_LOSEMANTLE_DMG, 0, EntityRef(player), 30)
    end

    sfx:Play(SoundEffect.SOUND_DEATH_CARD)

    local poof = Isaac.Spawn(1000,16,1,player.Position,Vector.Zero,nil):ToEffect()
    poof.Color = Color(0.1,0.1,0.1,1)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, mantleDestroyed)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(not mod:isAtlasA(player)) then return end

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, playMantleSFX, mod.MANTLE_DATA.DARK.ID)