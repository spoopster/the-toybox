
local sfx = SFXManager()

local SHOCKWAVE_DMG = 10

local CARBATTERY_RANDOM_NUM = 2
local CARBATTERY_SIZEUP = 0.2

---@param player EntityPlayer
---@param flags UseFlag
local function useMantle(_, _, player, flags)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CONGLOMERATE) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.DEFAULT.ID)
    else
        local data = ToyboxMod:getEntityDataTable(player)
        data.MANTLEROCK_ACTIVE = (data.MANTLEROCK_ACTIVE or 0)+1
        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            if(data.MANTLEROCK_ACTIVE==data.MANTLEROCK_ACTIVE//1) then
                data.MANTLEROCK_ACTIVE = data.MANTLEROCK_ACTIVE+0.5
            end
            player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_LEO, false)
            player:AddCacheFlags(CacheFlag.CACHE_SIZE)
        end

        ToyboxMod:addItemForRoom(player, CollectibleType.COLLECTIBLE_TERRA, 1)
        --ToyboxMod.HiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_TERRA, nil, 1, "TOYBOX")
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_ROCK)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    if(data.MANTLEROCK_ACTIVE and data.MANTLEROCK_ACTIVE~=data.MANTLEROCK_ACTIVE//1) then
        player:AddCacheFlags(CacheFlag.CACHE_SIZE)
    end
    data.MANTLEROCK_ACTIVE = 0
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    local rockNum = ToyboxMod:getEntityData(player, "MANTLEROCK_ACTIVE")
    if(not (rockNum and rockNum>0 and rockNum~=rockNum//1)) then return end

    player.SpriteScale = player.SpriteScale*(1+(rockNum//1)*CARBATTERY_SIZEUP)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_SIZE)

---@param player Entity
---@param source EntityRef
local function fireShockwaves(_, player, dmg, flags, source)
    player = player:ToPlayer()
    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    local data = ToyboxMod:getEntityDataTable(player)
    if(data.MANTLEROCK_ACTIVE and data.MANTLEROCK_ACTIVE>0) then
        local ent = source.Entity
        if(ent and not ent:ToNPC()) then
            if(ent.SpawnerEntity and ent.SpawnerEntity:ToNPC()) then ent = ent.SpawnerEntity
            elseif(ent.Parent and ent.Parent:ToNPC()) then ent = ent.Parent end
        end

        local rng = player:GetCardRNG(ToyboxMod.CARD_MANTLE_ROCK)
        local angle = ((ent and ent.Position or source.Position)-player.Position):GetAngleDegrees()
        local spawnData = {
            SpawnType = "LINE",
            SpawnData = {EntityType.ENTITY_EFFECT,EffectVariant.ROCK_EXPLOSION,0},
            SpawnerEntity = player,
            Position = player.Position,
            Amount = 15,
            Damage = SHOCKWAVE_DMG,
            PlayerFriendly = true,
            Distance = Vector(35,0):Rotated(angle),
            Delay = 2+rng:RandomInt(0,2),
            AngleVariation = 80,
            DamageCooldown = 10,
            DestroyGrid=1,
        }
        for _=1, (data.MANTLEROCK_ACTIVE//1)*dmg do
            ToyboxMod:spawnCustomObjects(spawnData)
        end

        if(data.MANTLEROCK_ACTIVE~=data.MANTLEROCK_ACTIVE//1) then
            for _=1, (data.MANTLEROCK_ACTIVE//1)*dmg*CARBATTERY_RANDOM_NUM do
                local randSpawnData = {
                    SpawnType = "LINE",
                    SpawnData = {EntityType.ENTITY_EFFECT,EffectVariant.ROCK_EXPLOSION,0},
                    SpawnerEntity = player,
                    Position = player.Position,
                    Amount = 15,
                    Damage = SHOCKWAVE_DMG,
                    PlayerFriendly = true,
                    Distance = Vector(35,0):Rotated(rng:RandomInt(1,360)),
                    Delay = 2+rng:RandomInt(0,2),
                    AngleVariation = 80,
                    DamageCooldown = 10,
                    DestroyGrid=1,
                }
                ToyboxMod:spawnCustomObjects(randSpawnData)
            end
        end

        local poof = Isaac.Spawn(1000,16,2,player.Position,Vector.Zero,player):ToEffect()
        poof.Color = Color(0.75,0.75,0.75,0.65)
        sfx:Play(ToyboxMod.SFX_ATLASA_ROCKBREAK)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, fireShockwaves, EntityType.ENTITY_PLAYER)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_ROCK] = true end