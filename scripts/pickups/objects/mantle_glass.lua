local mod = MilcomMOD
local sfx = SFXManager()

local DMG_MULT = 0.5
local TAKE_DMG_MULT = 2
local TAKE_DMG_INC = 2

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.GLASS.ID)
    else
        local data = mod:getEntityDataTable(player)
        data.MANTLEGLASS_ACTIVE = (data.MANTLEGLASS_ACTIVE or 0)+1
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

        sfx:Play(SoundEffect.SOUND_GLASS_BREAK)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE.MANTLE_GLASS)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local data = mod:getEntityDataTable(player)
    data.MANTLEGLASS_ACTIVE = 0
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    local glassNum = mod:getEntityData(player, "MANTLEGLASS_ACTIVE")
    if(not (glassNum and glassNum>0)) then return end

    if(flag==CacheFlag.CACHE_DAMAGE) then
        player.Damage = player.Damage*(1+glassNum*DMG_MULT)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player Entity
---@param source EntityRef
local function increaseDamage(_, player, dmg, flags, source)
    player = player:ToPlayer()
    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    local data = mod:getEntityDataTable(player)
    if(data.MANTLEGLASS_ACTIVE and data.MANTLEGLASS_ACTIVE>0 and dmg>0) then
        return
        {
            Damage = dmg*TAKE_DMG_MULT+data.MANTLEGLASS_ACTIVE*TAKE_DMG_INC,
            DamageFlags = flags,
            DamageCountdown = countdown,
        }
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, increaseDamage, EntityType.ENTITY_PLAYER)

---@param player Entity
---@param source EntityRef
local function spawnBloodPoof(_, player, dmg, flags, source)
    player = player:ToPlayer()
    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    local data = mod:getEntityDataTable(player)
    if(data.MANTLEGLASS_ACTIVE and data.MANTLEGLASS_ACTIVE>0 and dmg>0) then
        local blood = Isaac.Spawn(1000,16,4,player.Position,Vector.Zero,player):ToEffect()
        sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, spawnBloodPoof, EntityType.ENTITY_PLAYER)

if(mod.ATLAS_A_MANTLESUBTYPES) then mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE.MANTLE_GLASS] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(mod.CONSUMABLE.MANTLE_GLASS).Weight = (mod.CONFIG.MANTLE_WEIGHT or 0.5)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)