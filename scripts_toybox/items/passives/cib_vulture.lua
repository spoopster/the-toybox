local sfx = SFXManager()

local DMG_LUCK_DEC = 1
local FLOOR_LUCK_INC = 2

local BASE_LUCK = 8

---@param pl EntityPlayer
---@param isInitFinished boolean
local function luckBonus(_, pl, _, isInitFinished)
    if(pl.FrameCount==0) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_CIB_VULTURE)) then return end

    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_CIB_VULTURE)

    local bonus = ToyboxMod:getEntityData(pl, "CIB_LUCK_OFFSET") or 0
    ToyboxMod:setEntityData(pl, "CIB_LUCK_OFFSET", bonus+FLOOR_LUCK_INC*mult)

    pl:AddCacheFlags(CacheFlag.CACHE_LUCK, true)

    Isaac.CreateTimer(
        function(eff)
            if(eff.FrameCount>0) then
                pl:SetColor(Color(1,1,1,1,0.8,0.76,0.4),20,0,true,false)
                sfx:Play(ToyboxMod.SFX_STAR_TRANSFORM, 1, 2, false, 0.95+math.random()*0.1)
            end
        end,
        1, 2, true
    )
    Isaac.CreateTimer(
        function(eff)
            if(eff.FrameCount>0) then
                pl:CreateAfterimage(10, pl.Position)
            end
        end,
        5, 5, true
    )
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, luckBonus)

---@param player Entity
local function luckPenalty(_, player, _, flags, source)
    player = player:ToPlayer()
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_CIB_VULTURE)) then return end

    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    local mult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_CIB_VULTURE)

    local bonus = ToyboxMod:getEntityData(player, "CIB_LUCK_OFFSET") or 0
    ToyboxMod:setEntityData(player, "CIB_LUCK_OFFSET", bonus-DMG_LUCK_DEC*mult)

    player:AddCacheFlags(CacheFlag.CACHE_LUCK, true)

    sfx:Play(ToyboxMod.SFX_POISON)
    sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, luckPenalty, EntityType.ENTITY_PLAYER)

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_CIB_VULTURE)) then return end

    local bonus = (ToyboxMod:getEntityData(pl, "CIB_LUCK_OFFSET") or 0)+BASE_LUCK
    pl.Luck = pl.Luck+bonus
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_LUCK)