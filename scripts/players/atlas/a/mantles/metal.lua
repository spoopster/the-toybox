local mod = MilcomMOD
local sfx = SFXManager()

--* maybe make sfx better

if(mod.ATLAS_A_MANTLESUBTYPES) then
    mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_METAL] = true
end

local function useMantle(_, _, player, _)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        mod:giveMantle(player, mod.MANTLES.METAL)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_METAL)

local ENUM_SPEED_BONUS = -0.1
local ENUM_BLOCKCHANCE = 1/15 --1/5 for all 3
local ENUM_DAMAGECOOLDOWN = 60
local ENUM_TRANSF_BLOCKCHANCE = 1/4

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLES.METAL)

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+ENUM_SPEED_BONUS*numMantles
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player Entity
local function cancelAtlasAMetalMantleDamage(_, player, dmg, flags, source, frames)
    player = player:ToPlayer()
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)
    
    local numMantles = mod:getNumMantlesByType(player, mod.MANTLES.METAL)

    if(dmg>0) then
        local rng = player:GetCardRNG(mod.CONSUMABLE_MANTLE_METAL)

        local blockChance = ENUM_BLOCKCHANCE*numMantles
        if(mod:atlasHasTransformation(player, mod.MANTLES.METAL)) then
            blockChance = ENUM_TRANSF_BLOCKCHANCE
            if(flags & DamageFlag.DAMAGE_SPIKES ~= 0 and Game():GetRoom():GetType()~=RoomType.ROOM_SACRIFICE) then blockChance = 1 end
        end

        if(rng:RandomFloat()<blockChance) then
            player:SetMinDamageCooldown(ENUM_DAMAGECOOLDOWN*(player:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE)+1))
            player:SetColor(Color(0,0,0.5,1,0.9,0.9,1),10,0,true,false)

            sfx:Play(mod.SFX_ATLASA_METALBLOCK)

            return false
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -1e12, cancelAtlasAMetalMantleDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    sfx:Play(mod.SFX_ATLASA_METALBREAK, 1.4)
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_LOSE_MANTLE, playMantleSFX, mod.MANTLES.METAL)