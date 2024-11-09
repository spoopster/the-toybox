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

local MANTLE_DMG_UP = 0.4
local MANTLE_BLOODSOUL_DROPCHANCE = 6.66*0.01 -- 20% total
--local MANTLE_BLACKSOUL_DROPCHANCE = 5*0.01 -- 15% total
local TRANSF_BLACKSOUL_DROPCHANCE = 15*0.01 -- 10%
local TRANSF_BLACKSOUL_CHANCE_FALLOFF_POWER = 2

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not mod:isAtlasA(player)) then return end
    local numMantles = mod:getNumMantlesByType(player, mod.MANTLE_DATA.DARK.ID)
    
    if(flag==CacheFlag.CACHE_DAMAGE) then
        mod:addBasicDamageUp(player, MANTLE_DMG_UP*numMantles)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param npc EntityNPC
local function enemyDie(_, npc)
    if(not npc:IsEnemy()) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local rng = pl:GetCardRNG(mod.CONSUMABLE_MANTLE_DARK)
        if(mod:isAtlasA(pl)) then
            local data = mod:getEntityDataTable(pl)
            local plDir = (npc.Position-pl.Position):Resized(20)
            local numMantles = mod:getNumMantlesByType(pl, mod.MANTLE_DATA.DARK.ID)
            --[[]]
            if(rng:RandomFloat()<MANTLE_BLOODSOUL_DROPCHANCE*numMantles) then
                local bloodSoul = Isaac.Spawn(EntityType.ENTITY_PICKUP, mod.PICKUP_BLOOD_SOUL, 0, npc.Position, plDir:Rotated(rng:RandomInt(60)-30), pl):ToPickup()
            end
            if(mod:atlasHasTransformation(pl, mod.MANTLE_DATA.DARK.ID)) then
                if(rng:RandomFloat()<TRANSF_BLACKSOUL_DROPCHANCE/(math.max(data.BLACKSOUL_COUNTER or 0, 1)^TRANSF_BLACKSOUL_CHANCE_FALLOFF_POWER)) then
                    local blackSoul = Isaac.Spawn(EntityType.ENTITY_PICKUP, mod.PICKUP_BLACK_SOUL, 0, npc.Position, plDir:Rotated(rng:RandomInt(60)-30), pl):ToPickup()
                end
            end
            --]]
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, enemyDie)

---@param pl EntityPlayer
local function imposeMinBlackSoul(_, pl)
    if(not mod:isAtlasA(pl)) then return end
    if(not mod:atlasHasTransformation(pl, mod.MANTLE_DATA.DARK.ID)) then return end

    local data = mod:getEntityDataTable(pl)
    if(not (data.BLACKSOUL_COUNTER and data.BLACKSOUL_COUNTER>=1)) then
        data.BLACKSOUL_COUNTER = 1
        mod:addBlackSoulCounter(pl, 0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, imposeMinBlackSoul)