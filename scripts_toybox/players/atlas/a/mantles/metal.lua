
local sfx = SFXManager()

--* maybe make sfx better

local SPEED_UP = -0.1
local BLOCKCHANCE_MANTLE = 0.05 --15% for all 3
local BLOCKCHANCE_TRANSF = 0.1 --10%
local BLOCK_DMGCOOLDOWN = 60

local CREEP_VARIANTS = {
    [EffectVariant.CREEP_RED] = 0,
    [EffectVariant.CREEP_GREEN] = 0,
    [EffectVariant.CREEP_YELLOW] = 0,
    [EffectVariant.CREEP_WHITE] = 0,
    [EffectVariant.CREEP_BLACK] = 0,
    [EffectVariant.PLAYER_CREEP_LEMON_MISHAP] = 0,
    [EffectVariant.PLAYER_CREEP_HOLYWATER] = 0,
    [EffectVariant.PLAYER_CREEP_WHITE] = 0,
    [EffectVariant.PLAYER_CREEP_BLACK] = 0,
    [EffectVariant.PLAYER_CREEP_RED] = 0,
    [EffectVariant.PLAYER_CREEP_GREEN] = 0,
    [EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL] = 0,
    [EffectVariant.CREEP_BROWN] = 0,
    [EffectVariant.PLAYER_CREEP_LEMON_PARTY] = 0,
    [EffectVariant.PLAYER_CREEP_PUDDLE_MILK] = 0,
    [EffectVariant.PLAYER_CREEP_BLACKPOWDER] = 0,
    [EffectVariant.CREEP_SLIPPERY_BROWN] = 0,
    [EffectVariant.CREEP_SLIPPERY_BROWN_GROWING] = 0,
    [EffectVariant.CREEP_STATIC] = 0,
    [EffectVariant.CREEP_LIQUID_POOP] = 0,
}

local function getBlockChance(player)
    if(not ToyboxMod:isAtlasA(player)) then return 0 end

    return BLOCKCHANCE_MANTLE*ToyboxMod:getNumMantlesByType(player, ToyboxMod.MANTLE_DATA.METAL.ID)+BLOCKCHANCE_TRANSF*(ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.METAL.ID) and 1 or 0)
end

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not ToyboxMod:isAtlasA(player)) then return end
    local numMantles = ToyboxMod:getNumMantlesByType(player, ToyboxMod.MANTLE_DATA.METAL.ID)

    if(flag==CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = player.MoveSpeed+SPEED_UP*numMantles
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

---@param player Entity
---@param source EntityRef
---@param flags DamageFlag
local function cancelAtlasAMetalMantleDamage(_, player, dmg, flags, source, frames)
    if(not ToyboxMod:isAtlasA(player:ToPlayer())) then return end
    player = player:ToPlayer()

    if(dmg>0) then
        local blockChance = getBlockChance(player)
        if(ToyboxMod:atlasHasTransformation(player, ToyboxMod.MANTLE_DATA.METAL.ID)) then
            if(flags & DamageFlag.DAMAGE_SPIKES~=0 and Game():GetRoom():GetType()~=RoomType.ROOM_SACRIFICE) then blockChance = 1
            elseif(flags & DamageFlag.DAMAGE_ACID~=0) then blockChance = 1 end
        end

        local rng = player:GetCardRNG(ToyboxMod.CARD_MANTLE_METAL)
        if(rng:RandomFloat()<blockChance) then
            player:SetMinDamageCooldown(BLOCK_DMGCOOLDOWN*(player:GetTrinketMultiplier(TrinketType.TRINKET_BLIND_RAGE)+1))
            player:SetColor(Color(0,0,0.5,1,0.9,0.9,1),10,0,true,false)

            sfx:Play(ToyboxMod.SFX_ATLASA_METALBLOCK)

            return false
        end
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, -1e12, cancelAtlasAMetalMantleDamage, EntityType.ENTITY_PLAYER)