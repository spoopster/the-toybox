
local sfx = SFXManager()

local SHOCKWAVE_DMG = 10

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.DEFAULT.ID)
    else
        local data = ToyboxMod:getEntityDataTable(player)
        data.MANTLEROCK_ACTIVE = (data.MANTLEROCK_ACTIVE or 0)+1
        ToyboxMod:addItemForRoom(player, CollectibleType.COLLECTIBLE_TERRA, 1)
        --ToyboxMod.HiddenItemManager:AddForRoom(player, CollectibleType.COLLECTIBLE_TERRA, nil, 1, "TOYBOX")
        sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_ROCK)

---@param player EntityPlayer
local function postNewRoom(_, player)
    local data = ToyboxMod:getEntityDataTable(player)
    data.MANTLEROCK_ACTIVE = 0
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, postNewRoom)

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
            Delay = 3,
            AngleVariation = 80,
            DamageCooldown = 10,
            DestroyGrid=1,
        }
        for i=1, data.MANTLEROCK_ACTIVE*dmg do
            ToyboxMod:spawnCustomObjects(spawnData)
        end

        local poof = Isaac.Spawn(1000,16,2,player.Position,Vector.Zero,player):ToEffect()
        poof.Color = Color(0.75,0.75,0.75,0.65)
        sfx:Play(ToyboxMod.SOUND_EFFECT.ATLASA_ROCKBREAK)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, fireShockwaves, EntityType.ENTITY_PLAYER)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_ROCK] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(ToyboxMod.CARD_MANTLE_ROCK).Weight = (ToyboxMod.CONFIG.MANTLE_WEIGHT or 0.5)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)